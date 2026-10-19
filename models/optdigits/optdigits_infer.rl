get * from std::io
get * from std::math
get * from std::str
get * from std::array
get * from std::types
get * from std::res
get * from std::fs
get * from std::serialize
get std::len

fn sigmoid(float x) -> float
{
    return 1.0 / (1.0 + exp(0.0 - x).result_unwrap())
}

fn model_load(string path) -> arr[arr[float]]
{
    dec string raw = read_file(path).result_unwrap()
    dec arr[arr[string]] lines = csv_parse(raw).result_unwrap()
    dec arr[arr[float]] model = []

    model = arr_push(
        model,
        arr_map(
            lines[0],
            fn (string i) -> float { return i.to_float().result_unwrap() }
        ).result_unwrap()
    ).result_unwrap()
    model = arr_push(
        model,
        arr_map(
            lines[1],
            fn (string i) -> float { return i.to_float().result_unwrap() }
        ).result_unwrap()
    ).result_unwrap()
    model = arr_push(
        model,
        arr_map(
            lines[2],
            fn (string i) -> float { return i.to_float().result_unwrap() }
        ).result_unwrap()
    ).result_unwrap()
    model = arr_push(
        model,
        arr_map(
            lines[3],
            fn (string i) -> float { return i.to_float().result_unwrap() }
        ).result_unwrap()
    ).result_unwrap()
    return model
}

fn print_ascii(arr[string] row)
{
    for r in 0..8
    {
        dec line = ""
        for c in 0..8
        {
            dec v = row[r * 8 + c].to_float().result_unwrap()
            dec glyph = " "
            if v > 0.0 { glyph = "." }
            if v > 4.0 { glyph = "+" }
            if v > 11.0 { glyph = "#" }
            line = concat(line, glyph)
        }
        println(line)
    }
    println("")
}

// ============ 1. LOAD MODEL ============
dec arr[arr[float]] model = model_load("optdigits_model.csv")
dec arr[float] w1 = model[0]
dec arr[float] b1 = model[1]
dec arr[float] w2 = model[2]
dec arr[float] b2 = model[3]

// shapes derived from the artifact (w1: n_hid x n_in, b1: n_hid, w2: n_out x n_hid, b2: n_out)
dec int n_out = len(b2).result_unwrap()
dec int n_hid = len(b1).result_unwrap()
dec int n_in = len(w1).result_unwrap() / n_hid
println(format("model: n_in {}  n_hid {}  n_out {}", n_in, n_hid, n_out))

// ============ 2. LOAD TEST ROWS ============
dec arr[arr[string]] rows = arr_filter(
    csv_parse(read_file("optdigits.tes").result_unwrap()).result_unwrap(),
    fn (arr[string] r) -> bool { return r.len().result_unwrap() == 65 }
).result_unwrap()
dec int n_test = len(rows).result_unwrap()

dec arr[float] xs = arr_fill(0.0, n_test * n_in)
dec arr[int] labels = arr_fill(0, n_test)
for [int s = 0, s < n_test, s += 1]
{
    dec arr[string] r = rows[s]
    for [int k = 0, k < n_in, k += 1]
    {
        xs[s * n_in + k] = r[k].to_float().result_unwrap() / 16.0
    }
    labels[s] = r[n_in].to_int().result_unwrap()
}
println(format("test rows: {}", n_test))

// ============ 3. EVAL ============
dec arr[float] a = arr_fill(0.0, n_hid)
dec arr[float] p = arr_fill(0.0, n_out)
dec arr[int] preds = arr_fill(0, n_test)
dec int correct = 0
dec arr[int] confusion = arr_fill(0, n_out * n_out)

for [int s = 0, s < n_test, s += 1]
{
    // forward: hidden activations into a[]
    for [int j = 0, j < n_hid, j += 1]
    {
        dec float z = b1[j]
        for [int k = 0, k < n_in, k += 1]
        {
            z = z + w1[j * n_in + k] * xs[s * n_in + k]
        }
        a[j] = sigmoid(z)
    }
    // forward: logits into p[] (argmax on logits == argmax on softmax)
    for [int i = 0, i < n_out, i += 1]
    {
        dec float z = b2[i]
        for [int j = 0, j < n_hid, j += 1]
        {
            z = z + w2[i * n_hid + j] * a[j]
        }
        p[i] = z
    }

    dec int pred = 0
    for [int i = 1, i < n_out, i += 1]
    {
        if p[i] > p[pred] { pred = i }
    }
    preds[s] = pred
    dec int label = labels[s]
    if pred == label { correct = correct + 1 }
    confusion[label * n_out + pred] = confusion[label * n_out + pred] + 1
}

println(format(
    "TEST ACC: {}/{} = {}",
    correct,
    n_test,
    correct.to_float().result_unwrap() / n_test.to_float().result_unwrap()
))

println("confusion (rows = true, cols = predicted):")
for [int i = 0, i < n_out, i += 1]
{
    dec string line = ""
    for [int j = 0, j < n_out, j += 1]
    {
        line = concat(line, format("{} ", confusion[i * n_out + j]))
    }
    println(line)
}

// ============ 4. DEMO: one row from each eighth of the test file ============
println("--- sample predictions ---")
dec int step = n_test / 8
for i in 0..8
{
    dec int s = i * step
    print_ascii(rows[s])
    dec string verdict = "MISS"
    if preds[s] == labels[s] { verdict = "ok" }
    println(format("pred {}  true {}  {}", preds[s], labels[s], verdict))
}
