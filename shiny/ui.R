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
  title = "discoRd Member Survey",
  tags$head(tags$style(HTML("
                            h1{
                            text-align: center;
                            }
                            h5{
                            text-align: center;
                            }
                            "
                            )),
    div(id = "header",
        h1("discoRd Member Survey"),
        h5("Thank you for being an awesome part of the discoRd community.
           To learn more about our", tags$br(),  "server members, we would like to collect 
           demographic and interests information. Please", tags$br(), "be assured that this 
           survey is completely anonymous and the data/analysis will only be", tags$br(), 
           "shared within the discoRd server. Please contact the server admins via 
           @ModMail or ping", tags$br(), "@admin in the #server-concerns channel if you have any 
           questions regarding this survey."))
  ),
  fluidRow(align = "center", populate_questions(
    ss = "1YRVzzMXm-IIxhvpQWeXCJyh4kXRfcLad2Z60gzC0dxU",
    sheet = "Questions",
    div_id = "form"
    ),
    div(style = "margin-top: 30px"),
    tags$style(type='text/css', 
               "
               #form { 
               width: 100%; 
               font-size: 14px;
               margin-top: 30px;
               }
               .form-group {
               margin-bottom: 25px;
               }
               ")),
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
      h3("Thank you!", tags$br(), "Your response was submitted successfully."),
      h1(img(src="https://user-images.githubusercontent.com/64165327/112882297-c4707600-909a-11eb-9bc1-963f2d00ee72.png")),
      tags$style("h3{
                 text-align: center;
                 }")
    )
  )
)
