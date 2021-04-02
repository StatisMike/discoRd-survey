# mandatory fields
fieldsMandatory <- g_questions %>%
  filter(.data[['mandatory']]) %>%
  pull(inputId)

# fields that will be saved and displayed in the googlesheet
fieldsAll <- g_questions[['inputId']]

humanTime <- function() format(Sys.time(), "%Y-%m-%d %H:%M:%OS")

# Define server logic
server <- function(input, output, session) {

  # gather the form data into the right shape
  formData <- reactive({
    data <- sapply(fieldsAll, function(x) input[[x]])
    data <- c(data, timestamp = humanTime())
  })

  # save the data to Google Sheet
  saveData <- function(data){
    data <- data %>%
      as.list() %>%
      data.frame()

    googlesheets4::sheet_append(
      ss = GS_ID,
      data = data,
      sheet = GS_SHEET_ANSWERS
    )
  }

  loadData <- function() {
    # Read the data
    read_sheet(
      ss = GS_ID,
      sheet = GS_SHEET_ANSWERS
    )
  }

  observe({
    # check if all mandatory fields have a value
    mandatoryFilled <-
      vapply(fieldsMandatory,
             function(x) {
               !is.null(input[[x]]) && input[[x]] != "" && !is.na(input[[x]])
             },
             logical(1))
    mandatoryFilled <- all(mandatoryFilled)

    # disable submit button if any mandatory fields are not filled in and
    # age is not between 13 and 100
    shinyjs::toggleState(
      id = "submit",
      condition = mandatoryFilled && input$age >= 13 && input$age <= 100
    )
  })

  # action to take when submit button is pressed
  observeEvent(input$submit, {
    shinyjs::disable("submit")
    shinyjs::show("submit_msg")
    shinyjs::hide("error")

    tryCatch({
      saveData(formData())
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
    })
  })
}
