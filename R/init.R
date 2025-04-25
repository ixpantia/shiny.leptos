#' @title Get the name of the package from DESCRIPTION
#' @param path Path to the package directory. Default is the current working directory.
#' @return The name of the package as a string.
#' @importFrom cli cli_process_start cli_process_done cli_process_failed cli_alert_success cli_alert_danger cli_alert_info cli_h1 symbol
#' @importFrom glue glue
#' @export
get_pkg_name <- function(path = ".") {
  desc_path <- file.path(path, "DESCRIPTION")
  if (!file.exists(desc_path)) {
    stop("DESCRIPTION file not found at path: ", path)
  }
  extract_package_name(readLines(desc_path))
}

extract_package_name <- function(description_file) {
  # Split by lines if the input is a single string
  if (length(description_file) == 1L) {
    description_file <- strsplit(description_file, "\n")[[1]]
  }
  # Remove leading and trailing whitespace
  description_file <- trimws(description_file)
  # Find line that starts with "Package: "
  package_line <- grep("^Package: ", description_file, value = TRUE)
  if (length(package_line) == 0) {
    stop("Could not find 'Package:' line in DESCRIPTION content.")
  }
  # Extract the package name
  # Remove "Package: " from the line
  trimws(gsub("Package: ", "", package_line[1])) # Use only the first match
}

PACKAGE <- "shiny.leptos"

apply_name <- function(string, package_name, pattern = "@@package_name@@") {
  gsub(pattern, package_name, string)
}

#' @importFrom cli cli_process_start cli_process_done cli_process_failed cli_alert_success cli_alert_danger cli_alert_info cli_h1 symbol
#' @importFrom glue glue
copy_and_apply_package_name <- function(path_from, path_to, package_name) {
  cli::cli_process_start(
    "Copying template file from {basename(path_from)} to {path_to}",
    msg_done = "Copied template file to {path_to}",
    msg_failed = "Failed to copy template file to {path_to}"
  )

  tryCatch(
    {
      if (!file.exists(path_from)) {
        stop("Source file does not exist: ", path_from)
      }
      # Read the file
      file_content <- readLines(path_from, warn = FALSE)
      # Apply the package name
      new_content <- apply_name(file_content, package_name)
      # Ensure the target directory exists
      target_dir <- dirname(path_to)
      if (!dir.exists(target_dir)) {
        dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
        cli::cli_alert_info("Created directory {target_dir}")
      }
      # Write the new content to the file
      writeLines(new_content, path_to)
      cli::cli_process_done()
      invisible(TRUE)
    },
    error = function(e) {
      cli::cli_process_failed(msg = glue::glue("Error: {e$message}"))
      invisible(FALSE)
    }
  )
}

