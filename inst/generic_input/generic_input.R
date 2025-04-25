#' @export
@@component_name_snake@@ <- function(inputId, value = 0.0) {
  attach_pkg_deps(
    shiny::div(
      id = inputId,
      class = "@@package_name@@-@@component_name_snake@@-container",
      `data-initial-value` = value
    )
  )
}

#' @export
update_@@component_name_snake@@ <- function(
  inputId,
  value = 0.0,
  session = shiny::getDefaultReactiveDomain()
) {
  session$sendInputMessage(inputId, list(value = value))
}
