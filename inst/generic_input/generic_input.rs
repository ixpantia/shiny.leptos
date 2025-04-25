use leptos::prelude::*;
use wasm_bindgen::{prelude::wasm_bindgen, JsValue};
use web_sys::{ HtmlElement, js_sys };

#[derive(Clone)]
#[wasm_bindgen]
pub struct @@component_name_camel@@State {
    value: RwSignal<f64>,
}

#[component]
fn @@component_name_camel@@(state: @@component_name_camel@@State) -> impl IntoView {
    view! {
        <button class="btn btn-primary" on:click=move |_| *state.value.write() += 1.0 >
            "Count: " {state.value}
        </button>
    }
}

#[wasm_bindgen]
pub fn attach_@@component_name_snake@@(element: HtmlElement, initial_value: Option<f64>) -> @@component_name_camel@@State {
    let initial_value = initial_value.unwrap_or(0.0);
    let value = RwSignal::new(initial_value);
    let state = @@component_name_camel@@State { value };
    let component_state = state.clone();
    leptos::mount::mount_to(element, move || {
        view! {
            <div>
            <@@component_name_camel@@ state=component_state></@@component_name_camel@@>
            </div>
        }
    })
    .forget();
    state
}

#[wasm_bindgen]
pub fn update_@@component_name_snake@@(state: &@@component_name_camel@@State, value: f64) {
    state.value.set(value);
}

#[wasm_bindgen]
pub fn get_@@component_name_snake@@_value(state: &@@component_name_camel@@State) -> f64 {
    state.value.get_untracked()
}

#[wasm_bindgen]
pub fn subscribe_@@component_name_snake@@(state: &@@component_name_camel@@State, callback: js_sys::Function) {
    let state = state.clone();
    Effect::watch(
        move || state.value.get(),
        // (value, last_value, _prev)
        // The value passed to the callback is FALSE since we do not
        // have a set rate policy
        move |_, _, _| match callback.call0(&JsValue::FALSE) {
            Ok(_) => {}
            Err(err) => {
                web_sys::console::error_1(&JsValue::from_str(&format!(
                    "Error calling callback: {}",
                    err.as_string().unwrap_or_default()
                )));
            }
        },
        // Do not run the effect immediately
        false,
    );
}
