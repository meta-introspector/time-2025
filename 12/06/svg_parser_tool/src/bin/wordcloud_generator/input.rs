use std::path::PathBuf;
use pico_args::Arguments;

pub fn get_args() -> Result<(PathBuf, String), pico_args::Error> {
    let mut args = Arguments::from_env();

    if args.contains(["-h", "--help"]) {
        print_help();
        std::process::exit(0);
    }

    let db_type: String = args.opt_value_from_str("--db-type")?.unwrap_or("rocksdb".to_string());
    let root_path_str: String = args.free_from_str().unwrap_or_else(|_| ".".to_string());
    let root_path = PathBuf::from(root_path_str);

    Ok((root_path, db_type))
}

fn print_help() {
    println!(
        r#"wordcloud_generator
Usage: wordcloud_generator [PATH] [OPTIONS]

Arguments:
  [PATH]    The root directory to start collecting files from. Defaults to current directory.

Options:
  --db-type <DB_TYPE>    The database type to use for caching. Can be 'rocksdb', 'redb', or 'sled'. Defaults to 'rocksdb'.
  -h, --help             Print help information
"#
    );
}
