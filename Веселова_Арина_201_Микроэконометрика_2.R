
# Подключим необходимые библиотеки
library("glmx")                                                  # пакет, позволяющий оценивать пробит
# модель с гетероскдестичной 
# случайной ошибкой
library("zoo")  
library("lmtest")                                                # дополнительные тесты
library("numDeriv")                                              # численное дифференцирование
install.packages("sampleSelection")
library("maxLik") 
library("miscTools") 
library("sampleSelection")                                       # встроенный датафрейм для
# выполнения домашнего задания
library("mgcv") 
library("nlme") 
library("GJRM")                                                  # система бинарных уравнений

# Отключим scientific notation
options(scipen = 999)

# Подключим встроенный датафрейм, содержащий информацию
# о характеристиках американских женщин и их трудовом
# статусе в 1975-1976 годах
data(Mroz87)

# Краткое описание:
help(Mroz87)
# lfp - бинарная переменная, принимающая значение 1
#       если иженщина работает и 0 - в противном случае
# hours - количество проработанных часов за год
# kids5 - количество детей младше 6 лет
# kids618 - количество несовершеннолетних детей
#           старше пяти лет
# age - возраст женщины
# educ - число лет, потраченных женщиной на
#        получение образования
# wage - почасовая зарплата женщины
# hushrs - количество часов, проработанных мужем женщины
# husage - возраст мужа женщины
# huseduc - число лет, потраченных муженм женщины на
#           получение образования
# huswage - зарплата мужа женщины
# faminc - доход семьи женщины
# mtr - налоговая нагрузка на женщину
# fatheduc - число лет, потраченных отцом женщины на
#            получение образования
# motheduc - число лет, потраченных отцом женщины на
#            получение образования
# unem - безработица в регионе проживания женщины
# city - бинарная переменная, принимающая значение 1
#        если женщина живет в городе и 0 - иначе
# exper - рабочий стаж женщины в годах
# nwifeinc - доход семьи женщины за вычетом ее дохода
# wifecoll - бинарная переменная, принимающая значение 1
#            если женщина посещала колледж и 0 - иначе
# huscoll - бинарная переменная, принимающая значение 1
#           если муж женщины посещал колледж и 0 - иначе

head(Mroz87)



## 2.1 ##

# Для удобства отключим 
# экспоненциальную запись чисел
options(scipen = 999)

# Подключим дополнительные библиотеки
install.packages("crch")
library("crch")                          # регрессия с усечением

install.packages("hpa")
library("hpa")                           # моменты усеченного 
# нормального распределения

# Оценим модель Тобина
model_tb <- crch(wage ~ age + educ + exper,      # формула
                 data = Mroz87,                           # данные                       
                 left = 0,                          # нижнее (левое) усечение
                 truncated = FALSE,                  # модель Тобина
                 dist = "gaussian")                  # распределение случайной
# ошибки
                                   # посмотрим результат
est_tb <- coef(model_tb)                             # достанем оценки
coef_tb <- est_tb[-length(est_tb)]                   # оценки регрессионных
# коэффициентов
sigma_tb <- exp(est_tb[length(est_tb)])              # достаем оценку 
# стандартного отклонения



## 2.4 ##
Arina <- data.frame(age = 21, educ = 14, exper = 2.5)

## A)
wage_est <- predict(model_tb,
                    newdata = Arina)
wage_est

## Б)
epsilon_E <- truncatedNormalMoment(k = 1,                      # момент
                                   x_lower = tr - spend_est,   # нижнее усечение
                                   x_upper = Inf,              # верхние усечение
                                   mean = 0,                   # математическое ожидание
                                   sd = sigma_tb)              # стандартное отклонение


# вручную
prob_est <- pnorm(wage_est / sigma_tb)

a <- (0 - wage_est) / sigma_tb
lambda <- dnorm(a) / (1 - pnorm(a))
epsilon_E <- sigma_tb * lambda
# посчитаем E(spend* | spend* >= tr_left)
wage_est_cond <- wage_est + epsilon_E
# рассчитаем E(spend) = P(spend* >= tr_left) * E(spend* | spend* >= tr_left)
#                       P(spend* < tr_left) * E(spend* | spend* < tr_left) =
#                       P(spend* >= tr_left) * E(spend* | spend* >= tr_left) +
#                       (1 - P(spend* < tr_left)) * tr_left
wage_est_cens <- prob_est * wage_est_cond + (1 - prob_est) * 0
wage_est_cens

## В)
prob_est



## 2.5 ##

## A)
coef_tb[2]

## Б)
ME_cens <- coef_tb[2] * prob_est
ME_cens

## В)
ME_prob <- coef_tb[2] / sigma_tb * dnorm(wage_est / sigma_tb)
ME_prob



