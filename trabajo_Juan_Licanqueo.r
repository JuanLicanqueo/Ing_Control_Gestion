#========================================#
# Instalación de los paquetes a ocupar.
#========================================#
install.packages("tseries")
install.packages("quantmod")
#=========================================#
# Instalación de las librerias a ocupar.
#=========================================#
library(tidyverse)
library(lubridate)
library(quantmod)
library(tseries)
library(xts)
library(zoo)
library(reshape)
library(ggplot2)

# Limpiamos memoria
remove(list = ls())

# definimos directorio de trabajo
setwd('C:/Users/Juan/Desktop/Series_de_Tiempo/')
getwd()

#### CARGAMOS DATOS ####
# Cargamos los datos de YAHOO! FINANCE del indice del precio del consumidor de  MEXICO desde el año 2006 a la fecha.

getSymbols('^MXX', src = 'yahoo', from = '2006-01-01',
           to = Sys.Date(), periodicity = 'daily',
           format = 'xts')

names(MXX) <- c('Apertura', 'Máximo', 'Mínimo', 'Cierre','Volumen', 'Ajuste')
View(MXX)

##### Guardamos en una variable el precio de cierre. #####
IPC_CIERRE <- MXX$Cierre
View(IPC_CIERRE)

# Gráficamos los datos seleccionados.
plot(IPC_CIERRE,
     main = 'IPC MEXICO: Precio de cierre.',
     col = '#178FE6')

# Calculamos el retorno discreto.
IPC_CIERRE_DISC = ROC(IPC_CIERRE, type = 'discret')

# Visualizamos los 5 primeros registros del retorno discreto.
head(IPC_CIERRE_DISC, 5)

# Gráficamos los datos calculados del retorno discreto.
plot(IPC_CIERRE_DISC,
     main = 'IPC MEXICO: Retorno discreto.' )

#========================================================================#
# El gráfico del retorno discreto muestra que el proceso es estacionario.
#========================================================================#

# Calculamos el retorno logaritmico.
IPC_CIERRE_LOG = ROC(IPC_CIERRE, type = 'continuous')

# Visualizamos los primeras 5 del retorno logaritmico.
head(IPC_CIERRE_LOG, 5)

# Gráficamos los datos calculados del retorno logaritmico.
plot(IPC_CIERRE_LOG,
     main = 'IPC MEXICO: Retorno logaritmico')
#===========================================================================#
# El gráfico del retorno logaritmico muestra que el proceso es estacionario.#
# Para estimar el modelo se utilizara este retorno.                         #
#===========================================================================#

#### Guardamos el logaritmo del precio de cierre del IPC. ####
IPC_CIERRE_log = log(IPC_CIERRE)

# Gráficaremos la función autocorrelación simple.
acf(na.omit(IPC_CIERRE))
#===========================================================================#
# Del gráficos inferimos que hay correlacion de los diferentes rezagos por  # # y estos son significativos.                                               #
#===========================================================================#

# Gráficaremos la función autocorrelación parcial.
pacf(na.omit(IPC_CIERRE))
#===========================================================================#
# Del gráficos inferimos que el modelo es AR(1).                            #
#===========================================================================#

#-------------------------------------------------------------------------#
#### Generamos el Modelo AR(1) ####
modelo_1 = arima(IPC_CIERRE_log, order = c(1,0,0))
modelo_1
#===========================================================================#
# El intercepto del AR(1) es 0.99 ~ 1, esto significa que beta es igual 1 y # # sigue paseo aleatorio ademas esto implica que la serie no es estacionaria.#
#===========================================================================#

#-------------------------------------------------------------------------#

#### Calcularemos la calidad del modelo_1. ####
confint(modelo_1)
AIC(modelo_1)
BIC(modelo_1)

#### Calcularemos el error del modelo_1. ####
Errores_ABS_1 = abs(residuals(modelo_1))
summary(Errores_ABS_1)
#===============================================#
# El valor del error absoluto medio es 0.005934
#===============================================#

