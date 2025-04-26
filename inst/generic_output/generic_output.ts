import { ErrorsMessageValue } from "rstudio-shiny/srcts/types/src/shiny/shinyapp";
import {
  attach_@@component_name_snake@@,
  update_@@component_name_snake@@,
  @@component_name_camel@@State,
} from "@@package_name@@-wasm"; // Import functions from the WASM package

// Extend the HTMLElement interface to include our state property
interface HTMLElement {
    state: @@component_name_camel@@State | undefined;
}

// Define a Shiny Output Binding for our component.
class @@component_name_camel@@Binding extends Shiny.OutputBinding {

  // Find the HTML element(s) associated with this output binding.
  // The selector should match the class applied in the R UI function.
  find(scope: HTMLElement): JQuery<HTMLElement> {
    return $(scope).find(".@@package_name@@-@@component_name_snake@@-container");
  }

  // Get the ID of the output element. Standard implementation.
  getId(el: HTMLElement): string {
    const id = el.id;
    if (!id) throw new Error("Output element is missing an ID");
    return id;
  }

  // This is the core function called by Shiny to render or update the output.
  renderValue(el: HTMLElement, data: any): void {
    try {
      // Check if the component has already been initialized (state exists).
      if (!el.state) {
        el.state = attach_@@component_name_snake@@(el, data);
      } else {
        // Subsequent renders: Call the update function from Rust/WASM.
        // Pass the stored state object and the new data from Shiny.
        update_@@component_name_snake@@(el.state, data);
      }
    } catch (error) {
      // Log errors from the Rust/WASM functions to the console.
      console.error(`Error rendering @@component_name_snake@@ output (${el.id}):`, error);
    }
  }

  renderError(el: HTMLElement, err: ErrorsMessageValue): void {}

  clearError(el: HTMLElement): void {}
}

Shiny.outputBindings.register(new @@component_name_camel@@Binding(), "@@component_name_camel@@Binding");
