library(readr)



data_load <- function(filename){
  #try catch
  df <- read_delim(filename, delim = ";", 
                   col_types = cols(
                     Zuzanna = col_logical(),
                     Julia = col_logical(),
                     Lena = col_double(),
                     Maja = col_double(),
                     Hanna = col_double(),
                     Zofia = col_double(),
                     Amelia = col_double(),
                     Alicja = col_double(),
                     Aleksandra = col_logical(),
                     Natalia = col_logical(),
                     Oliwia = col_logical(), 
                     Maria = col_logical(),
                     Wiktoria = col_double(),
                     Emilia = col_double(),
                     Antonina = col_double(),
                     Laura = col_double(),
                     Anna = col_double(),
                     Nadia = col_logical(),
                     Pola = col_logical(),
                     Liliana = col_logical(),
                     Nikola = col_logical(),
                     Gabriela = col_logical()
                   ))
  df
}
