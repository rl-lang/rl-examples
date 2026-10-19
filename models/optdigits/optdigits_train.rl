get * from std::io
get * from std::math
get * from std::math::consts
get * from std::random
get * from std::array
get * from std::str
get * from std::types
get * from std::fs
get * from std::res
get * from std::serialize
get std::len

dec int n_in = 64
dec int n_hid = 64
dec int n_out = 10
dec int epochs = 100
dec string TRAIN_FILE = "optdigits.tra"

fn sigmoid(float x) -> float
{
    return 1.0 / (1.0 + exp(0.0 - x).result_unwrap())
}

fn sigmoid_d(float x) -> float
{
    return x * (1.0 - x)
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

// ============ 3. LOAD DATA ============
rand_seed(22122)

dec arr[arr[string]] rows = csv_parse(read_file(TRAIN_FILE).result_unwrap()).result_unwrap()

// rows: arr[arr[string]], 3823 entries of 65 strings (64 pixels + label)
dec int n_rows = len(rows).result_unwrap()
dec arr[float] xs = arr_fill(0.0, n_rows * 64)
dec arr[int] labels = arr_fill(0, n_rows)
for [int s = 0, s < n_rows, s += 1]
{
    dec arr[string] r = rows[s]
    for [int k = 0, k < 64, k += 1] { xs[s * 64 + k] = r[k].to_float().result_unwrap() / 16.0 }
    labels[s] = r[64].to_int().result_unwrap()
}

dec int n_rows = labels.len().result_unwrap()

// ============ 4. SANITY PRINTS (delete after first run) ============
println(format(
    "rows: {}  fields: {}  labels 0..9",
    n_rows,
    65
))

// pixel min/max over xs (expect 0.0 .. 1.0 after /16)
// histogram: count per label (expect ~380 each)
print_ascii(rows[0])

// ============ 5. INIT WEIGHTS ============
dec float lim = 0.125// 1/sqrt(64)

dec arr[float] w1 = arr_fill(0.0, n_hid * n_in)// 4096, layout w1[j*n_in + k]
dec arr[float] b1 = arr_fill(0.0, n_hid)// 64
dec arr[float] w2 = arr_fill(0.0, n_out * n_hid)// 640,  layout w2[i*n_hid + j]
dec arr[float] b2 = arr_fill(0.0, n_out)// 10

for [int i = 0, i < n_hid * n_in, i += 1]
{
    w1[i] = rand_float_range(0.0 - lim, lim)?
}
for [int i = 0,i < n_out * n_hid, i += 1]
{
    w2[i] = rand_float_range(0.0 - lim, lim)?
}

dec arr[float] a = arr_fill(0.0, n_hid)// hidden activations
dec arr[float] p = arr_fill(0.0, n_out)// softmax output
dec arr[float] d_out = arr_fill(0.0, n_out)
dec arr[float] d_z = arr_fill(0.0, n_hid)

// ============ 6. TRAINING ============
dec float lr = 0.05
dec float epoch_loss = 0.0
dec int correct = 0
dec arr[int] order = arr_range(0, n_rows, 1)?

for [int e = 0, e < epochs, e += 1]
{
    order = rand_shuffle(order)?
    epoch_loss = 0.0
    correct = 0

    for idx in order
    {
        dec int s = idx
        dec int label = labels[s]

        // ---- FORWARD: hidden layer into a[] ----
        for [int j = 0, j < n_hid, j += 1]
        {
            dec float z = b1[j]
            for [int k = 0, k < n_in, k += 1]
            {
                z = z + w1[j * n_in + k] * xs[s * n_in + k]
            }
            a[j] = sigmoid(z)
        }

        // ---- FORWARD: logits into p[] (then softmax in place) ----
        for [int i = 0, i < n_out, i += 1]
        {
            dec float z = b2[i]
            for [int j = 0, j < n_hid, j += 1]
            {
                z = z + w2[i * n_hid + j] * a[j]
            }
            p[i] = z
        }
        dec float mx = p[0]
        for [int i = 1, i < n_out, i += 1]
        {
            if p[i] > mx { mx = p[i] }
        }
        dec float zsum = 0.0
        for [int i = 0, i < n_out, i += 1]
        {
            p[i] = exp(p[i] - mx).result_unwrap()
            zsum = zsum + p[i]
        }
        for [int i = 0, i < n_out, i += 1]
        {
            p[i] = p[i] / zsum
        }

        // ---- loss + accuracy ----
        dec float prob = p[label]
        if prob < 0.000001 { prob = 0.000001 }
        epoch_loss = epoch_loss + (0.0 - log(prob, 2.718281828459045).result_unwrap())

        dec int pred = 0
        for [int i = 1, i < n_out, i += 1]
        {
            if p[i] > p[pred] { pred = i }
        }
        if pred == label { correct = correct + 1 }

        // ---- BACKWARD: all gradients FIRST (d_z needs OLD w2) ----
        for [int i = 0, i < n_out, i += 1]
        {
            d_out[i] = p[i]
            if i == label { d_out[i] = d_out[i] - 1.0 }
        }
        for [int j = 0, j < n_hid, j += 1]
        {
            dec float da = 0.0
            for [int i = 0, i < n_out, i += 1]
            {
                da = da + d_out[i] * w2[i * n_hid + j]
            }
            d_z[j] = da * sigmoid_d(a[j])
        }

        // ---- UPDATE output layer ----
        for [int i = 0, i < n_out, i += 1]
        {
            for [int j = 0, j < n_hid, j += 1]
            {
                w2[i * n_hid + j] = w2[i * n_hid + j] - lr * d_out[i] * a[j]
            }
            b2[i] = b2[i] - lr * d_out[i]
        }

        // ---- UPDATE hidden layer ----
        for [int j = 0, j < n_hid, j += 1]
        {
            for [int k = 0, k < n_in, k += 1]
            {
                w1[j * n_in + k] = w1[j * n_in + k] - lr * d_z[j] * xs[s * n_in + k]
            }
            b1[j] = b1[j] - lr * d_z[j]
        }
    }

    // ---- progress ----
    dec int interval = epochs / 10
    if interval < 1 { interval = 1 }
    if e.mod(interval)? == 0
    {
        println(format(
            "Epoch {}/{} | loss {} | acc {}/{}",
            e,
            epochs,
            epoch_loss / n_rows.to_float().result_unwrap(),
            correct,
            n_rows
        ))
    }

    // OPTIONAL lr decay if loss plateaus noisy late:
    // if e.mod(30)? == 0 { lr = lr * 0.5 }
}

// ============ 7. EVAL ON TEST ============
dec arr[arr[string]] rows_t = arr_filter(
    csv_parse(read_file("optdigits.tes").result_unwrap()).result_unwrap(),
    fn (arr[string] r) -> bool { return r.len().result_unwrap() == 65 }
).result_unwrap()
dec int n_test = len(rows_t).result_unwrap()

dec arr[float] xs_t = arr_fill(0.0, n_test * n_in)
dec arr[int] labels_t = arr_fill(0, n_test)
for [int s = 0, s < n_test, s += 1]
{
    dec arr[string] r = rows_t[s]
    for [int k = 0, k < n_in, k += 1]
    {
        xs_t[s * n_in + k] = r[k].to_float().result_unwrap() / 16.0
    }
    labels_t[s] = r[64].to_int().result_unwrap()
}

dec int correct_t = 0
dec arr[int] confusion = arr_fill(0, 100)// index: true*10 + pred

for [int s = 0, s < n_test, s += 1]
{

    // forward only
    for [int j = 0, j < n_hid, j += 1]
    {
        dec float z = b1[j]
        for [int k = 0, k < n_in, k += 1]
        {
            z = z + w1[j * n_in + k] * xs_t[s * n_in + k]
        }
        a[j] = sigmoid(z)
    }
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

    dec int label = labels_t[s]
    if pred == label { correct_t = correct_t + 1 }
    confusion[label * 10 + pred] = confusion[label * 10 + pred] + 1
}

println(format(
    "TEST ACC: {}/{} = {}",
    correct_t,
    n_test,
    correct_t.to_float().result_unwrap() / n_test.to_float().result_unwrap()
))

println("confusion (rows = true, cols = predicted):")
for [int i = 0, i < n_out, i += 1]
{
    dec string line = ""
    for [int j = 0, j < n_out, j += 1]
    {
        line = concat(
            line,
            format("{} ", confusion[i * 10 + j])
        )
    }
    println(line)
}

// ============ 8. SAVE ============
fn model_save(
    string path, arr[float] w1, arr[float] b1, arr[float] w2, arr[float] b2
    )
{
    dec w1s = arr_map(
        w1,
        fn (float i) -> string { return i.to_string().result_unwrap() }
    ).result_unwrap()
    dec b1s = arr_map(
        b1,
        fn (float i) -> string { return i.to_string().result_unwrap() }
    ).result_unwrap()
    dec w2s = arr_map(
        w2,
        fn (float i) -> string { return i.to_string().result_unwrap() }
    ).result_unwrap()
    dec b2s = arr_map(
        b2,
        fn (float i) -> string { return i.to_string().result_unwrap() }
    ).result_unwrap()
    write_file(
        path,
        csv_stringify([w1s, b1s, w2s, b2s])
    )
}

model_save(
    "optdigits_model.csv",
    w1,
    b1,
    w2,
    b2
)
println("Done. Model saved to optdigits_model.csv")

