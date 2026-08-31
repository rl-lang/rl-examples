get term_flush from std::term
get sleep from std::process
get print, eprintln from std::io
get format, starts_with from std::str
get args, exit from std::process
get arr_reverse, arr_contains, arr_last, arr_index_of, len from std::array
get to_int from std::types
get result_unwrap, is_err from std::res
get mod from std::math

// --- global variables
dec bool reversed = false
dec int style = 0
dec arr[string] frames = []
dec int count = -1
dec string message = ""
dec string finish_message = ""
dec bool color_random = false
dec string frame_color = ""
dec string msg_color = ""
dec arr[string] rainbow = ["31", "32", "33", "34", "35", "36"]

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
  print("\e[1mspinner\e[0m - a terminal spinner for long-running tasks\n")
  print("\n")
  print("displays an animated loading indicator until manually stopped\n")
  print("or until a cycle count is reached.\n")
  print("\n")
  print("\e[36musage:\e[0m spinner [options]\n")
  print("\n")
  print("\e[36moptions:\e[0m\n")
  print("  \e[33m-s\e[0m \e[1m<style>\e[0m   animation style (dots | wave | pulse | fill | bounce | heavy)\n")
  print("  \e[33m-r\e[0m           reverse the animation\n")
  print("  \e[33m-n\e[0m \e[1m<count>\e[0m   run for N cycles, then stop\n")
  print("  \e[33m-m\e[0m \e[1m<text>\e[0m    text to display next to the spinner\n")
  print("  \e[33m-M\e[0m \e[1m<text>\e[0m    text to display after spinner finishes\n")
  print("  \e[33m-C\e[0m \e[1m[colors]\e[0m color mode (see below)\n")
  print("  \e[33m-h\e[0m           show this help message\n")
  print("\n")
  print("\e[36mcolor modes:\e[0m\n")
  print("  \e[33m-C\e[0m              random color per frame\n")
  print("  \e[33m-C\e[0m \e[1m<color>\e[0m      single color for frames\n")
  print("  \e[33m-C\e[0m \e[1m<f> <m>\e[0m      color for frames and messages\n")
  print("  \e[33m-C\e[0m \e[1mrandom <m>\e[0m  random frames with colored messages\n")
  print("\n")
  print("\e[36mcolors:\e[0m random | black red green yellow blue magenta cyan white\n")
  print("\n")
  print("\e[36mexamples:\e[0m\n")
  print("  spinner -s wave -m \"Loading...\"\n")
  print("  spinner -s pulse -n 50 -M \"Done!\"\n")
  print("  spinner -C red -m \"Working...\"\n")
  print("  spinner -C cyan magenta -m \"Building...\" -M \"Build complete\"\n")
  print("  spinner -C random cyan -m \"Compiling...\"\n")
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
          eprintln(format("\e[31merror:\e[0m '{}' is not a valid style\n  valid styles: dots | wave | pulse | fill | bounce | heavy", args[target_index + 1]))
          exit(4)
        }
      }
    } else {
      eprintln("\e[31merror:\e[0m '-s' requires a style argument\n  valid styles: dots | wave | pulse | fill | bounce | heavy")
      exit(3)
    }
  } else {
    eprintln("\e[31merror:\e[0m missing style after '-s'\n  valid styles: dots | wave | pulse | fill | bounce | heavy")
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
          eprintln(format("\e[31merror:\e[0m '-n' expected an integer, got '{}'", args[target_index + 1]))
          exit(4)
        } else {
          dec int c = c.result_unwrap()
          if c > 0 {
            count = c
          } else {
            eprintln(format("\e[31merror:\e[0m '-n' must be a positive integer, got {}", c))
            exit(4)
          }
        }
    } else {
      eprintln("\e[31merror:\e[0m '-n' requires a count argument after it")
      exit(3)
    }
  } else {
    eprintln("\e[31merror:\e[0m missing count after '-n'")
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
      eprintln("\e[31merror:\e[0m '-m' requires a message argument after it")
      exit(3)
    }
  } else {
    eprintln("\e[31merror:\e[0m missing message after '-m'")
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
      eprintln("\e[31merror:\e[0m '-M' requires a finish message argument after it")
      exit(3)
    }
  } else {
    eprintln("\e[31merror:\e[0m missing finish message after '-M'")
    exit(3)
  }
}

