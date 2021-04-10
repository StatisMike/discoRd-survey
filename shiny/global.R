#
# This is a Shiny web application. Its purpose is to replicate the current
# discoRd member survey in Shiny.
#
# Join the R discoRd server here:
#
#    https://discord.gg/xRkFsWwJsy

## Note: the following code is run once at start up. It's loaded in the global
## environment of the R session and thus shared among the `server` and `ui`.
## Reading the questions here means the ui doesn't reflect question changes
## until the app is restarted.
library(DT)
library(shiny)
library(shinyjs)
library(dplyr)
library(googlesheets4)
library(gargle)
library(bslib)

source("../R/constants.R")
source('../R/generate_questions.R')

g_questions <- read_sheet(ss = GS_ID,
                          sheet = GS_SHEET_QUESTIONS,
                          col_types = QUESTIONS_INPUT_COLUMN_TYPES)

# mandatory fields
fieldsMandatory <- g_questions %>%
  filter(.data[['mandatory']]) %>%
  pull(inputId)

# fields that will be saved and displayed in the googlesheet
fieldsAll <- g_questions[['inputId']]

## Create a timestamp
humanTime <- function() format(Sys.time(), "%Y-%m-%d %H:%M:%OS")

## Save the answer user input to Google Sheet
save_new_answers <- function(user_answers) {
  old_answers <- read_all_answers()
  ## drop invalid answers
  user_answers <- user_answers[!sapply(user_answers, is.null)]
  user_answers <- user_answers %>%
    as.data.frame()

  ## I'm using `merge()` here and not `full_join()` because
  ## I want to dynamically coerce variable types. Otherwise,
  ## `full_join()`'s strict type safety raises an error
  to_upload_answers <- merge(old_answers, user_answers,
                             all = TRUE, sort = FALSE) %>%
    relocate(timestamp, .after = last_col())

  sheet_write(
    ss = GS_ID,
    data = to_upload_answers,
    sheet = GS_SHEET_ANSWERS
  )
}

## Read the Answer data from Google Sheets
read_all_answers <- function() {
  read_sheet(
    ss = GS_ID,
    sheet = GS_SHEET_ANSWERS
  )
}
