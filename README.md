# shiny.leptos

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- TODO: Add CI build status badge -->
[![R-CMD-check](https://github.com/ixpantia/shiny.leptos/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ixpantia/shiny.leptos/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**Create Custom Shiny Inputs and Outputs with Rust, Leptos, and WebAssembly**

`shiny.leptos` provides a framework and tooling within R to build custom Shiny input and output components using the [Leptos](https://leptos.dev/) Rust framework, compiling them to WebAssembly (WASM) for high-performance, interactive front-end elements within your Shiny applications.

This package helps you:

1.  **Initialize:** Set up the necessary directory structure (`srcrs`, `srcts`, `srcsass`) and configuration files (Cargo.toml, package.json, vite.config.js, etc.) for Rust/Leptos and TypeScript development within your R package.
2.  **Scaffold:** Generate template files (Rust, TypeScript, R) for new custom input or output components.
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

2.  **Create a New Component:**
    *   **Input Component:** Use `new_input_component()` to generate the basic files. For example, to create a component named `my_counter`:
        ```r
        shiny.leptos::new_input_component("my_counter")
        ```
        This will create `R/my_counter.R`, `srcrs/src/my_counter.rs`, and `srcts/src/my_counter.ts`.
    *   **Output Component:** Use `new_output_component()` similarly. For example, to create `my_plot`:
        ```r
        shiny.leptos::new_output_component("my_plot")
        ```
        This will create `R/my_plot.R` (with `my_plot_output` and `render_my_plot`), `srcrs/src/my_plot.rs`, and `srcts/src/my_plot.ts`.
    *   Both functions update `srcrs/src/lib.rs` and `srcts/src/index.ts` to include the new component.

3.  **Implement Your Component:**
    *   Edit the generated `.rs` file (`srcrs/src/`) to implement the desired appearance and behavior using Leptos.
    *   Modify the generated `.ts` file (`srcts/src/`) if the default Shiny input/output binding needs adjustments.
    *   Customize the generated `.R` file (`R/`) to set appropriate default values or add specific arguments to the R functions (UI, update/render).
    *   Optionally, add styles for your component in `srcsass/`.

4.  **Build Assets:**
    From the root of your package, run the build command:
    ```r
    shiny.leptos::build()
    # Or run individual steps:
    # shiny.leptos::build_sass()
    # shiny.leptos::build_rs() # Called by build_ts
    # shiny.leptos::build_ts()
    ```
    This compiles Sass, builds the Rust WASM package, installs/updates the WASM dependency, and bundles the TypeScript/JavaScript. The final assets (`*.js`, `style.css`) are placed in `inst/dist/`.

5.  **Document and Use:**
    *   Run `devtools::document()` to generate documentation and update your package's `NAMESPACE`.
    *   Use `devtools::install()` to install your package locally.
    *   Use your new component in a Shiny app like any other input or output!

## Example Usage (Input)

Let's assume you created a `leptos_button` input component, implemented it, and built/installed the package `yourPackageName`.

```r
# app.R
library(shiny)
library(yourPackageName) # Replace with your package name

ui <- fluidPage(
  leptos_button("myButton1", value = 5),
  hr(),
  verbatimTextOutput("button1Value"),
  actionButton("reset", "Reset Button 1")
)

server <- function(input, output, session) {
  output$button1Value <- renderPrint({
    paste("Button 1 Value:", input$myButton1)
  })

  observe({
    update_leptos_button("myButton1", value = 0)
  }) |> bindEvent(input$reset)
}

shinyApp(ui, server)
```

*Creating and using a custom output follows a similar pattern, using `new_output_component`, implementing the Rust view and R render/UI functions, building, and then using `yourPackageName::my_output_output()` in the UI and `output$myOutput <- yourPackageName::render_my_output({...})` in the server.*

## Key Functions

*   `init()`: Initializes the required directory structure and configuration files.
*   `new_input_component(component_name)`: Creates scaffolding for a new **input** component.
*   `new_output_component(component_name)`: Creates scaffolding for a new **output** component.
*   `build()`: Runs the full build process (Sass, Rust/WASM, TypeScript/Vite).

## Project Structure

After running `init()`, your package will have these key directories:

*   `srcrs/`: Rust source code (Leptos components).
*   `srcts/`: TypeScript source code (Shiny bindings).
*   `srcsass/`: Sass/SCSS files for styling.
*   `out/`: (Generated) Compiled WASM package, used by `srcts`.
*   `inst/dist/`: (Generated) Final JS and CSS assets for the R package.
*   `Cargo.toml`: (Root) Rust workspace definition.
*   `R/`: Generated R functions for UI and server interaction.

## Authors

*   **ixpantia, SRL** (Copyright Holder) <hola@ixpantia.com>
*   **Andres Quintero** (Author, Creator) <andres@ixpantia.com>

## License

*MIT License*
See the [LICENSE](LICENSE) file for details.
