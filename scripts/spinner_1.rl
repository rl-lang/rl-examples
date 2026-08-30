get term_flush from std::term
get sleep from std::process
get print, eprintln from std::io
get format from std::str
get args, exit from std::process
get arr_reverse, arr_contains, arr_last, arr_index_of, len from std::array

// --- global variables
dec bool reversed = false
dec int style = 0
dec arr[string] frames = []

// --- basic set of animations
dec dots = ["⠋", "⠙", "⠸", "⢰", "⣠", "⣄", "⡆", "⠇"]
dec wave = ["⠀", "⠄", "⠆", "⠇", "⠏", "⠗", "⠿", "⣿", "⣷", "⣶", "⣦", "⣤", "⣄", "⣀", "⠤", "⠐"]
dec pulse = ["⣀", "⣤", "⣶", "⣾", "⣿", "⣶", "⣤", "⣀"]
dec fill = ["⠀", "⡀", "⣀", "⣄", "⣤", "⣦", "⣴", "⣼", "⣶", "⣾", "⣿"]
dec bounce = ["⠁", "⠈", "⠐", "⠠", "⡀", "⢀", "⠠", "⠐", "⠈"]
dec heavy = ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"]

dec args = args()

// --- checking weather reverse
//     option is provided or not
if args.arr_contains("-r")? {
  reversed = true
}

// --- checking if the option -s
//     is used correctly or not
//     then parses it
if args.arr_contains("-s")? {
  dec target_index = args.arr_index_of("-s")?
  if !(args[target_index] == args.arr_last()?) {
    if target_index + 1 < args.len()? {
      match args[target_index + 1] {
        "dots" => { style = 0 }
        "wave" => { style = 1 }
        "pulse" => { style = 2 }
        "fill" => { style = 3 }
        "bounce" => { style = 4 }
        "heavy" => { style = 5 }
        _ => {
          eprintln(format("Error:\t{} is not valid style\n\tvalid styles are dots | wave | pulse | fill | bounce | heavy", args[target_index + 1]))
          exit(1)
        }
      }
    } else {
      eprintln(format("Error:\t'-s' requires a style argument after it\n\tvalid styles are dots | wave | pulse | fill | bounce | heavy"))     
      exit(2)
    }
  } else {
    eprintln("Error:\tmissing style after '-s'\n\tvalid styles are dots | wave | pulse | fill | bounce | heavy")
    exit(3)
  }
}

match style {
  0 => { frames = dots }
  1 => { frames = wave }
  2 => { frames = pulse }
  3 => { frames = fill }
  4 => { frames = bounce }
  5 => { frames = heavy }
}

if reversed {
  frames = frames.arr_reverse()?
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
