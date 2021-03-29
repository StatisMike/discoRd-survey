library(shiny)
library(shinyjs)
library(dplyr)

source("../R/constants.R")
source('../R/generate_questions.R')

appCSS <-
  ".mandatory_star { color: red; }
   #error { color: red; }"

# Define UI for application
fluidPage(
  shinyjs::useShinyjs(),
  shinyjs::inlineCSS(appCSS),
  titlePanel("discoRd Member Survey"),
  populate_questions(
    ss = "1YRVzzMXm-IIxhvpQWeXCJyh4kXRfcLad2Z60gzC0dxU",
    sheet = "Questions",
    div_id = "form"
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