#-------------------------------------------------------------------------#

                     #==============================#
                     #   IDENTIFICACIÓN DEL MODELO  #
                     #==============================#

#### Guardamos la cantidad de registros del IPC.####
Cant_Regist <- dim(IPC_CIERRE)[1]
Cant_Regist

#-------------------------------------------------------------------------#
#### TEST DICKEY-FULLER ####
# Aplicaremos el test de DICKEY-FULLER al logaritmo del precio de cierre.
adf.test(na.omit(IPC_CIERRE_log), alternative = 'stationary') 
# p-value = 0.2155
# el p-value del logaritmo de la serie no es significativo por lo que no se rechaza H0 (ERROR TIPO 1)
# lo que implica que el logaritmo de la serie no es estacionaria como ya lo habiamos verificado anteriormente.

#-------------------------------------------------------------------------#
#### PRIMERA DIFERENCIACIÓN ####
# Calcularemos la primera diferencia al logaritmo del precio del cierre para encontrar la estacionaridad.
Prim_Dif = diff(IPC_CIERRE_log)
# Ahora aplicamos el test de DICKEY-FULLER a la serie diferenciada
adf.test(na.omit(Prim_Dif[2:Cant_Regist,]), alternative = 'stationary')
# p-value = 0.01
# el p-value de la serie diferenciada es significativa por lo cual rechazamos H0 (ERROR TIPO 2)
# lo que implica que el logaritmo de la serie diferenciada es estacionaria 

#-------------------------------------------------------------------------#

#### ORDEN DE LA SERIE DIFERENCIADA ####
# Identificaremos el orden del modelo de la serie diferenciada del logaritmo del precio de cierre

