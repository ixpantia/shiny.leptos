# File: R/generic_input_init.R
#' Create scaffolding for a new Leptos input component
#'
#' This function creates the necessary R, Rust, and TypeScript files
#' for a new input component based on a generic template.
#'
#' @param component_name The name for the new component (e.g., "my_slider").
#'   This will be converted to snake_case and CamelCase where needed.
#' @param path Path to the root of the R package. Default is the current directory.
#' @importFrom cli cli_process_start cli_process_done cli_process_failed cli_alert_success cli_alert_danger cli_alert_info cli_h1 cli_h2 symbol
#' @importFrom glue glue
#' @importFrom snakecase to_upper_camel_case to_snake_case
#' @export
new_input_component <- function(component_name, path = ".") {
  component_name_camel <- snakecase::to_upper_camel_case(component_name)
  component_name_snake <- snakecase::to_snake_case(component_name)

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

  cli::cli_h1(
    "Creating new input component '{component_name_snake}' in package '{package_name}'"
  )

  # --- TypeScript File ---
  cli::cli_h2("TypeScript Setup (srcts)")
  generic_input_ts_path <- system.file(
    file.path("generic_input", "generic_input.ts"),
    package = PACKAGE
  )
  generic_input_ts_path_out <- file.path(
    path,
    "srcts",
    "src",
    paste0(component_name_snake, ".ts")
  )

  cli::cli_process_start(
    "Generating TypeScript file {basename(generic_input_ts_path_out)}...",
    msg_done = "TypeScript file created: {basename(generic_input_ts_path_out)}",
    msg_failed = "Failed to create TypeScript file."
  )
  ts_write_ok <- tryCatch(
    {
      generic_input_ts <- readLines(generic_input_ts_path, warn = FALSE)
      generic_input_ts <- apply_name(generic_input_ts, package_name)
      generic_input_ts <- apply_name(
        generic_input_ts,
        component_name_camel,
        "@@component_name_camel@@"
      )
      generic_input_ts <- apply_name(
        generic_input_ts,
        component_name_snake,
        "@@component_name_snake@@"
      )
      writeLines(generic_input_ts, generic_input_ts_path_out)
      cli::cli_process_done()
      TRUE
    },
    error = function(e) {
      cli::cli_process_failed(msg = glue::glue("Error: {e$message}"))
      FALSE
    }
  )
  if (!ts_write_ok) return(invisible(FALSE))

  # Modify index.ts
  index_ts_path <- file.path(path, "srcts", "src", "index.ts")
  import_line_ts <- paste0('import "./', component_name_snake, '";')
  cli::cli_process_start(
    "Adding import to srcts/src/index.ts...",
    msg_done = "Import added to index.ts.",
    msg_failed = "Failed to modify index.ts."
  )
  ts_modify_ok <- tryCatch(
    {
      if (!file.exists(index_ts_path)) stop("srcts/src/index.ts not found.")
      index_ts <- readLines(index_ts_path, warn = FALSE)
      if (any(grepl(import_line_ts, index_ts, fixed = TRUE))) {
        cli::cli_alert_info("Import already exists in index.ts.")
        cli::cli_process_done() # Consider it done if already present
      } else {
        index_ts <- c(import_line_ts, index_ts)
        writeLines(index_ts, index_ts_path)
        cli::cli_process_done()
      }
      TRUE
    },
    error = function(e) {
      cli::cli_process_failed(
        msg = glue::glue("Error modifying index.ts: {e$message}")
      )
      FALSE
    }
  )
  if (!ts_modify_ok) return(invisible(FALSE))

  # --- Rust File ---
  cli::cli_h2("Rust Setup (srcrs)")
  generic_input_rs_path <- system.file(
    file.path("generic_input", "generic_input.rs"),
    package = PACKAGE
  )
  generic_input_rs_path_out <- file.path(
    path,
    "srcrs",
    "src",
    paste0(component_name_snake, ".rs")
  )

  cli::cli_process_start(
    "Generating Rust file {basename(generic_input_rs_path_out)}...",
    msg_done = "Rust file created: {basename(generic_input_rs_path_out)}",
    msg_failed = "Failed to create Rust file."
  )
  rs_write_ok <- tryCatch(
    {
      generic_input_rs <- readLines(generic_input_rs_path, warn = FALSE)
      generic_input_rs <- apply_name(generic_input_rs, package_name)
      generic_input_rs <- apply_name(
        generic_input_rs,
        component_name_camel,
        "@@component_name_camel@@"
      )
      generic_input_rs <- apply_name(
        generic_input_rs,
        component_name_snake,
        "@@component_name_snake@@"
      )
      writeLines(generic_input_rs, generic_input_rs_path_out)
      cli::cli_process_done()
      TRUE
    },
    error = function(e) {
      cli::cli_process_failed(msg = glue::glue("Error: {e$message}"))
      FALSE
    }
  )
  if (!rs_write_ok) return(invisible(FALSE))

  # Modify lib.rs
  lib_rs_path <- file.path(path, "srcrs", "src", "lib.rs")
  mod_line_rs <- paste0("pub mod ", component_name_snake, ";")
  cli::cli_process_start(
    "Adding module declaration to srcrs/src/lib.rs...",
    msg_done = "Module declaration added to lib.rs.",
    msg_failed = "Failed to modify lib.rs."
  )
  rs_modify_ok <- tryCatch(
    {
      if (!file.exists(lib_rs_path)) stop("srcrs/src/lib.rs not found.")
      lib_rs <- readLines(lib_rs_path, warn = FALSE)
      if (any(grepl(mod_line_rs, lib_rs, fixed = TRUE))) {
        cli::cli_alert_info("Module declaration already exists in lib.rs.")
        cli::cli_process_done() # Consider it done if already present
      } else {
        lib_rs <- c(mod_line_rs, lib_rs)
        writeLines(lib_rs, lib_rs_path)
        cli::cli_process_done()
      }
      TRUE
    },
    error = function(e) {
      cli::cli_process_failed(
        msg = glue::glue("Error modifying lib.rs: {e$message}")
      )
      FALSE
    }
  )
  if (!rs_modify_ok) return(invisible(FALSE))

  # --- R File ---
  cli::cli_h2("R Setup")
  r_dir_path <- file.path(path, "R")
  cli::cli_process_start(
    "Ensuring R directory exists...",
    msg_done = "R directory exists.",
    msg_failed = "Failed to ensure R directory exists."
  )
  tryCatch(
    {
      dir.create(r_dir_path, showWarnings = FALSE)
      cli::cli_process_done()
      TRUE
    },
    error = function(e) {
      cli::cli_process_failed(msg = glue::glue("Error: {e$message}"))
      FALSE
    }
  ) -> r_dir_ok
  if (!r_dir_ok) return(invisible(FALSE))

  generic_input_r_path <- system.file(
    file.path("generic_input", "generic_input.R"),
    package = PACKAGE
  )
  generic_input_r_path_out <- file.path(
    r_dir_path,
    paste0(component_name_snake, ".R")
  )

  cli::cli_process_start(
    "Generating R file {basename(generic_input_r_path_out)}...",
    msg_done = "R file created: {basename(generic_input_r_path_out)}",
    msg_failed = "Failed to create R file."
  )
  r_write_ok <- tryCatch(
    {
      generic_input_r <- readLines(generic_input_r_path, warn = FALSE)
      generic_input_r <- apply_name(generic_input_r, package_name)
      generic_input_r <- apply_name(
        generic_input_r,
        component_name_camel,
        "@@component_name_camel@@"
      )
      generic_input_r <- apply_name(
        generic_input_r,
        component_name_snake,
        "@@component_name_snake@@"
      )
      writeLines(generic_input_r, generic_input_r_path_out)
      cli::cli_process_done()
      TRUE
    },
    error = function(e) {
      cli::cli_process_failed(msg = glue::glue("Error: {e$message}"))
      FALSE
    }
  )
  if (!r_write_ok) return(invisible(FALSE))

  cli::cli_alert_success(
    "Successfully created component scaffolding for '{component_name_snake}'."
  )
  cli::cli_alert_info("Next steps:")
  cli::cli_ul()
  cli::cli_li(
    "Implement the component logic in '{basename(generic_input_rs_path_out)}' (Rust/Leptos)."
  )
  cli::cli_li(
    "Adjust the TypeScript bindings in '{basename(generic_input_ts_path_out)}' if necessary."
  )
  cli::cli_li(
    "Customize the R functions in '{basename(generic_input_r_path_out)}'."
  )
  cli::cli_li(
    "Run `devtools::document()` to generate documentation and update NAMESPACE."
  )
  cli::cli_li("Run `shiny.leptos::build()` to compile everything.")
  cli::cli_end()

  invisible(TRUE)
}
