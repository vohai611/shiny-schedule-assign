# Utilities to load user input data (xlsx)
read_all_sheet <- function(path){
  sheet <- readxl::excel_sheets(path)
  map_df(sheet, ~ {
    readxl::read_excel(path, sheet = .x, col_types = "numeric") %>%
      mutate(name = .x, .before = 1)
  }) %>%
    group_by(name) %>%
    mutate(people = cur_group_id()) %>%
    ungroup() %>% 
    replace(is.na(.),-10000) %>%  
  pivot_longer(cols =  c(-name,-shift, -people), names_to = "day", values_to = 'w') %>% 
  mutate(day = parse_number(day))
}  

read_all_sheet <- possibly(read_all_sheet, otherwise = NA)

# Prepare template for user to download from random data

template_download <- function(.tbl) {
  df <- .tbl %>% 
    mutate(w = if_else(w == -10000, "Busy", as.character(w))) %>% 
    pivot_wider(c(name, shift), names_from = day, values_from = w, names_prefix = "Day ")
  
  df %>% 
    split(df$name) %>% 
    map(~select(.x,-name)) %>% 
    return()
}