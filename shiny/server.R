# Define server logic
server <- function(input, output, session) {

  # reactiveValues for storing valid and mandatory inputs status
  # as valid$mandatory_filled and valid$minmax_matched
  # (their negations are invalid and mandatory not-filled questions)
  valid <- reactiveValues()

  # gather the form data into the right shape
  formData <- reactive({
    data <- reactiveValuesToList(input)[fieldsAll]
    data <- c(data, timestamp = humanTime())
  })

  observe({
    # check if all mandatory fields have a value
    valid$mandatory_filled <-
      vapply(fieldsMandatory,
             function(x) {
               !is.null(input[[x]]) && input[[x]] != "" && !is.na(input[[x]])
             },
             logical(1))

    # check if all numeric fields are between or equal min and max values
    # allows for numeric field to be NA (it can be non-mandatory even though it has min and max!)
    valid$minmax_matched <-
      vapply(fieldsNumeric,
             function(x) {
               (input[[x]] >= g_questions[g_questions$inputId == x, 'num_min'] && 
                  input[[x]] <= g_questions[g_questions$inputId == x, 'num_max']) ||
                 is.na(input[[x]])
             },
             logical(1))

    # update submit button if any mandatory fields are not filled in and
    # numeric inputs are in their valid min-max values - instatenous feedback
    # can't be disabled - need to be able to trigger modalDialog with info

    valid$filled_matched <- c(valid$mandatory_filled, valid$minmax_matched)
    
    if(input$submit > 0){
      
      for (input in 1:length(valid$filled_matched)) {
        
        if (isTRUE(valid$filled_matched[input])) {
          
          shinyjs::removeCssClass(id = names(valid$filled_matched)[input],
                                  class = "invalid_input")
          
        } else {
          
          shinyjs::addCssClass(id = names(valid$filled_matched)[input],
                               class = "invalid_input")
        }
      }
    }

    if (!all(valid$filled_matched)) {

      updateActionButton(session, inputId = "submit",
                         label = "Cannot submit")

    } else {

      updateActionButton(session, inputId = "submit",
                         label = "Submit")

    }

  })

  # action to take when submit button is pressed
  observeEvent(input$submit, {

    if (!all(valid$filled_matched)) {

      showModal(
        modalDialog(
          title = "Error!",
          if (!all(valid$mandatory_filled)) {
            tags$p("Some mandatory inputs aren't filled:",
                        tags$br(),
                        paste(names(valid$mandatory_filled[!valid$mandatory_filled]),
                              collapse = ", "))
          },
          if (!all(valid$minmax_matched)) {
            tags$p("Some numeric inputs aren't in valid min/max values:",
                   tags$br(),
                   paste(names(valid$minmax_matched[!valid$minmax_matched]),
                         collapse = ", "))
          }
        )
      )

    } else {

      shinyjs::disable("submit")
      shinyjs::show("submit_msg")
      shinyjs::hide("error")

      tryCatch({
        save_new_answers(formData())
        shinyjs::reset("form")
        shinyjs::hide("form")
        shinyjs::show("thankyou_msg")
      },
      error = function(err){
        shinyjs::html("error_msg", err$message)
        shinyjs::show(id = "error", anim = TRUE, animType = "fade")
      },
      finally = {
        shinyjs::enable("submit")
        shinyjs::hide("submit_msg")
      }

      )}

  })

}
