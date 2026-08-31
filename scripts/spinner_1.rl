get term_flush from std::term
get sleep from std::process
get print, eprintln from std::io
get format from std::str
get args, exit from std::process
get arr_reverse, arr_contains, arr_last, arr_index_of, len from std::array
get to_int from std::types
get result_unwrap, is_err from std::res

// --- global variables
dec bool reversed = false
dec int style = 0
dec arr[string] frames = []
dec int count = -1

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
      eprintln("Error:\t'-s' requires a style argument after it\n\tvalid styles are dots | wave | pulse | fill | bounce | heavy")     
      exit(2)
    }
  } else {
    eprintln("Error:\tmissing style after '-s'\n\tvalid styles are dots | wave | pulse | fill | bounce | heavy")
    exit(3)
  }
}

// --- checking if the option -n
//     is used correctly or not
if args.arr_contains("-n")? {
  dec target_index = args.arr_index_of("-n")?
  if !(args[target_index] == args.arr_last()?) {
    if target_index + 1 < args.len()? {
        dec result[int] c = args[target_index + 1].to_int()
        if c.is_err() {
          eprintln("Error:\tcount argument expected an integer number")
          exit(1)
        } else {
          dec int c = c.result_unwrap()
          if c > 0 {
            count = c
          } else {
            eprintln("Error:\tcount should be positive integer number")
            exit(1)
          }
        }
    } else {
      eprintln(format("Error:\t'-n' requires a count argument after it"))     
      exit(2)
    }
  } else {
    eprintln("Error:\tmissing count after '-n'")
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
//     of dots/animations when not
//     given a count (-n)
if count != -1 {
  print("\e[?25l")
  while count > 0 {
    for frame in frames {
      print(format("\r{}", frame))
      term_flush()?
      sleep(100)
    }
    count -= 1
  }
  print("\e[?25h")
  print("\n")
} else {
  while true {
    for frame in frames {
      print(format("\r{}", frame))
      term_flush()?
      sleep(100)
    }
  }
}
