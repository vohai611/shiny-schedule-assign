library(shiny)
library(shinyvalidate)
source("back-end/linear-programming.R")
source("back-end/handle-upload-file.R")

server <- function(input, output, session){
  
# Introduction
  
# random data block -------------------------------------------------------------------------------------
  # auto change tab (observe event)
  observeEvent(input$go,
               updateTabsetPanel(session,
                                 "main", selected = "Review data"))
  
  observeEvent(input$optim,
               updateTabsetPanel(session, "main", selected =  "Schedule assign"))
  
  ## deactive optimze button when not generate data
  observeEvent({
    input$n_people
    input$n_day
    input$n_shift
    input$busy_prob
  }, 
    {output$ui_optim = renderUI("") }
  )
  
  observeEvent({
    input$go
  },
  {output$ui_optim = renderUI(
    actionButton('optim', label = 'Optimize!', width = '70%'))}
  
  )
  
  
  # shinyvalidate does not work properly !! 
  iv <- InputValidator$new()
  iv$add_rule("n_people", sv_between(2, 20))
  iv$add_rule("n_day", sv_between(7, 28))
  iv$add_rule("n_shift", sv_between(1, 5))
  iv$enable()

  n <- eventReactive(input$go, input$n_people)
  day <- eventReactive(input$go, input$n_day)
  shift <- eventReactive(input$go, input$n_shift)
  busy_prob <- eventReactive(input$go, input$busy_prob)

  ## Validate feedback block
  
  # check input value block
  s_stop <-  reactive({
    if( (!between(n(),2,20)) || (!between(day(), 7, 28)) || (!between(shift(), 1,5 )) ) { TRUE }
    else{ FALSE }
  })


# Both type of input: -----
  people_per_shift <- eventReactive(input$optim, input$people_per_shift)
  cont_w <- eventReactive(input$optim, input$cont_w) 
  max_work_days =  eventReactive(input$optim, input$max_work_days)
  
# Weight data -------------------------------------------------------------------------------------------
  # weight data depend on user choose tab1 or tab2
  
  weight_data <- eventReactive(req(input$tabs, input$go), {
    if (s_stop()) validate("Input is not valid
                           people must between 2 and 20,
                           day must between 7 and 28,
                           number of shift must between 1 and 5.
                           ")
    if (! input$tabs == "user_df") {
      gen_w_data(n = n(),day = input$n_day, shift = shift(),busy_prob = busy_prob())
    } else {
      a <- read_all_sheet(input$file$datapath) 
      # check if user input is in correct form
      if (any(is.na(a)))
        validate('Wrong data!')
      a
    }
  })  
  
  ## allow user to download template
  output$template <- downloadHandler(filename = function() {"template.xlsx"},
                                     content = function(file) {
    df <- template_download(weight_data())
    writexl::write_xlsx(df, path = file)
  })

# Main panel --------------------------------------------------------------------------------------------

  ## tab1: Introduction (at UI)
  
  ## tab 2: preview people by names ---
  
  observeEvent(n(), {
    updateSelectInput(session, 'people_name', choices = unique(weight_data()$name))
  })
  
  output$review_table <- renderTable({
    
    weight_data() %>%
      filter(name == input$people_name) %>%
      select(-name,-people) %>%
      pivot_wider(shift, names_from = day, values_from = w, names_prefix = 'Day ') %>%
      mutate(across(.fns = ~ if_else(
        .x == -10000, "Busy", as.character(.x)
      )))
  })
  
  ## tab3: result -----
  ### run model
  result <- eventReactive(input$optim, {
    waiter::Waiter$new(id = c("result_table", "individual_table"),
                       color = waiter::transparent(.6),
                       html = waiter::spin_3())$show()
    assign_schedule(weight_data(), w_per_shift = people_per_shift(), cont_w =  cont_w(), max_work_days())
  })
  
  ### render result
  
  # complement data 
  join_weight_data <- eventReactive(input$optim,{weight_data() %>% 
      distinct(name, people)
  })
  
  # Extract output data
  result_table <- reactive({
    get_schedule(result()) %>% 
      left_join(join_weight_data(), by = 'people') %>% 
      pivot_wider(shift, names_from = day, values_from = name, names_prefix = 'Day ',
                  values_fn =  function(x) str_c(x, collapse = "/")) 
  })
  
  ## render to screen
  output$result_table <- renderTable(result_table())
  
  
  ## allow use to download result 
  
  output$down_result <- downloadHandler(filename = function() {"result.xlsx"},
                                     content = function(file) {
    writexl::write_xlsx(result_table(), path = file)
                                     })
    
  ## display individual result
  observeEvent(input$optim , {
    updateSelectInput(session, 'individual_result', choices = unique(weight_data()$name))
  })
  
  
  individual_table <- reactive( {
    library(kableExtra)
    weight_data() %>% 
      filter(name == input$individual_result) %>% 
      left_join(get_schedule(result())) %>% 
      mutate(w = if_else(w == -10000, "Busy", as.character(w))) %>% 
      mutate(w = cell_spec(w, background = if_else(!is.na(value), "firebrick", 'white'))) %>% 
      pivot_wider(shift, names_from = day, values_from = w, names_prefix = "Day " ) %>% 
      kbl(booktabs = T, linesep = " ", escape=FALSE,) %>% 
      kable_styling(bootstrap_options = "basic", full_width = F, position = "left")
  })
  

  output$individual_table <- function(){
    individual_table()
  }
  
  ## Display model result
  output$model_text_result <- renderText({
    
    status <- solver_status(result())
    obj_value <- objective_value(result())
    
    paste0("Solver status: ", status,
           "\nObjective value: ", obj_value)
  
  })
  
  
}
