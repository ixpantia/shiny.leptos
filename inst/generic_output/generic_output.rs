use leptos::prelude::*;
use wasm_bindgen::{prelude::wasm_bindgen, JsValue};
use web_sys::HtmlElement;

// Define the structure of the data you expect from Shiny's render function.
// Replace `String` with your actual data type (e.g., a struct)
// and ensure it derives `serde::Deserialize`.
// Use `serde_wasm_bindgen::from_value` to deserialize.
// Example:
// #[derive(serde::Deserialize, Clone, Debug, PartialEq)]
// struct @@component_name_camel@@Data {
//     value: i32,
//     label: String,
// }
type ExpectedDataType = String; // <-- Replace this with your data type if needed

#[wasm_bindgen]
pub struct @@component_name_camel@@State {
    // Use RwSignal to hold the reactive data received from Shiny.
    data: RwSignal<ExpectedDataType>,
}

// This is the Leptos component that renders the UI based on the data.
#[component]
fn @@component_name_camel@@(
    // The component receives the reactive data signal.
    data: RwSignal<ExpectedDataType>
) -> impl IntoView {
    // Build your view here using the `data` signal.
    // The `view!` macro uses reactive primitives, so the UI
    // will automatically update when `data` changes.
    view! {
        // Simple example: display the data directly.
        // Replace this with your actual UI rendering logic.
        <p>{data}</p>
    }
}

// This function is called by the TypeScript binding (`renderValue`)
// the first time the output is rendered. It mounts the Leptos component
// to the specified HTML element.
#[wasm_bindgen]
pub fn attach_@@component_name_snake@@(element: HtmlElement, initial_data_js: JsValue) -> Result<@@component_name_camel@@State, String> {
    // Deserialize the initial data received from Shiny.
    let initial_data: ExpectedDataType = serde_wasm_bindgen::from_value(initial_data_js)
        .map_err(|e| format!("Failed to deserialize initial data: {}", e))?;

    let data_signal = RwSignal::new(initial_data);

    let state = @@component_name_camel@@State { data: data_signal };

    leptos::mount::mount_to(element, move || {
        view! {
            <@@component_name_camel@@ data=data_signal />
        }
    })
    .forget();

    Ok(state)
}

#[wasm_bindgen]
pub fn update_@@component_name_snake@@(state: &@@component_name_camel@@State, new_data_js: JsValue) -> Result<(), String> {
    // Deserialize the new data received from Shiny.
    let new_data: ExpectedDataType = serde_wasm_bindgen::from_value(new_data_js)
        .map_err(|e| format!("Failed to deserialize updated data: {}", e))?;

    state.data.set(new_data);

    Ok(())
}
