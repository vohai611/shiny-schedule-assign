
library(ompr)
library(ompr.roi)
library(ROI.plugin.glpk)
library(tidyverse)

## Solve linear programming
## input:
# n people
# days
# shift
# people required per shift


# create random data ------------------------------------------------------------------------------------

## create weight for each people 

gen_w_data <- function(n, day, shift, busy_prob = .2) {
  
  # generate people name
  people_name <- randomNames::randomNames(n = n, ethnicity = "Asian", which.names = 'first')
  
  people_id <- tibble(people = seq_len(n), name = people_name)
  
  sample_fun <- function(times, busy_prob) {
    out <- sample(1:3, times, replace = TRUE)
    out[runif(times) < busy_prob] <- -10000
    return(out)
  }
  
  weight_data <- expand.grid(people = seq_len(n),
                             day = seq_len(day),
                             shift = seq_len(shift)) %>% 
    as_tibble() %>% 
    left_join(people_id,by = 'people') %>% 
    group_by(people) %>% 
    mutate(w = sample_fun(.env$day * .env$shift, busy_prob)) %>% 
    ungroup()
  
  return(weight_data)
}


# build and solve model
library(ompr.roi)
library('ROI.plugin.glpk')

assign_schedule <- function(data, w_per_shift, cont_w = TRUE) {
  n <- length(unique(data$people))
  day <- length(unique(data$day))
  shift <- length(unique(data$shift))
  # allow work two day in a row or not
  cont_w <- ifelse(cont_w, 10000, 1)
  
  weight <- function(people, day, shift){
    data %>% 
      filter(people == {{people}},
             day == {{day}},
             shift == {{shift}}) %>% 
      pull(w)
  }
  
  
  model <- MIPModel() %>% 
    add_variable(x[i, j, t], i= 1:n, j = 1:day, t= 1:shift, type = 'binary') %>% 
    # maximize preference
    set_objective(sum_expr(weight(i,j,t) * x[i,j,t], i = 1:n, j = 1:day, t = 1:shift)) %>% 
    # each shift, how many people work?
    add_constraint(sum_expr(x[i, j, t], i = 1:n) == w_per_shift, j = 1:day, t = 1:shift) %>% 
    # each people only work for 1 day
    add_constraint(sum_expr(x[i,j,t], t = 1:shift) <= 1, i = 1:n, j = 1:day) %>% 
    # people does not work x days in a row
    add_constraint(sum_expr(x[i,j,t] , t = 1:shift) + sum_expr(x[i, j+1, t], t = 1:shift)
                   <= cont_w, i = 1:n, j= 1:(day-1))
  
  result <- solve_model(model, with_ROI(solver = "glpk", verbose = TRUE))
  
  return(result)
}

  
get_schedule <- . %>% 
  get_solution(x[i,j, t]) %>% 
  select(-variable, people = i, day = j , shift = t) %>% 
  filter(value ==1) %>% 
  as_tibble()
  
  






