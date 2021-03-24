#
# This is a Shiny web application. Its purpose is to replicate the current 
# discoRd member survey in Shiny. 
#
# Join the R discoRd server here:
#
#    https://discord.gg/xRkFsWwJsy
#

library(DT)
library(shiny)
library(shinyjs)
library(dplyr)
library(googlesheets4)
library(gargle)

# mandatory fields
fieldsMandatory <- c("gender",
                     "degree")

# saving the responses:
# fields that will saved and displayed in the data frame
fieldsAll <- c("gender", "age", "country", "degree", "study_field", "industry") 
responsesDir <- file.path("responses/")
# used to create timestamp for each submission
epoch_time <- function(){
  as.integer(Sys.time())
}

humanTime <- function() format(Sys.time(), "%Y-%m-%d %H:%M:%OS")


# function used to add red asterisk to mandatory fields
labelMandatory <- function(label){
  tagList(
    label,
    span("*", class = "mandatory_star")
  )
}

## Google Sheet authentication

# designate project-specific cache
options(gargle_oauth_cache = ".secrets")
# check the value of the option, if you like
# gargle::gargle_oauth_cache()
# trigger auth on purpose to store a token in the specified cache
# a broswer will be opened
# googlesheets4::sheets_auth()
# see your token file in the cache, if you like
# list.files(".secrets/")
# sheets reauth with specified token and email address
sheets_auth(
  cache = ".secrets",
  email = "ericfletcher3@gmail.com"
)

appCSS <-
  ".mandatory_star { color: red; }
   #error { color: red; }"

# genders
genders <- c("Male",
             "Female",
             "Non-binary",
             "Prefer not to say",
             "Other")

# degrees
degrees <- c("High school diploma or below",
            "Associate degree",
            "B.A / BSc or an equivalent degree",
            "B.A / BSc and still studying for a M.A / MSc",
            "M.A / MSc or an equivalent degree",
            "M.A / MSc and still studying for a phD",
            "phD",
            "Prefer not to say")

# Define UI for application
ui <- fluidPage(
  shinyjs::useShinyjs(),
  shinyjs::inlineCSS(appCSS),
  titlePanel("discoRd Member Survey"),
  div(
    id = "form",
    radioButtons(
      inputId = "gender", 
      label = labelMandatory("What is your gender?"), 
      choices = genders,
      # on form load - initialize with no selections made
      selected = character(0)
      ),
    numericInput(
      inputId = "age", 
      label = "What is your age?", 
      value = 0, 
      min = 5, 
      max = 100, 
      step = 5,
      width = 150
      ),
    textInput(
      inputId = "country",
      label = "Country of residence?",
      placeholder = "Your answer"
    ),
    radioButtons(
      inputId = "degree",
      label = labelMandatory("Highest academic degree?"),
      choices = degrees,
      # on form load - initialize with no selections made
      selected = character(0)
    ),
    textInput(
      inputId = "study_field",
      label = "Field of study?",
      placeholder = "Your answer"
    ),
    textInput(
      inputId = "industry",
      label = "What industry do you work in?",
      placeholder = "Your answer"
    ),
    actionButton(
      inputId = "submit", 
      label = "Submit", 
      class = "btn-primary", 
      width = 350)
  ),
  shinyjs::hidden(
    span(id = "submit_msg", "Submitting..."),
    div(id = "error",
        div(br(), tags$b("Error: "), span(id = "error_msg"))
        )
  ),
  # Hide thank you message until after a submission is made
  div(id = "thankYou"),
  shinyjs::hidden(
    div(
      id = "thankyou_msg",
      h3("Thanks, your response was submitted successfully!")
    )
  )
    
)

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
  
     googlesheets4::sheet_append("https://docs.google.com/spreadsheets/d/1YRVzzMXm-IIxhvpQWeXCJyh4kXRfcLad2Z60gzC0dxU/edit#gid=0", data)
   }
   
   loadData <- function() {
     # Read the data
     read_sheet("https://docs.google.com/spreadsheets/d/1YRVzzMXm-IIxhvpQWeXCJyh4kXRfcLad2Z60gzC0dxU/edit#gid=0")
   }

  observe({
    # check if all mandatory fields have a value
    mandatoryFilled <-
      vapply(fieldsMandatory,
             function(x) {
               !is.null(input[[x]]) && input[[x]] != ""
             },
             logical(1))
    mandatoryFilled <- all(mandatoryFilled)
    
    # disable submit button if all mandatory fields are not filled in
    shinyjs::toggleState(id = "submit", condition = mandatoryFilled)

    # disable submit button if age is not > 5 and <= 100
    shinyjs::toggleState(id = "submit", condition = input$age > 5 & input$age <= 100)
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

# Run the application 
shinyApp(ui = ui, server = server)
