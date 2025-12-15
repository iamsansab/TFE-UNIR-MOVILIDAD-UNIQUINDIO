# TFE-UNIR-MOVILIDAD-UNIQUINDIO
Repositorio con los procesos de analítica de datos empleados en el diagnóstico de movilidad interna del campus, incluye los datos de campo y scripts en R utilizados.

# Análisis de ocupación de parqueaderos – Universidad del Quindío

Este repositorio contiene los datos de campo y los scripts desarrollados en R para el análisis de la ocupación de los parqueaderos de la Universidad del Quindío, en el marco del trabajo de grado de maestría enfocado en el estudio de la movilidad interna del campus universitario.

## 📍 Contexto del estudio
La Universidad del Quindío presenta una alta demanda de estacionamiento para vehículos y motocicletas, lo cual genera presiones operativas sobre la infraestructura existente y efectos indirectos sobre la movilidad interna y externa del campus. Con el fin de diagnosticar esta situación, se realizó una fase de campo basada en conteos sistemáticos de entradas y salidas en diferentes parqueaderos, en jornadas comprendidas entre las 6:30 a. m. y las 9:00 p. m.

## 📊 Información contenida
El repositorio incluye:

- Archivos en formato Excel con los registros de campo de:
  - Parqueaderos de vehículos
  - Parqueaderos de motocicletas
  - Conteos realizados en diferentes días (martes, miércoles y sábado)
- Scripts en R para:
  - Limpieza y estructuración de los datos
  - Cálculo de ocupación horaria y acumulada
  - Estimación del porcentaje de ocupación respecto a la capacidad instalada
  - Identificación de horas pico y periodos de saturación operativa
  - Construcción de curvas de demanda diaria
  - Clasificación de la criticidad operativa de los parqueaderos

## 🧠 Metodología de análisis
El análisis se basa en técnicas de analítica de datos aplicadas a estudios de transporte y estacionamiento, considerando:
- Conteo de entradas y salidas por intervalo horario
- Reconstrucción de la ocupación acumulada
- Comparación temporal entre días de observación
- Evaluación del nivel de presión sobre el sistema de estacionamiento

Los procesos fueron desarrollados en R, empleando librerías como `dplyr`, `tidyr`, `ggplot2`, `readxl` y `hms`.

## 📈 Resultados esperados
Los resultados derivados de este repositorio permiten:
- Identificar patrones de uso del estacionamiento
- Detectar periodos críticos de saturación
- Comparar el desempeño operativo entre parqueaderos
- Aportar insumos técnicos para la formulación de estrategias de gestión de la movilidad y del estacionamiento en el campus

## 📄 Uso académico
Este repositorio tiene fines exclusivamente académicos y de investigación. Los datos y scripts aquí contenidos forman parte del soporte técnico del trabajo de grado y pueden ser reutilizados o adaptados para estudios similares, citando adecuadamente la fuente.

---
Autor: Santiago Sabogal Correa
Programa de Maestría: Máster Universitario en Análisis y Visualización de Datos Masivos/ Visual Analytics and Big Data  
Universidad Internacional de La Rioja - Escuela Superior de Ingeniería y Tecnología
