library(shiny)
source("back-end/linear-programming.R")
source("back-end/handle-upload-file.R")

server <- function(input, output, session){
  
# Introduction
  
# random data block -------------------------------------------------------------------------------------
  n <- eventReactive(input$go, input$n_people)
  day <- eventReactive(input$go, input$n_day)
  shift <- eventReactive(input$go, input$n_shift)
  busy_prob <- eventReactive(input$go, input$busy_prob)
  
  ## Validate feedback block
  iv <- InputValidator$new()
  iv$add_rule("n_people", sv_between(2, 20))
  iv$add_rule("n_day", sv_between(7, 28))
  iv$add_rule("n_shift", sv_between(2, 5))
  iv$enable()
  # check input value block
  s_stop <-  reactive({
    if( (!between(n(),2,20)) || (!between(day(), 7, 28)) || (!between(shift(), 2,5 )) ) { TRUE }
    else{ FALSE }
  })


# user data block ---------------------------------------------------------------------------------------
  # handle error file type
  
  # handle file
  # weight_data <- reactive({
  #   read_all_sheet(input$file$datapath) %>% 
  #     clean_user_input()
  # })
  
# Both type of input: -----
  
  people_per_shift <- eventReactive(input$optim, input$people_per_shift)
  cont_w <- eventReactive(input$optim, input$cont_w) 
  
  
  #weight_data <- reactive({})

# Weight data -------------------------------------------------------------------------------------------

  weight_data <- eventReactive(req(input$tabs, input$go), {
    if (! input$tabs == "user_df") {
      gen_w_data(n = n(),day = day(), shift = shift(),busy_prob = busy_prob())
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


  ## tab 2: preview people by names
  observeEvent(n(), {
    updateSelectInput(session, 'people_name', choices = unique(weight_data()$name))
  })
  
  output$review_table <- renderTable({
    
    weight_data() %>%
      filter(name == input$people_name) %>%
      select(-name,-people) %>%
      pivot_wider(shift, names_from = day, values_from = w, names_prefix = 'Day ') %>%
      mutate(across(.fns = ~ if_else(
        .x == -10000, "Can't work", as.character(.x)
      )))
  })
  
  ## tab3: result
  result <- eventReactive(input$optim, {
    assign_schedule(weight_data(), w_per_shift = people_per_shift(), cont_w =  cont_w())
  })
  
  ### render result
  
  join_weight_data <- eventReactive(input$optim,{weight_data() %>% 
      distinct(name, people)
  })
  
  output$result_table <- renderTable({
    get_schedule(result()) %>% 
      left_join(join_weight_data(), by = 'people') %>% 
      pivot_wider(shift, names_from = day, values_from = name, names_prefix = 'Day ',
                  values_fn =  function(x) str_c(x, collapse = "/"))
  })
  
}
