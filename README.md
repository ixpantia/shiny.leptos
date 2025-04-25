# shiny.leptos

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- TODO: Add CI build status badge -->
[![R-CMD-check](https://github.com/ixpantia/shiny.leptos/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ixpantia/shiny.leptos/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**Create Custom Shiny Inputs with Rust, Leptos, and WebAssembly**

`shiny.leptos` provides a framework and tooling within R to build custom Shiny input components using the [Leptos](https://leptos.dev/) Rust framework, compiling them to WebAssembly (WASM) for high-performance, interactive front-end elements within your Shiny applications.

This package helps you:

1.  **Initialize:** Set up the necessary directory structure (`srcrs`, `srcts`, `srcsass`) and configuration files (Cargo.toml, package.json, vite.config.js, etc.) for Rust/Leptos and TypeScript development within your R package.
2.  **Scaffold:** Generate template files (Rust, TypeScript, R) for new custom input components.
3.  **Build:** Compile your Rust/Leptos code to WASM, bundle TypeScript bindings using Vite, and compile Sass/SCSS stylesheets into a single CSS file, placing the outputs in the correct `inst/` subdirectory for your R package.

## Installation

You can install the development version of `shiny.leptos` from [GitHub](https://github.com/ixpantia/shiny.leptos) with:

```r
# install.packages("remotes")
remotes::install_github("ixpantia/shiny.leptos")
```

**Prerequisites for Development:**

To *create* components using `shiny.leptos` within your own R package, you will need the following installed on your system:

1.  **Rust Toolchain:** Install via [rustup](https://rustup.rs/).
2.  **WASM Target for Rust:** `rustup target add wasm32-unknown-unknown`
3.  **`wasm-pack`:** `cargo install wasm-pack`
4.  **Node.js and Yarn:** Install Node.js (which includes npm) from [nodejs.org](https://nodejs.org/), then install Yarn: `npm install -g yarn`
5.  **Sass:** Install the Dart Sass executable (see [sass-lang.com/install](https://sass-lang.com/install)). Ensure the `sass` command is available in your system's PATH.

## Core Workflow

1.  **Initialize your Package:**
    Navigate to the root directory of your R package in the terminal or R console and run:
    ```r
    shiny.leptos::init()
    ```
    This sets up the `srcrs/`, `srcts/`, `srcsass/`, `out/` directories and necessary config files. It also adds these directories to your `.Rbuildignore`.

2.  **Create a New Input Component:**
    Use the `new_input_component()` function to generate the basic files for your component. For example, to create a component named `my_counter`:
    ```r
    shiny.leptos::new_input_component("my_counter")
    ```
    This will create:
    *   `R/my_counter.R`: R functions for the UI (`my_counter()`) and server-side updates (`update_my_counter()`).
    *   `srcrs/src/my_counter.rs`: Rust/Leptos code defining the component's logic and view.
    *   `srcts/src/my_counter.ts`: TypeScript bindings to interact with the WASM component from Shiny's JavaScript side.
    *   It will also update `srcrs/src/lib.rs` and `srcts/src/index.ts` to include the new component.

3.  **Implement Your Component:**
    *   Edit `srcrs/src/my_counter.rs` to implement the desired appearance and behavior using Leptos.
    *   Modify `srcts/src/my_counter.ts` if the default Shiny input binding needs adjustments for your component's specific data or events.
    *   Customize `R/my_counter.R` to set appropriate default values or add specific arguments to the R functions.
    *   Optionally, add styles for your component in `srcsass/` (e.g., create `_my_counter.scss` and import it in `main.scss`).

4.  **Build Assets:**
    From the root of your package, run the build command:
    ```r
    shiny.leptos::build()
    # Or run individual steps:
    # shiny.leptos::build_sass()
    # shiny.leptos::build_rs() # Called by build_ts
    # shiny.leptos::build_ts()
    ```
    This compiles Sass, builds the Rust WASM package using `wasm-pack`, installs/updates the WASM dependency for TypeScript using `yarn`, and finally bundles the TypeScript/JavaScript using `vite`. The final assets (`*.js`, `style.css`) are placed in `inst/dist/`.

5.  **Document and Use:**
    *   Run `devtools::document()` to generate documentation and update your package's `NAMESPACE`.
    *   Use `devtools::install()` to install your package locally, including the new component.
    *   Use your new component in a Shiny app like any other input!

## Example Usage

Let's assume you created a `leptos_button` component using `shiny.leptos::new_input_component("leptos_button")`, implemented it as a simple counter button (similar to the generic template), and ran `shiny.leptos::build()` and `devtools::document()`.

```r
# app.R (within your package or a separate project using your package)
library(shiny)
library(yourPackageName) # Replace with the actual name of your package

ui <- fluidPage(
  # Use the custom component function generated in R/leptos_button.R
  leptos_button("myButton1", value = 5),
  leptos_button("myButton2"),
  hr(),
  verbatimTextOutput("button1Value"),
  actionButton("reset", "Reset Button 1")
)

server <- function(input, output, session) {

  output$button1Value <- renderPrint({
    paste("Button 1 Value:", input$myButton1)
  })

  observe({
    print(paste("Button 2 Value:", input$myButton2))
  }) |> bindEvent(input$myButton2)

  observe({
    # Use the update function generated in R/leptos_button.R
    update_leptos_button("myButton1", value = 0)
  }) |> bindEvent(input$reset)

}

shinyApp(ui, server)
```

## Key Functions

*   `init()`: Initializes the required directory structure and configuration files in an existing R package.
*   `new_input_component(component_name)`: Creates scaffolding (R, Rust, TypeScript files) for a new input component.
*   `build()`: Runs the full build process (Sass, Rust/WASM, TypeScript/Vite).
*   `build_sass()`: Builds only the Sass assets.
*   `build_rs()`: Builds only the Rust/WASM assets using `wasm-pack`.
*   `build_ts()`: Builds only the TypeScript assets using `yarn` and `vite` (implicitly runs `build_rs` first).

## Project Structure

After running `init()`, your package will have these key directories for Leptos/WASM development:

*   `srcrs/`: Contains the Rust source code for your Leptos components.
    *   `srcrs/src/lib.rs`: Main library file for the Rust crate.
    *   `srcrs/src/*.rs`: Individual component source files.
    *   `srcrs/Cargo.toml`: Defines Rust dependencies and crate settings.
*   `srcts/`: Contains the TypeScript source code for Shiny input/output bindings.
    *   `srcts/src/index.ts`: Main entry point for TypeScript bundling.
    *   `srcts/src/*.ts`: Individual component binding files.
    *   `srcts/package.json`: Defines Node.js dependencies (like Vite, TypeScript, and your WASM package).
    *   `srcts/vite.config.js`: Configuration for the Vite bundler.
    *   `srcts/tsconfig.json`: TypeScript compiler options.
*   `srcsass/`: Contains Sass/SCSS files for styling.
    *   `srcsass/main.scss`: Main entry point for Sass compilation.
*   `out/`: (Generated by `build_rs`) Contains the compiled WASM package (`yourpackage-wasm`). This is used as a local dependency by `srcts`.
*   `inst/dist/`: (Generated by `build_ts` and `build_sass`) Contains the final bundled JavaScript (`yourpackage.js`) and CSS (`style.css`) files that will be included in your R package and served to the browser.
*   `Cargo.toml`: (At package root) Defines the Rust workspace.

## License

*MIT License*
See the [LICENSE](LICENSE) file for details.