# Gráficaremos la función de autocorrelación simple para la serie diferenciada para estimar el q del MA
acf(na.omit(Prim_Dif[2:Cant_Regist,]),
    main = 'Autocorrelación 
    Primera serie diferenciada (MA)')
# Encontramos un rezago significativo por lo cual para MA el valor de q de nuestro modelo sera 1

# Gráficaremos la función de autocorrelación parcial para la serie diferenciada para estimar el p del AR 
pacf(na.omit(Prim_Dif[2:Cant_Regist,]),
    main = 'Autocorrelación parcial 
    Primera serie diferenciada (AR)')
# Encontramos tres rezagos significativos por lo cual para AR el valor de p de nuestro modelo sera 3

# Como diferenciamos una vez la serie d tomara el valor de 1
#### Entonces nuestro modelo tendria el siguiente orden ####

                     #==============#
                     # ARIMA(3,1,1) #
                     #==============#

#--------------------------------------------------------------------------#

             #==============================#
             ####  ESTIMACIÓN DEL MODELO ####
             #==============================#

# Estimaremos la serie del logaritmo del precio con el modelo encontrado
modelo_2 = arima(IPC_CIERRE_log, order = c(3,1,1))
modelo_2

# Verificamos en el gráfico si existe ruido blanco según la significancia de lo estimado
tsdiag(modelo_2)
# Con el gráfico vemos que hay ruido blanco

# Aplicamos el test de Ljung-Box para verificar que es ruido blanco
Box.test(residuals(modelo_2), type = 'Ljung-Box')
# p-value = 0.9247
# Esto implica que no rechazamos H0(ERROR TIPO 1) ya que el p-value no es significativo 
# Por ende las autocorrelaciones son independientes y además existe ruido blanco

#-------------------------------------------------------------#
              #====================================#
              #### PRONOSTICANDO CON EL MODELO ####
              #===================================#

# Realizaremos 10 predicciones para evaluar que tan preciso es nuestro modelo

modelo_2_pred <- forecast::forecast(modelo_2, h = 10, level = c(99.5))
modelo_2_pred

#Point Forecast  Lo 99.5  Hi 99.5
#4202       10.73367 10.69995 10.76739
#4203       10.73368 10.68428 10.78309
#4204       10.73379 10.67344 10.79414
#4205       10.73381 10.66475 10.80286
#4206       10.73380 10.65705 10.81056
#4207       10.73380 10.65001 10.81759
#4208       10.73380 10.64351 10.82409
#4209       10.73380 10.63745 10.83015
#4210       10.73380 10.63174 10.83586
#4211       10.73380 10.62635 10.84126

#-------------------------------------------------------------#
         #===========================================#
         #### COMPARANDO PRONOSTICO CON DATA REAL ####
         #===========================================#

# Guardamos 200 registros para realizar pronosticos.
Data_Pred <- IPC_CIERRE_log[(Cant_Regist - 199):Cant_Regist,]
dim(Data_Pred)

#-------------------------------------------------------------#
#### DATOS DE ENTRENAMIENTO ####
# De los 200 registros separamos 150 para generar 50 pronosticos.
Datos_Forecast <- Data_Pred[1:(dim(Data_Pred)-50)]
dim(Datos_Forecast)

# Generamos el modelo con los 150 datos seleccionados.
Mod_Dat_Forec <- arima(Datos_Forecast, order = c(3,1,1))

# Predecimos 50 datos con el modelo para comparar con los reales.
Forecast_IPC <- forecast::forecast(Mod_Dat_Forec, h = 50, level = c(99.5))

# Pasamos los datos predichos a dataframe.
Forecast_IPC_df <- Forecast_IPC %>% 
  sweep::sw_sweep(.) %>% 
  filter(key == "forecast") %>% 
  select(-key)
# Verificamos que los datos fueron pasados a dataframe.
class(Forecast_IPC_df)

#-------------------------------------------------------------#
#### DATOS DE PRUEBA ####
# Guardamos los 50 registros reales para comparar con los pronosticados.
Datos_Real <- Data_Pred[((dim(Datos_Forecast)[1]) + 1) : (dim(Data_Pred)[1]),]
dim(Datos_Real)

# Generamos una función para pasar de formato xts a df.
xts_to_df <- function(data_xts){
 df_t <- data.frame(fecha = (index(data_xts)),
                    valor = coredata(data_xts))
  colnames(df_t) <- c('Fecha', 'Cierre')
  df_t
}

# Pasamos los datos reales a dataframe.
Datos_Real_df <- xts_to_df(Datos_Real)

# Verificamos que los datos fueron pasados a dataframe.
class(Datos_Real_df)

#-------------------------------------------------------------#
#### CREAR DATAFRAME CON LA DATA REAL Y PREDICHA ####
#Juntaremos la data real y predicha en un solo dataframe para poder comparar los resultados del modelo.
Real_vs_Prediccion <- cbind(Datos_Real_df, Forecast_IPC_df$value) %>% 
                            select(Fecha,
                                   'Precio_Cierre_Real' = Cierre,
                                   'Precio_Cierre_Predicho'= 'Forecast_IPC_df$value')
#-------------------------------------------------------------#
#### GRÁFICAREMOS LOS DATOS OBTENIDOS ####
# Utilizaremos una gráfica de linea para comparar que tan preciso fue el modelo con respecto a los datos reales.
ggplot(Real_vs_Prediccion) +
  geom_line(aes(x = Fecha, y = Precio_Cierre_Real),
            color = '#46397D') +
  geom_point(aes(x = Fecha, y = Precio_Cierre_Real),
             color = '#FF910B') +
  geom_line(aes(x = Fecha, y = Precio_Cierre_Predicho),
            color = '#A3596E') +
  geom_point(aes(x = Fecha, y = Precio_Cierre_Predicho),
             color  = '#306812') +
  theme_linedraw() +
  labs(x = 'Periodos Analizados',
       y = 'Precio de Cierre',
       title = 'Comparación de los Precios Reales vs los Predichos',
       subtitle = 'Fuente de datos: IPC MEXICO - yahoo finance') 
