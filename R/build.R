# File: R/build.R
#'
#' Build Sass assets for the package
#'
#' @param package_name Name of the package (used to locate inst and out directories)
#' @param dir Directory containing Sass sources. Default: "srcsass"
#' @param path Path to the package root. Default: "."
#' @export
build_sass <- function(
  package_name = get_pkg_name(path),
  dir = "srcsass",
  path = "."
) {
  target_dir <- file.path(path, dir)
  if (!dir.exists(target_dir)) {
    cli::cli_alert_warning(
      "Sass source directory '{target_dir}' not found. Skipping Sass build."
    )
    return(invisible(FALSE))
  }

  wd <- withr::local_dir(target_dir) # Change dir temporarily

  inst_dir <- file.path("..", "inst", package_name) # Relative to target_dir
  # Ensure inst/pkgname directory exists
  if (!dir.exists(inst_dir)) {
    dir.create(inst_dir, recursive = TRUE, showWarnings = FALSE)
  }

  output_css <- file.path(inst_dir, "style.css") # Relative to target_dir

  cmd <- "sass"
  args <- c("main.scss", output_css)

  cli::cli_process_start(
    "Building Sass assets: {dir}/main.scss -> inst/{package_name}/style.css",
    msg_done = "Sass build successful.",
    msg_failed = "Sass build failed."
  )

  tryCatch(
    {
      # Use processx::run for better control and output capture
      res <- processx::run(
        cmd,
        args,
        error_on_status = FALSE,
        echo_cmd = TRUE,
        echo = TRUE
      ) # Show command and output
      if (res$status == 0) {
        cli::cli_process_done()
        invisible(TRUE)
      } else {
        cli::cli_process_failed(
          msg = glue::glue(
            "Sass build failed (exit code: {res$status}).\nStderr:\n{res$stderr}"
          )
        )
        invisible(FALSE)
      }
    },
    error = function(e) {
      # This catches errors like 'command not found'
      cli::cli_process_failed(
        msg = glue::glue("Failed to run sass command: {e$message}")
      )
      cli::cli_alert_info(
        "Ensure 'sass' is installed and in your system's PATH."
      )
      invisible(FALSE)
    }
  )
}

#' Build Rust WASM package
#'
#' @param package_name Name of the package (used to name output directory)
#' @param dir Directory containing Rust sources. Default: "srcrs"
#' @param path Path to the package root. Default: "."
#' @importFrom cli cli_process_start cli_process_done cli_process_failed cli_alert_success cli_alert_danger cli_alert_info cli_h1 symbol
#' @importFrom glue glue
#' @importFrom withr with_dir local_dir
#' @importFrom processx run
#' @export
build_rs <- function(
  package_name = get_pkg_name(path),
  dir = "srcrs",
  path = "."
) {
  target_dir <- file.path(path, dir)
  if (!dir.exists(target_dir)) {
    cli::cli_alert_warning(
      "Rust source directory '{target_dir}' not found. Skipping Rust build."
    )
    return(invisible(FALSE))
  }

  wd <- withr::local_dir(target_dir) # Change dir temporarily

  out_dir <- file.path("..", "out", paste0(package_name, "-wasm")) # Relative to target_dir
  cmd <- "wasm-pack"
  args <- c("build", "--target", "bundler", "--out-dir", out_dir)

  cli::cli_process_start(
    "Building Rust WASM package with wasm-pack",
    msg_done = "Rust WASM build successful. Output: {out_dir}",
    msg_failed = "Rust WASM build failed."
  )

  tryCatch(
    {
      res <- processx::run(
        cmd,
        args,
        error_on_status = FALSE,
        echo_cmd = TRUE,
        echo = TRUE
      )
      if (res$status == 0) {
        cli::cli_process_done()
        invisible(TRUE)
      } else {
        cli::cli_process_failed(
          msg = glue::glue(
            "wasm-pack build failed (exit code: {res$status}).\nStderr:\n{res$stderr}"
          )
        )
        invisible(FALSE)
      }
    },
    error = function(e) {
      cli::cli_process_failed(
        msg = glue::glue("Failed to run wasm-pack command: {e$message}")
      )
      cli::cli_alert_info(
        "Ensure 'wasm-pack' is installed and in your system's PATH."
      )
      invisible(FALSE)
    }
  )
}

