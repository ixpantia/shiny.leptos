get_pkg_version <- function() {
  utils::packageDescription("@@package_name@@")$Version
}

attach_pkg_deps <- function(...) {
  package_version <- get_pkg_version()

  dep <- htmltools::htmlDependency(
    src = "dist",
    script = list(src = "@@package_name@@.js", type = "module"),
    stylesheet = list(src = "style.css"),
    version = "1.0",
    package = "@@package_name@@",
    name = "@@package_name@@"
  )

  htmltools::tagList(...) |>
    htmltools::attachDependencies(dep, append = TRUE)
}