#' Initialize shiny.leptos structure in a package
#'
#' Sets up the necessary directories and template files for using
#' shiny.leptos in an R package.
#'
#' @param path Path to the root of the R package. Default is the current directory.
#' @importFrom cli cli_process_start cli_process_done cli_process_failed cli_alert_success cli_alert_danger cli_alert_info cli_h1 cli_h2 symbol
#' @importFrom glue glue
#' @export
init <- function(path = ".") {
  # Add ^srcts/, ^srcrs/, ^srcsass/, ^out/, ^target/ to .Rbuildignore
  build_ignore_path <- file.path(path, ".Rbuildignore")
  if (!file.exists(build_ignore_path)) {
    cli::cli_process_start(
      "Creating .Rbuildignore file",
      msg_done = "Created .Rbuildignore file",
      msg_failed = "Failed to create .Rbuildignore file"
    )
    tryCatch(
      {
        writeLines(
          c("^srcts/", "^srcrs/", "^srcsass/", "^out/", "^target/"),
          build_ignore_path
        )
        cli::cli_process_done()
      },
      error = function(e) {
        cli::cli_process_failed(msg = glue::glue("Error: {e$message}"))
      }
    )
  } else {
    cli::cli_process_start(
      ".Rbuildignore file already exists",
      msg_done = "Checked .Rbuildignore file",
      msg_failed = "Failed to check .Rbuildignore file"
    )
    tryCatch(
      {
        # Read the existing .Rbuildignore file
        build_ignore_content <- readLines(build_ignore_path, warn = FALSE)
        # Check if the lines are already present
        lines_to_add <- c(
          "^srcts/",
          "^srcrs/",
          "^srcsass/",
          "^out/",
          "^target/"
        )
        if (!all(lines_to_add %in% build_ignore_content)) {
          # Append the lines to the file
          writeLines(c(build_ignore_content, lines_to_add), build_ignore_path)
          cli::cli_alert_info("Added lines to .Rbuildignore")
        } else {
          cli::cli_alert_info("Lines already present in .Rbuildignore")
        }
      },
      error = function(e) {
        cli::cli_process_failed(msg = glue::glue("Error: {e$message}"))
      }
    )
    cli::cli_process_done()
  }

  # Extract package name from path/DESCRIPTION
  package_name <- tryCatch(
    {
      get_pkg_name(path)
    },
    error = function(e) {
      cli::cli_alert_danger("Failed to get package name: {e$message}")
      return(NULL)
    }
  )

  if (is.null(package_name)) return(invisible(NULL))

  cli::cli_h1("Initializing shiny.leptos structure for '{package_name}'")

  # --- TypeScript Setup ---
  cli::cli_h2("Setting up TypeScript (srcts)")
  ts_dir <- file.path(path, "srcts")
  ts_src_dir <- file.path(path, "srcts", "src")

  cli::cli_process_start(
    "Creating directory {ts_dir}",
    msg_done = "Directory {ts_dir} ensured.",
    msg_failed = "Failed to create {ts_dir}"
  )
  tryCatch(
    {
      dir.create(ts_dir, showWarnings = FALSE)
      cli::cli_process_done()
    },
    error = function(e) cli::cli_process_failed()
  )

  copy_and_apply_package_name(
    system.file(
      file.path("basefiles", "srcts", "vite.config.js"),
      package = PACKAGE
    ),
    file.path(path, "srcts", "vite.config.js"),
    package_name
  )

  copy_and_apply_package_name(
    system.file(
      file.path("basefiles", "srcts", "package.json"),
      package = PACKAGE
    ),
    file.path(path, "srcts", "package.json"),
    package_name
  )

  copy_and_apply_package_name(
    system.file(
      file.path("basefiles", "srcts", "tsconfig.json"),
      package = PACKAGE
    ),
    file.path(path, "srcts", "tsconfig.json"),
    package_name
  )

  cli::cli_process_start(
    "Creating directory {ts_src_dir}",
    msg_done = "Directory {ts_src_dir} ensured.",
    msg_failed = "Failed to create {ts_src_dir}"
  )
  tryCatch(
    {
      dir.create(ts_src_dir, showWarnings = FALSE)
      cli::cli_process_done()
    },
    error = function(e) cli::cli_process_failed()
  )

  copy_and_apply_package_name(
    system.file(
      file.path("basefiles", "srcts", "src", "index.ts"),
      package = PACKAGE
    ),
    file.path(path, "srcts", "src", "index.ts"),
    package_name
  )

  # --- Rust Setup ---
  cli::cli_h2("Setting up Rust (srcrs)")
  rs_dir <- file.path(path, "srcrs")
  rs_src_dir <- file.path(path, "srcrs", "src")

  copy_and_apply_package_name(
    system.file(file.path("basefiles", "Cargo.toml"), package = PACKAGE),
    file.path(path, "Cargo.toml"),
    package_name
  )

  cli::cli_process_start(
    "Creating directory {rs_dir}",
    msg_done = "Directory {rs_dir} ensured.",
    msg_failed = "Failed to create {rs_dir}"
  )
  tryCatch(
    {
      dir.create(rs_dir, showWarnings = FALSE)
      cli::cli_process_done()
    },
    error = function(e) cli::cli_process_failed()
  )

  copy_and_apply_package_name(
    system.file(
      file.path("basefiles", "srcrs", "Cargo.toml"),
      package = PACKAGE
    ),
    file.path(path, "srcrs", "Cargo.toml"),
    package_name
  )

  cli::cli_process_start(
    "Creating directory {rs_src_dir}",
    msg_done = "Directory {rs_src_dir} ensured.",
    msg_failed = "Failed to create {rs_src_dir}"
  )
  tryCatch(
    {
      dir.create(rs_src_dir, showWarnings = FALSE)
      cli::cli_process_done()
    },
    error = function(e) cli::cli_process_failed()
  )

  copy_and_apply_package_name(
    system.file(
      file.path("basefiles", "srcrs", "src", "lib.rs"),
      package = PACKAGE
    ),
    file.path(path, "srcrs", "src", "lib.rs"),
    package_name
  )

  # --- Sass Setup ---
  cli::cli_h2("Setting up Sass (srcsass)")
  sass_dir <- file.path(path, "srcsass")
  cli::cli_process_start(
    "Creating directory {sass_dir}",
    msg_done = "Directory {sass_dir} ensured.",
    msg_failed = "Failed to create {sass_dir}"
  )
  tryCatch(
    {
      dir.create(sass_dir, showWarnings = FALSE)
      cli::cli_process_done()
    },
    error = function(e) cli::cli_process_failed()
  )

  copy_and_apply_package_name(
    system.file(
      file.path("basefiles", "srcsass", "main.scss"),
      package = PACKAGE
    ),
    file.path(path, "srcsass", "main.scss"),
    package_name
  )

  copy_and_apply_package_name(
    system.file(
      file.path("basefiles", "srcsass", "variables.scss"),
      package = PACKAGE
    ),
    file.path(path, "srcsass", "variables.scss"),
    package_name
  )

  # --- R Setup ---
  cli::cli_h2("Setting up R helpers")
  r_dir <- file.path(path, "R")
  cli::cli_process_start(
    "Creating directory {r_dir}",
    msg_done = "Directory {r_dir} ensured.",
    msg_failed = "Failed to create {r_dir}"
  )
  tryCatch(
    {
      dir.create(r_dir, showWarnings = FALSE)
      cli::cli_process_done()
    },
    error = function(e) cli::cli_process_failed()
  )

  copy_and_apply_package_name(
    system.file(file.path("basefiles", "R", "deps.R"), package = PACKAGE),
    file.path(path, "R", "attach_dependencies.R"),
    package_name
  )

  cli::cli_alert_success(
    "shiny.leptos initialization complete for '{package_name}'!"
  )
  cli::cli_alert_info("Next steps:")
  cli::cli_ul()
  cli::cli_li(
    "Run `shiny.leptos::build()` in the terminal at '{path}' to build assets."
  )
  cli::cli_li("Start creating components using `new_input_component()`.")
  cli::cli_end()

  invisible(NULL)
}
