#!/home/crimson/.local/bin/rl run


get * from std::io
get * from std::cli
get * from std::process
get * from std::res
get * from std::collections
get * from std::types
get * from std::crypto
get * from std::str
get * from std::fs

CONST string GAME_NAME = "Mindustry.jar"
CONST string SHA_NAME = "Mindustry.jar.SHA256"
CONST string LOCATION = "/home/crimson/games/mindustry"

// Args
dec spec = [

    // which to start?
    {
        "name": "game-version",
        "short": "g",
        "default": "160.5"
    },

    {
        "name": "help",
        "short": "h",
        "flag": "true"
    },

    {
        "name": "skip-sha",
        "short": "s",
        "flag": "true"
    },
]

// initialize the argument reader
// default config used when wrong flags are used
dec map[string, string] default_config = { "help": "true" }
dec rargs = spec.parse_args()
dec map[string, string] args = {}
dec parse_args_err = ""
if rargs.is_err()
{
    parse_args_err = rargs.result_unwrap_err()
    args = default_config
}
else
{
    args = rargs?
}

// debug print for the arguments and flags passed
// println(args)
// print help and exit
if args.map_get("help").result_unwrap_or("false").to_bool().result_unwrap_or(false)
{
    println(spec.usage_string().result_unwrap())
    if !parse_args_err.is_empty()
    {
        eprintln(
            "\e[1;31m[Error] \e[0;31m",
            parse_args_err
        )
        exit(2)
    }
    exit(0)
}

// extract args values
dec game_ver = args.map_get("game-version").result_unwrap_or("160.5")
dec game_folder = game_ver.replace(".", "_")
dec skip_sha = args.map_get("skip-sha-check").result_unwrap_or("false").to_bool().result_unwrap()

fn start_game(string f)
{
    println("\e[32m[INFO] Starting Mindustry!")
    dec e = exec_fg(format(
        "java -jar {}/{}/{} 2>&1 > /home/crimson/games/mindustry/log & disown",
        LOCATION,
        f,
        GAME_NAME
    ))
    println("\e[32m[INFO] Log file at [/home/crimson/games/mindustry/log]")
    if e.is_err()
    {
        eprintln(format(
            "\e[31m[Error] Failed to start Mindustry.java: {}",
            e.result_unwrap_err()
        ))
        exit(3)
    }
    println("\e[32m[INFO] Don't close this terminal! Mindustry running in background")
}

/* debug print for the folder of selected version
println(game_folder) */
if path_exists(format("{}/{}", LOCATION, game_folder))
{
    if path_exists(format(
        "{}/{}/{}",
        LOCATION,
        game_folder,
        GAME_NAME
    ))
    and path_exists(format(
        "{}/{}/{}",
        LOCATION,
        game_folder,
        SHA_NAME
    ))
    {
        if !skip_sha
        {
            dec game_bytes = read_bytes(format(
                "{}/{}/{}",
                LOCATION,
                game_folder,
                GAME_NAME
            )).result_unwrap_or([0 as byte])
            dec game_sha = sha256(game_bytes).hex_encode()
            dec correct_sha = read_file(format(
                "{}/{}/{}",
                LOCATION,
                game_folder,
                SHA_NAME
            )).result_unwrap_or("_").split_once(" ").result_unwrap_or(["_"])
            if game_sha == correct_sha[0]
            {
                println("\e[32m[INFO] SHA256 Check Passed!")
            }
            else
            {

                eprintln("\e[1;31m[CRITICAL] SHA256 Check Failed!")
            }
        }
        else
        {
            println("\e[35m[INFO] Skipping SHA256 Check!")
        }
        start_game(game_folder)
    }
    else if path_exists(format(
        "{}/{}/{}",
        LOCATION,
        game_folder,
        GAME_NAME
    ))
    {
        if !skip_sha
        {
            eprintln("\e[33m[Warning] SHA256 was not found")
        }
        start_game(game_folder)
    }
    else
    {
        eprintln("\e[31m[Error] Mindustry.java was not found")
        exit(1)
    }
}
else
{
    eprintln("\e[31m[Error] Game Directory not found")
}

