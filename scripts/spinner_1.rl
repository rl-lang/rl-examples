get term_flush from std::term
get sleep from std::process
get print from std::io
get format from std::str
get args from std::process
get arr_reverse, arr_contains, len from std::array

// --- basic set of animations
dec dots = ["⠋", "⠙", "⠸", "⢰", "⣠", "⣄", "⡆", "⠇"]

// --- checking weather reverse
//     option is provided or not
dec args = args()
if args.arr_contains("-r")? {
  dots = dots.arr_reverse()?
}

// --- infinitly print the array
//     of dots/animations
while true {
  for dot in dots {
    print(format("\r{}", dot))
    term_flush()?
    sleep(100)
  }
}
