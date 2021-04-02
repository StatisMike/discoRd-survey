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

source("../R/constants.R")
source('../R/generate_questions.R')

g_questions <- read_sheet(ss = GS_ID,
                          sheet = GS_SHEET_QUESTIONS,
                          col_types = QUESTIONS_INPUT_COLUMN_TYPES)
