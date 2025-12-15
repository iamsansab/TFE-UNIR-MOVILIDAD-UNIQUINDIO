#-----------------------------#
#    1. Cargar librerías      #
#-----------------------------#
library(readxl)
library(tidyverse)
library(lubridate)

#-----------------------------------------#
#    2. Funcion para procesar un día      #
#-----------------------------------------#
procesar_parqueadero <- function(archivo, dia, capacidad){
  
  df <- read_excel(archivo)
  
  df_long <- df %>% 
    pivot_longer(cols = everything(),
                 names_to = "hora",
                 values_to = "placa") %>%
    mutate(
      placa = gsub("[^A-Za-z0-9]", "", placa),
      placa = na_if(placa, ""),
      hora = str_to_lower(hora),
      hora = str_trim(hora),
      hora = str_replace_all(hora, "a.m.", "am"),
      hora = str_replace_all(hora, "a.m", "am"),
      hora = str_replace_all(hora, "p.m.", "pm"),
      hora = str_replace_all(hora, "p.m", "pm")
    ) %>% 
    drop_na()
  
  ocupacion <- df_long %>%
    group_by(hora) %>%
    summarise(ocupacion = n_distinct(placa), .groups = "drop") %>%
    mutate(
      hora_parsed = parse_date_time(hora, orders = "I:M p"),
      porcentaje = (ocupacion / capacidad) * 100,
      dia = dia
    ) %>%
    arrange(hora_parsed)
  
  return(ocupacion)
}

#-----------------------------------------#
#   3. Procesamiento de 3 días            #
#-----------------------------------------#
capacidad <- 51   

martes <- procesar_parqueadero(
  "z8_exterior_calle11N_martes.xlsx",
  dia = "Martes",
  capacidad = capacidad
)

miercoles <- procesar_parqueadero(
  "z8_exterior_calle11N_miercoles.xlsx",
  dia = "Miércoles",
  capacidad = capacidad
)

sabado <- procesar_parqueadero(
  "z8_exterior_calle11N_sabado.xlsx",
  dia = "Sábado",
  capacidad = capacidad
)

# Unir todo en un solo dataset
ocupacion_total <- bind_rows(martes, miercoles, sabado) %>%
  arrange(hora_parsed)

#--------------------------------------------------------------#
#   4. Gráfico de ocupación comparando los tres días           #
#--------------------------------------------------------------#
ggplot(ocupacion_total,
       aes(x = hora_parsed,
           y = porcentaje,
           color = dia)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  geom_hline(yintercept = 100,
             linetype = "dashed",
             color = "black") +
  scale_x_datetime(date_labels = "%H:%M") +
  labs(
    title = "Comparación horaria de ocupación del parqueadero\nExterior Calle 11 Norte",
    x = "Hora del día",
    y = "Porcentaje de ocupación",
    color = "Día de observación"
  ) +
  theme_minimal()

#------------------------------------------#
#   5. Hora inicio saturación              #
#------------------------------------------#
inicio_saturacion <- ocupacion_total %>%
  filter(porcentaje >= 90) %>%
  group_by(dia) %>%
  summarise(
    hora_inicio_saturacion = min(hora_parsed),
    .groups = "drop"
  )

#--------------------------------------------------#
#   6. Ocupación promedio y condición operativa    #
#--------------------------------------------------#
condicion_operativa <- ocupacion_total %>%
  group_by(dia) %>%
  summarise(
    ocupacion_media = mean(porcentaje),
    ocupacion_maxima = max(porcentaje),
    horas_saturadas = sum(porcentaje >= 90) * 0.25,
    .groups = "drop"
  ) %>%
  mutate(
    condicion = case_when(
      ocupacion_media < 70 ~ "Baja",
      ocupacion_media < 85 ~ "Media",
      ocupacion_media < 95 ~ "Alta",
      TRUE ~ "Crítica"
    )
  )