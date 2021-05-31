library(tidyverse)

read_data <- function(file) {
  
  tmp <- read.delim(file, as.is = T)  
  
  # item_id
  item_id_idx = grepl(tmp[, 'Property'], pattern = 'item_id')
  item_id = tmp[item_id_idx, 'Value']
  
  # item_descr
  item_descr_idx = grepl(tmp[, 'Property'], pattern = 'item_descr')
  item_descr = tmp[item_descr_idx, 'Value']
  
  # item_cat
  item_cat_idx = grepl(tmp[, 'Property'], pattern = 'item_cat')
  item_cat = tmp[item_cat_idx, 'Value']
  
  tmp <- tmp[!(item_id_idx | item_descr_idx | item_cat_idx), ] %>% 
    mutate(item_id = item_id, 
           item_descr = item_descr, 
           item_cat = item_cat) %>% 
    separate(Value, into = c('Value_Orig','Unit'), sep = ' ') %>% 
    mutate(Value = gsub(Value_Orig, pattern = '[.]', replacement = '')) %>%  
    mutate(Value = as.numeric(gsub(Value, pattern = '[,]', replacement = '.')))
  
  return(tmp)
}

files = list.files(path = 'parsed_items/', 
                   pattern = '', full.names = T)
df <- NULL
for(file in files) {
  df = rbind(df, read_data(file))
}

df <-
  df %>% 
  select(item_id, item_cat, item_descr, Property, Value, Unit) %>% 
  mutate(Property = ifelse(Property == 'gesättigte Fettsäuren', 
                           'Gesättigte Fettsäuren',
                           Property)) %>% 
  mutate(item_cat = case_when(
    item_cat == 'Reis, Cerealien, Getreide und Getreideprodukte' ~ 'Cerealien, Getreide und Getreideprodukte, Reis', 
    item_cat == 'Fleisch- und Wurstwaren' ~ 'Wurst, Fleischwaren',
    item_cat == 'Fette, Öle, Butter, Schmalz' ~ 'Öle, Fette, Butter, Schmalz, Talg', 
    item_cat == 'Pilze, Kartoffeln und Kartoffelerzeugnisse, stärkereiche Pflanzenteile' ~ 'Kartoffeln und Kartoffelerzeugnisse, stärkereiche Pflanzenteile, Pilze', 
    T ~ item_cat
  )) %>% 
  mutate(Unit = ifelse(grepl(Property, pattern = 'Broteinheit'), 'BE', Unit)) %>% 
  mutate(Value_Scale = case_when(
    Unit == 'µg' ~ Value / 100 / 1e6,
    Unit == 'mg' ~ Value / 100 / 1e3,
    Unit %in% c('kcal', 'g', 'BE') ~ Value / 100,
    Unit == 'kg' ~ Value / 100 * 1e3,
    T ~ Value
  ))

df %>% 
  write_tsv(., path = 'BLS.tsv')

properties <- 
  tibble(Property = levels(as.factor(df$Property))) %>% 
  write_tsv(., path = 'BLS.Property.tsv')

warnings()