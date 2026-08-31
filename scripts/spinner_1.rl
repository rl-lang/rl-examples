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
dec string message = ""
dec string finish_message = ""

// --- basic set of animations
dec dots = ["⠋", "⠙", "⠸", "⢰", "⣠", "⣄", "⡆", "⠇"]
dec wave = ["⠀", "⠄", "⠆", "⠇", "⠏", "⠗", "⠿", "⣿", "⣷", "⣶", "⣦", "⣤", "⣄", "⣀", "⠤", "⠐"]
dec pulse = ["⣀", "⣤", "⣶", "⣾", "⣿", "⣶", "⣤", "⣀"]
dec fill = ["⠀", "⡀", "⣀", "⣄", "⣤", "⣦", "⣴", "⣼", "⣶", "⣾", "⣿"]
dec bounce = ["⠁", "⠈", "⠐", "⠠", "⡀", "⢀", "⠠", "⠐", "⠈"]
dec heavy = ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"]

dec args = args()

// --- checking if -h is provided
//     then prints usage and exits
if args.arr_contains("-h")? {
  print("usage: spinner [options]\n")
  print("\n")
  print("options:\n")
  print("  -s <style>   animation style (dots | wave | pulse | fill | bounce | heavy)\n")
  print("  -r           reverse the animation\n")
  print("  -n <count>   run for N cycles, then stop\n")
  print("  -m <message> text to display next to the spinner\n")
  print("  -M <message> text to display after spinner finishes\n")
  print("  -C [colors]  color mode (see below)\n")
  print("  -h           show this help message\n")
  print("\n")
  print("color modes:\n")
  print("  -C              random color per frame\n")
  print("  -C <color>      single color for frames\n")
  print("  -C <f> <m>      color for frames and messages\n")
  print("\n")
  print("colors: black red green yellow blue magenta cyan white\n")
  exit(0)
}

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
          eprintln(format("error: '{}' is not a valid style\n  valid styles: dots | wave | pulse | fill | bounce | heavy", args[target_index + 1]))
          exit(4)
        }
      }
    } else {
      eprintln("error: '-s' requires a style argument\n  valid styles: dots | wave | pulse | fill | bounce | heavy")
      exit(3)
    }
  } else {
    eprintln("error: missing style after '-s'\n  valid styles: dots | wave | pulse | fill | bounce | heavy")
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
          eprintln(format("error: '-n' expected an integer, got '{}'", args[target_index + 1]))
          exit(4)
        } else {
          dec int c = c.result_unwrap()
          if c > 0 {
            count = c
          } else {
            eprintln(format("error: '-n' must be a positive integer, got {}", c))
            exit(4)
          }
        }
    } else {
      eprintln("error: '-n' requires a count argument after it")
      exit(3)
    }
  } else {
    eprintln("error: missing count after '-n'")
    exit(3)
  }
}

// --- checking if the option -m
//     is used correctly or not
//     then parses it
if args.arr_contains("-m")? {
  dec target_index = args.arr_index_of("-m")?
  if !(args[target_index] == args.arr_last()?) {
    if target_index + 1 < args.len()? {
      message = args[target_index + 1]
    } else {
      eprintln("error: '-m' requires a message argument after it")
      exit(3)
    }
  } else {
    eprintln("error: missing message after '-m'")
    exit(3)
  }
}

// --- checking if the option -M
//     is used correctly or not
//     then parses it
if args.arr_contains("-M")? {
  dec target_index = args.arr_index_of("-M")?
  if !(args[target_index] == args.arr_last()?) {
    if target_index + 1 < args.len()? {
      finish_message = args[target_index + 1]
    } else {
      eprintln("error: '-M' requires a finish message argument after it")
      exit(3)
    }
  } else {
    eprintln("error: missing finish message after '-M'")
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
      print(format("\r{} {}", frame, message))
      term_flush()?
      sleep(100)
    }
    count -= 1
  }
  print("\e[?25h")
  print(format("\e[2K\r{}\n", finish_message))
} else {
  while true {
    for frame in frames {
      print(format("\r{} {}", frame, message))
      term_flush()?
      sleep(100)
    }
  }
}
