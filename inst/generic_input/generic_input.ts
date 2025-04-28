import { RatePolicyModes } from "rstudio-shiny/srcts/types/src/inputPolicies/inputRateDecorator";
import {
  attach_@@component_name_snake@@,
  update_@@component_name_snake@@,
  get_@@component_name_snake@@_value,
  @@component_name_camel@@State,
  subscribe_@@component_name_snake@@
} from "@@package_name_snake@@-wasm";

interface HTMLElement {
    state: @@component_name_camel@@State | undefined;
}

// Button:
class @@component_name_camel@@Binding extends window.Shiny.InputBinding {

  find(scope: HTMLElement): JQuery<HTMLElement> {
    return $(scope).find(".@@package_name_snake@@-@@component_name_snake@@-container");
  }

  initialize(el: HTMLElement): void {
    const id = el.id;
    if (!id) return;

    const initialValue = el.getAttribute("data-initial-value");
    const parsedValue = initialValue ? parseFloat(initialValue) : null;

    el.state = attach_@@component_name_snake@@(el, parsedValue);
  }

  subscribe(el: HTMLElement, callback: (value: boolean) => void): void {
    if (!el.state) this.initialize(el);
    if (el.state) {
      subscribe_@@component_name_snake@@(el.state, callback);
    }
  }

  getValue(el: HTMLElement): any {
    if (!el.state) this.initialize(el);
    return get_@@component_name_snake@@_value(el.state);
  }

  setValue(el: HTMLElement, value: any): void {
    if (!el.state) this.initialize(el);
    update_@@component_name_snake@@(el.state, value);
  }

  receiveMessage(el: HTMLElement, data: any): void {
    if (!el.state) this.initialize(el);
    this.setValue(el, data.value);
  }

  getRatePolicy(el: HTMLElement): { policy: RatePolicyModes; delay: number; } | null {
    return null;
  }

  getType() {
    return "";
  }
}

window.Shiny.inputBindings.register(new @@component_name_camel@@Binding(), "@@component_name_camel@@Binding");
