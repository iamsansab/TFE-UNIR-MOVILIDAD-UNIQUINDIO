#-----------------------------#
#    1. Cargar librerías      #
#-----------------------------#
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(ggplot2)
library(hms)
#-------------------------------------------------#
#    2. Función para procesar un día (motos)      #
#-------------------------------------------------#
procesar_motos <- function(ruta_archivo, dia, capacidad) {
  
  raw <- read_excel(ruta_archivo, col_names = FALSE)
  
  encabezado <- raw[1:2, ]
  datos <- raw[-c(1,2), ]
  
  col_info <- tibble(
    col_id = colnames(raw),
    tipo = as.character(unlist(encabezado[1, ])),
    hora_excel = as.numeric(unlist(encabezado[2, ]))
  ) %>%
    filter(tipo %in% c("ENTRA", "SALE")) %>%
    mutate(
      hora = as_hms(hora_excel * 24 * 3600),
      dia = dia
    )
  
  datos_long <- datos %>%
    pivot_longer(
      cols = everything(),
      names_to = "col_id",
      values_to = "placa"
    ) %>%
    filter(!is.na(placa))
  
  resumen <- datos_long %>%
    left_join(col_info, by = "col_id") %>%
    group_by(dia, hora, tipo) %>%
    summarise(n = n(), .groups = "drop") %>%
    pivot_wider(
      names_from = tipo,
      values_from = n,
      values_fill = 0
    ) %>%
    arrange(hora) %>%
    mutate(
      ocupacion = cumsum(ENTRA - SALE),
      capacidad = capacidad,
      porcentaje_ocupacion = (ocupacion / capacidad) * 100
    )
  
  return(resumen)
}


#-------------------------------------------#
#    3. Procesamiento de los tres dias      #
#-------------------------------------------#
capacidad_motos <- 270  

martes     <- procesar_motos("z3_motos_ingenieria_martes.xlsx", "Martes", capacidad_motos)
miercoles  <- procesar_motos("z3_motos_ingenieria_miercoles.xlsx", "Miércoles", capacidad_motos)
sabado     <- procesar_motos("z3_motos_ingenieria_sabado.xlsx", "Sábado", capacidad_motos)

datos_motos <- bind_rows(martes, miercoles, sabado)
#--------------------------------#
#    4. Hora pico principal      #
#--------------------------------#
hora_pico <- datos_motos %>%
  group_by(dia) %>%
  slice_max(ocupacion, n = 1, with_ties = FALSE) %>%
  select(dia, hora_pico = hora, ocupacion_max = ocupacion)
#---------------------------------------#
#    5. Inicio de saturación (>90%)     #
#---------------------------------------#
inicio_saturacion <- datos_motos %>%
  filter(porcentaje_ocupacion >= 90) %>%
  group_by(dia) %>%
  summarise(
    inicio_saturacion = min(hora),
    .groups = "drop"
  )
#--------------------------------#
#    6. Horas en saturación      #
#--------------------------------#
horas_saturadas <- datos_motos %>%
  filter(porcentaje_ocupacion >= 90) %>%
  group_by(dia) %>%
  summarise(
    intervalos = n(),
    horas_saturadas = intervalos * 0.25,
    .groups = "drop"
  )
#----------------------------------------#
#    7. Ocupación promedio y máxima      #
#----------------------------------------#
ocupacion_resumen <- datos_motos %>%
  group_by(dia) %>%
  summarise(
    ocupacion_media = mean(porcentaje_ocupacion),
    ocupacion_maxima = max(porcentaje_ocupacion),
    .groups = "drop"
  )
#--------------------------#
#    8. Tabla resumen      #
#--------------------------#
tabla_resumen_motos <- ocupacion_resumen %>%
  left_join(hora_pico, by = "dia") %>%
  left_join(inicio_saturacion, by = "dia") %>%
  left_join(horas_saturadas, by = "dia") %>%
  mutate(
    condicion_operativa = case_when(
      ocupacion_media < 60 ~ "Subutilizado",
      ocupacion_media < 85 ~ "Operación estable",
      TRUE ~ "Alta presión / Saturado"
    )
  )

tabla_resumen_motos
#--------------------------------#
#    8. Grafico de ocupacion     #
#--------------------------------#
ggplot(datos_motos, aes(x = hora, y = porcentaje_ocupacion, color = dia)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 1.3) +
  scale_x_time(
    breaks = hms::as_hms(c("06:00:00",
                           "12:00:00",
                           "18:00:00",
                           "21:00:00")),
    labels = scales::time_format("%H:%M")
  ) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "black") +
  labs(
    x = "Hora del día",
    y = "Ocupación (%)",
    color = "Día",
    title = "Comparación horaria de ocupación del parqueadero de motos\n del Centro de Investigaciones Biomédicas",
  ) +
  theme_minimal()



