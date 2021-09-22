# TODO
# add constrain
# n people per shift
# add max shift per day

# make app cleaner

# write instruction

# let user upload data



# building a simple app prototype -----------------------------------------------------------------------
library(shiny)
library(shinyvalidate)
library(tidyverse)
library(ompr)
library(ompr.roi)
library('ROI.plugin.glpk')

ui <- fluidPage(
  
  titlePanel("Tabsets"),
  
  sidebarLayout(
    
    sidebarPanel(
      numericInput("n_people", "Number of people: ", value = 5),
      numericInput("n_day", "Number of days: ", value = 7),
      numericInput("n_shift", "Number of shift per day: ", value = 3),
      numericInput("people_per_shift", "Number of people per shift: ", min = 1, max = 5,value = 1),
      actionButton('go', label = "Optimize!")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Introduction", HTML('Place holder')), 
        tabPanel("Review data",
                 column(width = 3, selectInput('people_name',"Choose people:", choices = NULL)),
                 tableOutput("review_table")), 
        tabPanel("Schedule assign", tableOutput("result_table"))
      )
    )
  )
)

server <- function(input, output, session){
  
  
  n <- eventReactive(input$go, input$n_people)
  people <- eventReactive( input$go, {randomNames::randomNames(n = n() , ethnicity = "Asian", which.names = 'first')})
  day <- eventReactive(input$go, input$n_day)
  shift <- eventReactive(input$go, input$n_shift)
  
  
  ## Validate feedback block
  iv <- InputValidator$new()
  iv$add_rule("n_people", sv_between(2, 20))
  iv$add_rule("n_day", sv_between(7, 28))
  iv$add_rule("n_shift", sv_between(2, 5))
  iv$enable()
  # check input value block
 s_stop <-  reactive({
  if( (!between(n(),2,20)) || (!between(day(), 7, 28)) || (!between(shift(), 2,5 )) )  {TRUE}
   else{FALSE }
  })
  
 ## tab 2: preview people by names
 observeEvent(n(), {
   updateSelectInput(session, 'people_name', choices = people())
 })
 output$review_table <- renderTable({
   weight_data() %>%
     left_join(tibble(name = people() , people = seq_len(n()))) %>%
     filter(name == input$people_name) %>%
     select(-name,-people) %>%
     pivot_wider(shift, names_from = day, values_from = w, names_prefix = 'day') %>%
     mutate(across(.fns = ~ if_else(
       .x == -10000, "Can't work", as.character(.x)
     )))
 })
  
 
  
  sample_fun <- function(times, no_work_prob = .2) {
    out <- sample(1:3, times, replace = TRUE)
    out[runif(times) < no_work_prob ] <- -10000
    return(out)
    
  }
  
  
  weight_data <-
    reactive( {
      expand.grid(
        people = seq_len(n()),
        day = seq_len(day()),
        shift = seq_len(shift())
      ) %>%
        as_tibble() %>%
        group_by(people) %>%
        mutate(w = sample_fun(day() * shift()))
    })
  
  weight <- function(people, day, shift){
    weight_data() %>% 
      filter(people == {{ people }},
             day == {{ day }},
             shift == {{ shift }}) %>% 
      pull(w)
  }
  

  result <- reactive({
    # work around NSE and shiny
    n <- n()
    day <- day()
    shift <- shift()
    
    model <- MIPModel() %>% 
     add_variable(x[i, j, t], i= 1:n, j = 1:day, t= 1:shift, type = 'binary') %>%
      # max preference
     set_objective(sum_expr(weight(i,j,t) * x[i,j,t], i = 1:n, j = 1:day, t = 1:shift)) %>%
      # each shift, just one people work
     add_constraint(sum_expr(x[i, j, t], i = 1:n) == 1, j = 1:day, t = 1:shift) %>% 
      # each people only work for 1 day
      add_constraint(sum_expr(x[i,j,t], t = 1:shift) <= 1, i = 1:n, j = 1:day)
    
    solve_model(model, with_ROI(solver = "glpk", verbose = TRUE))
  })

  output$result_table <- renderTable({
    if (s_stop() ) {
      validate("Please change input")
    }
   
    result() %>%
      get_solution(x[i, j, t]) %>%
      select(-variable,
             people = i,
             day = j ,
             shift = t) %>%
      filter(value == 1) %>%
      pivot_wider(
        shift,
        names_from = day,
        values_from = people,
        names_prefix = 'day'
      ) %>% 
      mutate(across(-shift, ~ people()[.x]))
    
  })
  # observeEvent(result(), {
  #   print({
  #     remesult() %>%
  #       get_solution(x[i, j, t])
  #   })
  # })
  
  
}

shinyApp(ui, server)


  