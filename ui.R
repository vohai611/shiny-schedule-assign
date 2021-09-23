library(shiny)
library(shinyvalidate)
library(tidyverse)


ui <- fluidPage(theme = shinythemes::shinytheme("sandstone"),
  titlePanel('Schedule assign application'),
  tags$br(),
  sidebarLayout(
    sidebarPanel(width = 3,
    fluidRow(
    tabsetPanel(id = 'tabs',
      tabPanel("Random data", value ='random_df',
               numericInput("n_people", "Number of people: ", value = 5),
               numericInput("n_day", "Number of days: ", value = 7),
               numericInput("n_shift", "Number of shift per day: ", value = 3),
               sliderInput('busy_prob', "Probability people get busy", min = 0, max = .6,step = .1,value =.2),
               downloadButton("template", "Download template")
               ),
      tabPanel("User data", value ='user_df',
               fileInput('file', "Upload your file: ", accept = "xlsx"),
               )
    )
    ),
    fluidRow(
      numericInput("people_per_shift", "Number of people per shift: ", min = 1, max = 5,value = 1),
      checkboxInput('cont_w', "Allow work continously", value = FALSE),
      actionButton('go', label = "Generate data"),
      actionButton('optim',label = 'Optimize!')
    )
      
    ),mainPanel = mainPanel(
      tabsetPanel(
        tabPanel("Introduction", HTML(read_lines("Introduction.html"))), 
        tabPanel("Review data",
                 column(width = 3, selectInput('people_name',"Choose people:", choices = NULL)),
                 tableOutput("review_table")), 
        tabPanel("Schedule assign", tableOutput("result_table"))
    )
  )
))

# server_test <- function(input, output, session){}
# shinyApp(ui, server_test)
