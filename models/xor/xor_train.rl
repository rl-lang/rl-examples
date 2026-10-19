get * from std::io
get * from std::math
get * from std::random
get * from std::array
get * from std::str
get * from std::types
get * from std::fs
get * from std::res
get * from std::serialize

fn sigmoid(float x) -> float {
    return 1.0 / (1.0 + exp(0.0 - x).result_unwrap())
}

fn sigmoid_d(float x) -> float {
    return x * (1.0 - x)
}

fn model_save(string path, arr[float] w0, arr[float] b0, arr[float] w1, float b1) {
    dec w0s = arr_map(w0, fn(float i) -> string { return i.to_string().result_unwrap() }).result_unwrap()
    dec b0s = arr_map(b0, fn(float i) -> string { return i.to_string().result_unwrap() }).result_unwrap()
    dec w1s = arr_map(w1, fn(float i) -> string { return i.to_string().result_unwrap() }).result_unwrap()
    dec b1s = [to_string(b1).result_unwrap()]

    write_file(path, csv_stringify([w0s, b0s, w1s, b1s]))
}

// --- ask for epochs ---
dec int epochs = 100000

// --- training data ---
dec arr[float] x0 = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0]
dec arr[float] x1 = [0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0]
dec arr[float] x2 = [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0]
dec arr[float] y  = [0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0]

// --- xavier init ---
dec float xs_hidden = 0.577
dec float xs_output = 0.354

dec arr[float] w0 = []
for _i in 0..24 {
    w0 = w0.arr_push(rand_float_range(0.0 - xs_hidden, xs_hidden)?)?
}

dec arr[float] b0 = []
for _i in 0..8 {
    b0 = b0.arr_push(0.0)?
}

dec arr[float] w1 = []
for _i in 0..8 {
    w1 = w1.arr_push(rand_float_range(0.0 - xs_output, xs_output)?)?
}

dec float b1 = 0.0

dec float lr = 0.5
dec float total_loss = 0.0
dec arr[int] order = [0, 1, 2, 3, 4, 5, 6, 7]

for [int e = 0, e < epochs, e += 1] {
    total_loss = 0.0
    order = rand_shuffle(order)?

    for idx in order {
        dec int s = idx
        dec float in0   = x0[s]
        dec float in1   = x1[s]
        dec float in2   = x2[s]
        dec float target = y[s]

        dec float h0 = sigmoid(w0[0]  * in0 + w0[8]  * in1 + w0[16] * in2 + b0[0])
        dec float h1 = sigmoid(w0[1]  * in0 + w0[9]  * in1 + w0[17] * in2 + b0[1])
        dec float h2 = sigmoid(w0[2]  * in0 + w0[10] * in1 + w0[18] * in2 + b0[2])
        dec float h3 = sigmoid(w0[3]  * in0 + w0[11] * in1 + w0[19] * in2 + b0[3])
        dec float h4 = sigmoid(w0[4]  * in0 + w0[12] * in1 + w0[20] * in2 + b0[4])
        dec float h5 = sigmoid(w0[5]  * in0 + w0[13] * in1 + w0[21] * in2 + b0[5])
        dec float h6 = sigmoid(w0[6]  * in0 + w0[14] * in1 + w0[22] * in2 + b0[6])
        dec float h7 = sigmoid(w0[7]  * in0 + w0[15] * in1 + w0[23] * in2 + b0[7])

        dec float out = sigmoid(w1[0]*h0 + w1[1]*h1 + w1[2]*h2 + w1[3]*h3 + w1[4]*h4 + w1[5]*h5 + w1[6]*h6 + w1[7]*h7 + b1)

        dec float err_rate = target - out
        total_loss = total_loss + err_rate * err_rate

        dec float d_out = err_rate * sigmoid_d(out)

        dec float d_h0 = d_out * w1[0] * sigmoid_d(h0)
        dec float d_h1 = d_out * w1[1] * sigmoid_d(h1)
        dec float d_h2 = d_out * w1[2] * sigmoid_d(h2)
        dec float d_h3 = d_out * w1[3] * sigmoid_d(h3)
        dec float d_h4 = d_out * w1[4] * sigmoid_d(h4)
        dec float d_h5 = d_out * w1[5] * sigmoid_d(h5)
        dec float d_h6 = d_out * w1[6] * sigmoid_d(h6)
        dec float d_h7 = d_out * w1[7] * sigmoid_d(h7)

        w1[0] = w1[0] + lr * d_out * h0
        w1[1] = w1[1] + lr * d_out * h1
        w1[2] = w1[2] + lr * d_out * h2
        w1[3] = w1[3] + lr * d_out * h3
        w1[4] = w1[4] + lr * d_out * h4
        w1[5] = w1[5] + lr * d_out * h5
        w1[6] = w1[6] + lr * d_out * h6
        w1[7] = w1[7] + lr * d_out * h7
        b1 = b1 + lr * d_out

        w0[0]  = w0[0]  + lr * d_h0 * in0
        w0[8]  = w0[8]  + lr * d_h0 * in1
        w0[16] = w0[16] + lr * d_h0 * in2
        b0[0]  = b0[0]  + lr * d_h0

        w0[1]  = w0[1]  + lr * d_h1 * in0
        w0[9]  = w0[9]  + lr * d_h1 * in1
        w0[17] = w0[17] + lr * d_h1 * in2
        b0[1]  = b0[1]  + lr * d_h1

        w0[2]  = w0[2]  + lr * d_h2 * in0
        w0[10] = w0[10] + lr * d_h2 * in1
        w0[18] = w0[18] + lr * d_h2 * in2
        b0[2]  = b0[2]  + lr * d_h2

        w0[3]  = w0[3]  + lr * d_h3 * in0
        w0[11] = w0[11] + lr * d_h3 * in1
        w0[19] = w0[19] + lr * d_h3 * in2
        b0[3]  = b0[3]  + lr * d_h3

        w0[4]  = w0[4]  + lr * d_h4 * in0
        w0[12] = w0[12] + lr * d_h4 * in1
        w0[20] = w0[20] + lr * d_h4 * in2
        b0[4]  = b0[4]  + lr * d_h4

        w0[5]  = w0[5]  + lr * d_h5 * in0
        w0[13] = w0[13] + lr * d_h5 * in1
        w0[21] = w0[21] + lr * d_h5 * in2
        b0[5]  = b0[5]  + lr * d_h5

        w0[6]  = w0[6]  + lr * d_h6 * in0
        w0[14] = w0[14] + lr * d_h6 * in1
        w0[22] = w0[22] + lr * d_h6 * in2
        b0[6]  = b0[6]  + lr * d_h6

        w0[7]  = w0[7]  + lr * d_h7 * in0
        w0[15] = w0[15] + lr * d_h7 * in1
        w0[23] = w0[23] + lr * d_h7 * in2
        b0[7]  = b0[7]  + lr * d_h7
    }

    dec int interval = epochs / 10
    if (interval < 1) { interval = 1 }
    if (e.mod(interval)? == 0) {
        println(format("Epoch {} / {} | Loss: {}", e, epochs, total_loss / 8.0))
    }
}

model_save("xor_model.csv", w0, b0, w1, b1)
println(format("\nDone. Model saved to xor_model.csv"))


