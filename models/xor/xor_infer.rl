get * from std::io
get * from std::math
get * from std::str
get * from std::array
get * from std::types
get * from std::res
get * from std::fs
get * from std::serialize

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

fn infer(
    arr[float] w0, arr[float] b0, arr[float] w1, float b1, float in0, float in1, float in2
    ) -> float
{
    dec float h0 = sigmoid(w0[0] * in0 + w0[8] * in1 + w0[16] * in2 + b0[0])
    dec float h1 = sigmoid(w0[1] * in0 + w0[9] * in1 + w0[17] * in2 + b0[1])
    dec float h2 = sigmoid(w0[2] * in0 + w0[10] * in1 + w0[18] * in2 + b0[2])
    dec float h3 = sigmoid(w0[3] * in0 + w0[11] * in1 + w0[19] * in2 + b0[3])
    dec float h4 = sigmoid(w0[4] * in0 + w0[12] * in1 + w0[20] * in2 + b0[4])
    dec float h5 = sigmoid(w0[5] * in0 + w0[13] * in1 + w0[21] * in2 + b0[5])
    dec float h6 = sigmoid(w0[6] * in0 + w0[14] * in1 + w0[22] * in2 + b0[6])
    dec float h7 = sigmoid(w0[7] * in0 + w0[15] * in1 + w0[23] * in2 + b0[7])
    return sigmoid(w1[0] * h0 + w1[1] * h1 + w1[2] * h2 + w1[3] * h3 + w1[4] * h4 + w1[5] * h5 + w1[6] * h6 + w1[7] * h7 + b1)
}

dec arr[arr[float]] model = model_load("xor_model.csv")
dec arr[float] w0 = model[0]
dec arr[float] b0 = model[1]
dec arr[float] w1 = model[2]
dec float b1 = model[3][0]

dec arr[float] inputs0 = [
    0.0,
    1.0,
    0.0,
    1.0,
    0.0,
    1.0,
    0.0,
    1.0,
]
dec arr[float] inputs1 = [
    0.0,
    0.0,
    1.0,
    1.0,
    0.0,
    0.0,
    1.0,
    1.0,
]
dec arr[float] inputs2 = [
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    1.0,
    1.0,
    1.0,
]
dec arr[float] targets = [
    0.0,
    1.0,
    1.0,
    0.0,
    1.0,
    0.0,
    0.0,
    1.0,
]

println("--- XOR Truth Table ---")
for [int s = 0, s < 8, s += 1]
{
    dec float out = infer(
        w0,
        b0,
        w1,
        b1,
        inputs0[s],
        inputs1[s],
        inputs2[s]
    )
    dec string verdict = "✗"
    if (out > 0.5 == targets[s] > 0.5) { verdict = "✓" }
    println(format(
        "{} XOR {} XOR {} => {}  (target: {})  {}",
        inputs0[s],
        inputs1[s],
        inputs2[s],
        out,
        targets[s],
        verdict
    ))
}