## 2.6 ##
# Оценим модель Тобина с квадратичной зависимостью от возраста
model_tb_age2 <- crch(wage ~ age + I(age ^ 2) + educ + exper,      
                      data = Mroz87,                                
                      left = 0,                          
                      truncated = FALSE,                  
                      dist = "gaussian")   
summary(model_tb_age2)

est_tb_age2 <- coef(model_tb_age2 )                             # достанем оценки
coef_tb_age2  <- est_tb_age2 [-length(est_tb_age2 )]                   # оценки регрессионных
# коэффициентов
sigma_tb_age2  <- exp(est_tb_age2 [length(est_tb_age2 )])              # достаем оценку 
# стандартного отклонения


## A)
coef_tb_age2[2] + 2 * coef_tb_age2[3] * Arina[1]

## Б)
(coef_tb_age2[2] + 2 * coef_tb_age2[3] * Arina[1]) * pnorm(predict(model_tb_age2, newdata = Arina) / sigma_tb_age2)


## В)
(coef_tb_age2[2] + 2 * coef_tb_age2[3] * Arina[1]) / sigma_tb_age2 * dnorm(predict(model_tb_age2, newdata = Arina) / sigma_tb_age2)

## 2.7 ##
model_htobit <- crch(wage ~ age + educ + exper|       
                       age + kids5,   
                     data = Mroz87,                                
                     left = 0,                          
                     link.scale = "log")    
summary(model_htobit)

# Осуществим тест на гомоскедастичность:
# H0: tau = 0
library("lmtest")  
lrtest(model_htobit, model_tb)



## 3.1 ##
library("maxLik") 
library("miscTools") 
library("sampleSelection") 
# метода Хекмана, основанный на ММП
model_mle <- selection(                              
  selection = lfp ~ age + kids5,                    
  outcome = wage ~ age + educ + exper,                  
  data = Mroz87,                                         
  method = "ml")                                    
summary(model_mle)

coef_mle <- coef(model_mle, part = "outcome")        # сохраним оценки коэффициентов
rho_mle <- model_mle$estimate["rho"]                 # оценка корреляции между
# случайными ошибками
sigma_mle <- model_mle$estimate["sigma"]             # стандартное отклонение
# случайной ошибки



## 3.3 ##
# метода Хекмана, основанного на
# двухшаговой процедуре
model_2st <- selection(                              
  selection = lfp ~ age + kids5,                    
  outcome = wage ~ age + educ + exper,                  
  data = Mroz87,                                          
  method = "2step")                                  # метод расчета двухшаговая процедура
summary(model_2st)                                   # результат оценивания
coef_2st <- coef(model_2st, part = "outcome")        # сохраним оценки коэффициентов
coef_2st <- coef_2st[-length(coef_2st)]              # удалим лишний коэффициент
rho_2st <- model_2st$rho                             # оценка корреляции между
# случайными ошибками

data.frame("Heckman MLE" = coef_mle,                 
           "Heckman 2step" = coef_2st)



## 3.5 ##
Arina2 <- data.frame(age = 21, educ = 14, exper = 2.5, kids5=0)

wage_star <- predict(model_mle, 
                     newdata = Arina2, 
                     part = "outcome",                 
                     type = "unconditional") 

# оценим линейный индекс
work_li <- predict(model_mle, 
                   newdata = Arina2, 
                   part = "selection",                   
                   type = "link")                      
# E(y*|z = 1)
# Оценим E(y*|z) вручную:
lambda_est_1 <- dnorm(work_li) / pnorm(work_li)         
lambda_est_2 <- dnorm(work_li) / pnorm(-work_li)
wage_star + rho_mle * model_mle$estimate["sigma"] * lambda_est_1           # E(y*|z = 1)

# Рассчитаем оценку условного математического 
# ожидания зависимой переменной основного уравнения,
# то есть E(y*|z)
wage_cond <- predict(model_mle, 
                     newdata = Arina2, 
                     part = "outcome",                   # для основного уравнения
                     type = "conditional")               # условные предсказания 
wage_cond[2]                                             

# E(y*|z = 0)
# вручную
wage_star - rho_mle * model_mle$estimate["sigma"] * lambda_est_2 
# рассчитано
wage_cond[1]  



## 3.5 ##
coef_s_est <- coef(model_mle)[1:3]
age_ME1 <- coef_mle["age"] - rho_mle * sigma_mle * (work_li * lambda_est_1 + lambda_est_1 ^ 2) *coef_s_est["age"]
age_ME1

age_ME2 <- coef_mle["age"] + rho_mle * sigma_mle * (work_li * lambda_est_2 - lambda_est_2 ^ 2) * coef_s_est["age"]
age_ME2
