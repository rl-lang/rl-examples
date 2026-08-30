get term_flush from std::term
get sleep from std::process
get print from std::io
get format from std::str
get args from std::process
get arr_reverse, arr_contains, arr_last, arr_index_of, len from std::array

// --- global variables
dec bool reversed = false
dec int style = 0
dec arr[string] frames = []

// --- basic set of animations
dec dots = ["⠋", "⠙", "⠸", "⢰", "⣠", "⣄", "⡆", "⠇"]

// --- checking weather reverse
//     option is provided or not
dec args = args()

if args.arr_contains("-r")? {
  reversed = true
}

if args.arr_contains("-s")? {
  dec target_index = args.arr_index_of("-s")?
  if !(args[target_index] == args.arr_last()?) {
    if target_index + 1 >= args.len()? {
      match args[target_index + 1] {
        "dots" => { style = 0 }
        _ => { style = 0 }
      }
    }
  }
}

match style {
  0 => {
    frames = dots
    if reversed {
      frames = frames.arr_reverse()?
    }
  }
}

// --- infinitly print the array
//     of dots/animations
while true {
  for frame in frames {
    print(format("\r{}", frame))
    term_flush()?
    sleep(100)
  }
}
