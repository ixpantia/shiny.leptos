
if (Shiny.bindAll !== undefined) {
  console.log("@@package_name@@ WASM loaded,  binding inputs and outputs");
  Shiny.bindAll(document.body)
} else {
  console.log("Shiny bindAll is  not yet defined. Shiny will bind by itself");
}
