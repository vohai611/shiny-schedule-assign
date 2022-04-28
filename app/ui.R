library(shiny)
library(shinyvalidate)
library(tidyverse)
library(bslib)
library(markdown)

my_theme <-
  bs_theme(
    fg = "rgb(53, 48, 48)",
    primary = "#52526D",
    bootswatch = 'flatly',
    success = "#443763",
    secondary = "#694141",
    danger = "#D99F52",
    `enable-rounded` = TRUE,
    `enable-transitions` = FALSE,
    bg = "rgb(255, 255, 255)",
    base_font = font_google("Lato")
  )


ui <- fluidPage(theme = my_theme, 
  titlePanel('Schedule assign application'),
  waiter::useWaiter(),
  br(),
  sidebarLayout(
    
    sidebarPanel = sidebarPanel(width = 3,style = "position: relative;",
    fluidRow(
    tabsetPanel(type = "pills",id = 'tabs',
      tabPanel("Random data", value ='random_df',
               br(),
               numericInput("n_people", "Number of people: ", value = 5),
               numericInput("n_day", "Number of days: ", value = 7),
               numericInput("n_shift", "Number of shift per day: ", value = 3),
               sliderInput('busy_prob', "Probability people get busy", min = 0, max = .6,step = .1,value =.2),
               downloadButton("template", "Download template")
               ),
      tabPanel("User data", value ='user_df',
               br(),
               fileInput('file', "Upload your file: ", accept = "xlsx"),
               )
    )
    ),
    br(),
    fluidRow(
      numericInput("people_per_shift", "Number of people per shift: ", min = 1, max = 5,value = 1)),
    fluidRow(
      numericInput("max_work_days", "Maximum number of working days: ", min = 1, max = 1000, value = 1000)
    ),
    fluidRow(
      checkboxInput('cont_w', "Allow work continously", value = TRUE)
    ),
    fluidRow(fillRow(flex = c(3,2),
      actionButton('go', label = "Generate data", width = '80%'),
      actionButton('optim', label = 'Optimize!', width = '70%')
    ),
    br(),
    br()
    )),
    
    mainPanel = mainPanel(
      tabsetPanel(id = "main",
        tabPanel("Introduction", shiny::includeMarkdown('Introduction.md')), 
        tabPanel("Review data",
                 br(),
                 column(width = 3, selectInput('people_name',"Choose people:", choices = NULL)),
                 tableOutput("review_table")), 
        tabPanel("Schedule assign",
                 br(),
                 verbatimTextOutput("model_text_result"),
                 br(),
                 fluidRow(column(3, downloadButton("down_result", "Download result")),
                          column(9, tableOutput("result_table"))
                                  ),
                 br(),
                 fluidRow(column(3, selectInput('individual_result', "Choose people:", choices = NULL)),
                          column(9,tableOutput("individual_table")) )
                 )
    )
  )
))

