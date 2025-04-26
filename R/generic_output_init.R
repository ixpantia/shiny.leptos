#' @rdname generic_component_init
#' @importFrom cli cli_process_start cli_process_done cli_process_failed cli_alert_success cli_alert_danger cli_alert_info cli_h1 cli_h2 symbol
#' @importFrom glue glue
#' @importFrom snakecase to_upper_camel_case to_snake_case
#' @export
new_output_component <- function(component_name, path = ".") {
  initial_component_name <- component_name
  component_name <- gsub("_output$", "", component_name)
  component_name <- gsub("_Output$", "", component_name)
  component_name <- gsub("Output$", "", component_name)
  if (component_name != initial_component_name) {
    cli::cli_alert_info(
      "The component name was modified to remove the '_output' suffix."
    )
  }
  copy_generic(
    component_name = component_name,
    path = path,
    r_file = file.path("generic_output", "generic_output.R"),
    rs_file = file.path("generic_output", "generic_output.rs"),
    ts_file = file.path("generic_output", "generic_output.ts")
  )
}
