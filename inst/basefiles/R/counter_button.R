#' @export
counter_button <- function(id) {
  attach_pkg_deps(
    shiny::div(id = id, class = "example-counter-button-container")
  )
}

#' @export
update_counter_button <- function(id, value = 0.0, session = shiny::getDefaultReactiveDomain()) {
  session$sendInputMessage(id, list(value = value))
}
