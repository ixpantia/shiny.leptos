test_that("can extract package name", {
  expected_package_name <- "shiny.leptos"
  description_file <- "Package: shiny.leptos\nVersion: 0.1.0\n"

  expect_equal(
    extract_package_name(description_file),
    expected_package_name
  )

  description_file <- c("Package: shiny.leptos", "Version: 0.1.0")

  expect_equal(
    extract_package_name(description_file),
    expected_package_name
  )

})
