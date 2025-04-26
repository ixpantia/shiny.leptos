#' @title Create scaffolding for a new Leptos Component
#' @description
#' This function creates the necessary R, Rust, and TypeScript files
#' for a new input or output component based on a generic template.
#'
#' @param component_name The name for the new component (e.g., "my_slider").
#'   This will be converted to snake_case and CamelCase where needed.
#' @param path Path to the root of the R package. Default is the current directory.
#' @name generic_component_init
#' @importFrom cli cli_process_start cli_process_done cli_process_failed cli_alert_success cli_alert_danger cli_alert_info cli_h1 cli_h2 symbol
#' @importFrom glue glue
#' @importFrom snakecase to_upper_camel_case to_snake_case
#' @export
new_input_component <- function(component_name, path = ".") {
  copy_generic(
    component_name = component_name,
    path = path,
    r_file = file.path("generic_input", "generic_input.R"),
    rs_file = file.path("generic_input", "generic_input.rs"),
    ts_file = file.path("generic_input", "generic_input.ts")
  )
}
