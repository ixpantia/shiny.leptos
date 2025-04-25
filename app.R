devtools::load_all()
library(shiny)

ui <- fluidPage(
  leptos_button("hello1"),
  leptos_button("hello2"),
  leptos_button("hello3"),
  actionButton("reset", "Reset")
)

server <- function(input, output, session) {

  observe({
    print(c("Hello 1:", input$hello1))
  })

  observe({
    print(c("Hello 2:", input$hello2))
  })

  observe({
    print(c("Hello 3:", input$hello3))
  })

  observe({
    update_leptos_button("hello1", 0.0)
    update_leptos_button("hello2", 0.0)
    update_leptos_button("hello3", 0.0)
  }) |>
    bindEvent(input$reset)
}

shinyApp(ui, server)