// --- checking if the option -C
//     is used correctly or not
//     0 args: random color per frame
//     1 arg:  color for frames only
//     2 args: color for frames and messages
if args.arr_contains("-C")? {
  dec target_index = args.arr_index_of("-C")?
  // -C is last arg → random mode
  if args[target_index] == args.arr_last()? {
    color_random = true
  } else {
    dec string first = args[target_index + 1]
    // next arg is a flag → random mode
    if first.starts_with("-") {
      color_random = true
    } else if target_index + 2 >= args.len()? or args[target_index + 2].starts_with("-") {
      // only 1 arg after -C → frame color only
      match first {
        "random" => { color_random = true }
        "black" => { frame_color = "30" }
        "red" => { frame_color = "31" }
        "green" => { frame_color = "32" }
        "yellow" => { frame_color = "33" }
        "blue" => { frame_color = "34" }
        "magenta" => { frame_color = "35" }
        "cyan" => { frame_color = "36" }
        "white" => { frame_color = "37" }
        _ => {
          eprintln(format("\e[31merror:\e[0m '{}' is not a valid color\n  valid colors: random | black | red | green | yellow | blue | magenta | cyan | white", first))
          exit(4)
        }
      }
    } else {
      // 2 args after -C → frame + message color
      dec string second = args[target_index + 2]
      match first {
        "random" => { color_random = true }
        "black" => { frame_color = "30" }
        "red" => { frame_color = "31" }
        "green" => { frame_color = "32" }
        "yellow" => { frame_color = "33" }
        "blue" => { frame_color = "34" }
        "magenta" => { frame_color = "35" }
        "cyan" => { frame_color = "36" }
        "white" => { frame_color = "37" }
        _ => {
          eprintln(format("\e[31merror:\e[0m '{}' is not a valid color for frames\n  valid colors: random | black | red | green | yellow | blue | magenta | cyan | white", first))
          exit(4)
        }
      }
      match second {
        "black" => { msg_color = "30" }
        "red" => { msg_color = "31" }
        "green" => { msg_color = "32" }
        "yellow" => { msg_color = "33" }
        "blue" => { msg_color = "34" }
        "magenta" => { msg_color = "35" }
        "cyan" => { msg_color = "36" }
        "white" => { msg_color = "37" }
        _ => {
          eprintln(format("\e[31merror:\e[0m '{}' is not a valid color for messages\n  valid colors: black | red | green | yellow | blue | magenta | cyan | white", second))
          exit(4)
        }
      }
    }
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
  dec int ci = 0
  while count > 0 {
    for frame in frames {
      dec string fc = frame_color
      if color_random {
        fc = rainbow[mod(ci, rainbow.len()?)?]
        ci += 1
      }
      if fc != "" {
        print(format("\r\e[{}m{}\e[0m", fc, frame))
      } else {
        print(format("\r{}", frame))
      }
      if message != "" {
        if msg_color != "" {
          print(format(" \e[{}m{}\e[0m", msg_color, message))
        } else {
          print(format(" {}", message))
        }
      }
      term_flush()?
      sleep(100)
    }
    count -= 1
  }
  print("\e[?25h")
  print("\e[2K\r")
  if msg_color != "" and finish_message != "" {
    print(format("\e[{}m{}\e[0m\n", msg_color, finish_message))
  } else if finish_message != "" {
    print(format("{}\n", finish_message))
  } else {
    print("\n")
  }
} else {
  dec int ci = 0
  while true {
    for frame in frames {
      dec string fc = frame_color
      if color_random {
        fc = rainbow[mod(ci, rainbow.len()?)?]
        ci += 1
      }
      if fc != "" {
        print(format("\r\e[{}m{}\e[0m", fc, frame))
      } else {
        print(format("\r{}", frame))
      }
      if message != "" {
        if msg_color != "" {
          print(format(" \e[{}m{}\e[0m", msg_color, message))
        } else {
          print(format(" {}", message))
        }
      }
      term_flush()?
      sleep(100)
    }
  }
}