#' Build TypeScript assets (depends on Rust WASM)
#'
#' @param package_name Name of the package (used to upgrade WASM dependency)
#' @param dir Directory containing TypeScript sources. Default: "srcts"
#' @param path Path to the package root. Default: "."
#' @importFrom cli cli_process_start cli_process_done cli_process_failed cli_alert_success cli_alert_danger cli_alert_info cli_h1 symbol
#' @importFrom glue glue
#' @importFrom withr with_dir local_dir
#' @importFrom processx run
#' @export
build_ts <- function(
  package_name = get_pkg_name(path),
  dir = "srcts",
  path = "."
) {
  target_dir <- file.path(path, dir)
  if (!dir.exists(target_dir)) {
    cli::cli_alert_warning(
      "TypeScript source directory '{target_dir}' not found. Skipping TypeScript build."
    )
    return(invisible(FALSE))
  }

  cli::cli_alert_info("Starting TypeScript build process in '{target_dir}'...")

  # Ensure Rust WASM is built first
  cli::cli_alert_info("Ensuring Rust WASM dependency is built...")
  rs_build_success <- build_rs(package_name = package_name, path = path)
  if (!isTRUE(rs_build_success)) {
    cli::cli_alert_danger(
      "Rust build failed or was skipped. Aborting TypeScript build."
    )
    return(invisible(FALSE))
  }

  wd <- withr::local_dir(target_dir) # Change dir temporarily

  # Yarn install
  cli::cli_process_start(
    "Running yarn install...",
    msg_done = "yarn install completed.",
    msg_failed = "yarn install failed."
  )
  yarn_install_ok <- tryCatch(
    {
      res <- processx::run(
        "yarn",
        "install",
        error_on_status = FALSE,
        echo_cmd = TRUE,
        echo = TRUE
      )
      if (res$status == 0) {
        cli::cli_process_done()
        TRUE
      } else {
        cli::cli_process_failed(
          msg = glue::glue(
            "yarn install failed (exit code: {res$status}).\nStderr:\n{res$stderr}"
          )
        )
        FALSE
      }
    },
    error = function(e) {
      cli::cli_process_failed(
        msg = glue::glue("Failed to run yarn install: {e$message}")
      )
      FALSE
    }
  )

  if (!yarn_install_ok) {
    cli::cli_alert_info("Ensure 'yarn' is installed and in your system's PATH.")
    return(invisible(FALSE))
  }

  # Yarn upgrade wasm package
  wasm_pkg_name <- paste0(package_name, "-wasm")
  cli::cli_process_start(
    "Running yarn upgrade {wasm_pkg_name}...",
    msg_done = "yarn upgrade {wasm_pkg_name} completed.",
    msg_failed = "yarn upgrade {wasm_pkg_name} failed."
  )
  yarn_upgrade_ok <- tryCatch(
    {
      res <- processx::run(
        "yarn",
        c("upgrade", wasm_pkg_name),
        error_on_status = FALSE,
        echo_cmd = TRUE,
        echo = TRUE
      )
      if (res$status == 0) {
        cli::cli_process_done()
        TRUE
      } else {
        cli::cli_process_failed(
          msg = glue::glue(
            "yarn upgrade failed (exit code: {res$status}).\nStderr:\n{res$stderr}"
          )
        )
        FALSE
      }
    },
    error = function(e) {
      cli::cli_process_failed(
        msg = glue::glue("Failed to run yarn upgrade: {e$message}")
      )
      FALSE
    }
  )

  if (!yarn_upgrade_ok) return(invisible(FALSE))

  # Vite build
  cli::cli_process_start(
    "Running vite build...",
    msg_done = "vite build completed.",
    msg_failed = "vite build failed."
  )
  vite_build_ok <- tryCatch(
    {
      res <- processx::run(
        "yarn",
        c("vite", "build"),
        error_on_status = FALSE,
        echo_cmd = TRUE,
        echo = TRUE
      )
      if (res$status == 0) {
        cli::cli_process_done()
        TRUE
      } else {
        cli::cli_process_failed(
          msg = glue::glue(
            "vite build failed (exit code: {res$status}).\nStderr:\n{res$stderr}"
          )
        )
        FALSE
      }
    },
    error = function(e) {
      cli::cli_process_failed(
        msg = glue::glue("Failed to run vite build: {e$message}")
      )
      FALSE
    }
  )

  if (!vite_build_ok) {
    cli::cli_alert_info(
      "Ensure 'vite' is installed (usually via yarn/npm) and runnable."
    )
    return(invisible(FALSE))
  }

  cli::cli_alert_success("TypeScript build process completed successfully.")
  invisible(TRUE)
}

#' Run all build tasks: Sass, Rust, and TypeScript
#'
#' @param package_name Name of the package. If NULL, attempts to detect from DESCRIPTION.
#' @param path Path to the package root. Default: "."
#' @importFrom cli cli_process_start cli_process_done cli_process_failed cli_alert_success cli_alert_danger cli_alert_info cli_h1 symbol
#' @importFrom glue glue
#' @export
build <- function(package_name = NULL, path = ".") {
  if (is.null(package_name)) {
    package_name <- tryCatch(
      {
        get_pkg_name(path)
      },
      error = function(e) {
        cli::cli_alert_danger(
          "Failed to automatically detect package name: {e$message}"
        )
        cli::cli_alert_info(
          "Please provide the 'package_name' argument or ensure a valid DESCRIPTION file exists at '{path}'."
        )
        return(NULL)
      }
    )
    if (is.null(package_name)) return(invisible(FALSE))
    cli::cli_alert_info("Detected package name: '{package_name}'")
  }

  cli::cli_h1("Starting full build process for '{package_name}'")

  sass_ok <- build_sass(package_name = package_name, path = path)
  # Note: build_ts implicitly calls build_rs
  ts_ok <- build_ts(package_name = package_name, path = path)

  if (isTRUE(sass_ok) && isTRUE(ts_ok)) {
    cli::cli_alert_success(
      "Full build process completed successfully for '{package_name}'."
    )
    invisible(TRUE)
  } else {
    cli::cli_alert_danger(
      "Full build process failed or had issues for '{package_name}'. Check messages above."
    )
    invisible(FALSE)
  }
}
