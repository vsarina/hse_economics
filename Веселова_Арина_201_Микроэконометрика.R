# filename <- file.choose()
# Canteen_clean <- readRDS(filename)


data <- readRDS("/Users/Arina/Desktop/Вышка/Микроэконометрика/homework.rds")
head(data)




## 2.1 ##
lin_prob = lm(sub ~ age + series + TV + I(age ^ 2) + age * series, data = data)
summary(lin_prob)




##2.3##
library("margins") 
lin_prob.me <- margins(model = lin_prob,                 # объект, возвращаемый glm(), в котором   
                     # хранятся полученные нами ранее оценки
                     variables = NULL,                     # переменная, по которой считается
                     # предельный эффект: можно указать вектор
                     # переменных или поставить NULL (по умолчанию), 
                     # чтобы получить предельные эффекты сразу по 
                     # всем независимым переменным
                     type = "response")                    # на что строится предельный эффект:
# вероятность или линейный индекс

# Посмотрим оценки предельных эффектов на вероятность подписки
mean(lin_prob.me$dydx_TV)             # предельный эффект для TV
mean(lin_prob.me$dydx_age)            # для age
mean(lin_prob.me$dydx_series)         # для series




##2.4##
# Построим 95% бутстрапированный доверительный 
# интервал для регрессионных коэффициентов
boot.iter <- 100                                           # число бутстрап итераций
coef.lm <- coef(lin_prob)                                  # МНК оценки
coef.boot <- matrix(NA,                                    # матрица, в которую будем сохранять
                    nrow = boot.iter,                      # оценки коэффициентов
                    ncol = length(coef.lm))                          
colnames(coef.boot) <- names(coef.lm)
head(coef.boot)

n <- length(data)
h <- data
for(i in 1:boot.iter)         
{
  h.rows.ind <- sample(1:n, n, replace = TRUE)             # случайным образом отбираем
  # строки датафрейма h
  h.boot <- h[h.rows.ind, ]                                # формируем новый датафрейм
  # из выбранных строк h
  model.boot <- lm(formula = formula(lin_prob),            # оцениваем модель по      
                   # новой выборке
                   data = h.boot)                
  coef.boot[i, ] <- coef(model.boot)                       # получаем оценки коэффициентов
}
head(coef.boot)


# Рассмотрим бутстрапированный ДИ 
# для коэффициента при 'age'
q.L.boot.age <- quantile(coef.boot[, "age"], 0.025)             # левая граница
q.R.boot.age <- quantile(coef.boot[, "age"], 0.975)             # правая граница


# Рассмотрим бутстрапированный ДИ 
# для коэффициента при 'series'
q.L.boot.series <- quantile(coef.boot[, "series"], 0.025)             # левая граница
q.R.boot.series <- quantile(coef.boot[, "series"], 0.975)             # правая граница


# Рассмотрим бутстрапированный ДИ 
# для коэффициента при 'TV'
q.L.boot.TV <- quantile(coef.boot[, "TV"], 0.005)             # левая граница
q.R.boot.TV <- quantile(coef.boot[, "TV"], 0.975)             # правая граница


# Рассмотрим бутстрапированный ДИ 
# для коэффициента при 'I(age^2)'
q.L.boot.age2 <- quantile(coef.boot[, "I(age^2)"], 0.025)             # левая граница
q.R.boot.age2 <- quantile(coef.boot[, "I(age^2)"], 0.975)             # правая граница


# Рассмотрим бутстрапированный ДИ 
# для коэффициента при 'I(age * series)'
q.L.boot.age_series <- quantile(coef.boot[, "I(age * series)"], 0.025)             # левая граница
q.R.boot.age_series <- quantile(coef.boot[, "I(age * series)"], 0.975)             # правая граница


Feature <- c("age", "series", "TV", "age^2", "age * series")
Left_quantile <- c(q.L.boot.age, q.L.boot.series, q.L.boot.TV, q.L.boot.age2, q.L.boot.age_series)
Right_quantile <- c(q.R.boot.age, q.R.boot.series, q.R.boot.TV, q.R.boot.age2, q.R.boot.age_series)

df <- data.frame(Feature, Left_quantile, Right_quantile)

print (df)




##2.5##
# Робастные ошибки в форме Уайта.
library(estimatr)
reg_hc = lm_robust(data = data,
                   sub ~ age + series + TV + I(age ^ 2) + I(age * series), se_type = "HC0")
summary(reg_hc)



##3.1##
# Пробит модель
model.probit <- glm(formula = sub ~ age + series + TV + I(age ^ 2) + age * series,   
                    data = data,                              
                    family = binomial(link = "probit"))    
summary(model.probit)                                      # визуализация результата



##3.3##
Arina <- data.frame(age=21,
                    series=10,
                    TV=0,
                    'age^2' = 441,
                    'age * series)' =210)

prob.Arina <- predict(model.probit,                        # объект возвращаемый glm()
                      newdata = Arina,                     # датафрейм, с использованием значений
                      # которого будут предсказаны вероятности
                      type = "response")                   # предсказываем вероятности
print(prob.Arina)


##3.4##
probit.me <- margins(model = model.probit,                 # объект, возвращаемый glm(), в котором   
                     # хранятся полученные нами ранее оценки
                     variables = NULL,                     # переменная, по которой считается
                     # предельный эффект: можно указать вектор
                     # переменных или поставить NULL (по умолчанию), 
                     # чтобы получить предельные эффекты сразу по 
                     # всем независимым переменным
                     type = "response")                    # на что строится предельный эффект:
# вероятность или линейный индекс

# Посмотрим оценки предельных эффектов на вероятность подписки
mean(probit.me$dydx_TV)             # предельный эффект для TV
mean(probit.me$dydx_age)            # для age




##3.5##
threshold <- 0.5                                           # порог отсечения
# пробит модель
probs.probit <- predict(model.probit,  
                        type = "response",
                        newdata = data)                  # вероятность
sub.probit <- as.numeric(probs.probit >= threshold)        # подписка
correct.probit <- mean(sub.probit == data$sub)           # доля верных прогнозов

# линейно-вероятностная модель
probs.linprob <- predict(lin_prob,  
                       type = "response",
                       newdata = data)                   # вероятность
sub.linprob <- as.numeric(probs.linprob >= threshold)          # подписка
correct.linprob <- mean(sub.linprob == data$sub)             # доля верных прогнозов

# наивная модель
sub.p <- mean(data$sub)                                  # доля подписки
correct.naive <- max(sub.p, 1 - sub.p)                     # доля верных прогнозов

# сравнение (доля верных прогнозов в процентах)
rbind(probit = correct.probit,                             # пробит модель
      linprob = correct.linprob,                               # линейно-вероятностная модель
      naive = correct.naive) * 100                         # наивная модель




##3.6##

summary(probit.me,  
        level = 0.95)  



##3.7##
# Построим 95% бутстрапированный доверительный интервал
boot.iter <- 100                                           # число бутстрап итераций

me.boot <- matrix(NA,                                    # матрица, в которую будем сохранять
                    nrow = boot.iter,                      # оценки предельных эффектов
                    ncol = 1)                          
colnames(me.boot) <- 'age'
head(me.boot)


n <- length(data)
h <- data

for(i in 1:boot.iter)         
{
  h.rows.ind <- sample(1:n, n, replace = TRUE)             # случайным образом отбираем
  # строки датафрейма h
  h.boot <- h[h.rows.ind, ]                                # формируем новый датафрейм
  # из выбранных строк h
  model.boot <- lm(formula = formula(model.probit),            # оцениваем модель по новой выборке
                   data = h.boot) 
  
  coefs_i = c(coef(model.boot))
  li = coefs_i*Arina
  #s = coef(model.boot)[1] + 2*coef(model.boot)['age'] * Arina['age'] + coef(model.boot)['series'] * Arina['series']
  #print(2*coef(model.boot)[['age']] )
  
  me_i = (1/sqrt(2*pi)) * exp(-((sum(li))^2/2)) * (coef(model.boot)[[1]] + 2*coef(model.boot)[['age']] * Arina[['age']] +  coef(model.boot)[['series']] * Arina[['series']])
  
  
  me.boot[i] <- me_i                     # получаем оценки коэффициентов
}
head(me.boot)


q.L.boot.age <- quantile(me.boot[, "age"], 0.025)            
q.R.boot.age <- quantile(me.boot[, "age"], 0.975) 
print(c(q.L.boot.age, q.R.boot.age))





##4.1##
library("numDeriv")                                        # численно дифференцирование

# Оценим пробит модель
model.probit <- glm(formula = sub ~ age + series + TV + I(age ^ 2) + I(age * series),
                    data = data,                                  
                    family = binomial(link = "probit")) 

# Запишем функцию правдоподобия
# для модели со случайно ошибкой
# из распределения Пирсона
ProbitLnLExtended <- function(par,                         # вектор значений параметров
                              y,                           # зависимая переменная 
                              X,                           # матрица независимых переменных
                              is_aggregate = TRUE)         # при TRUE возвращаем логарифм
  # функции правдоподобия, а при
  # FALSE возвращаем вектор вкладов
{
  beta <- matrix(par[-c(1, 2)], ncol = 1)                  # вектор beta коэффициентов и
  theta <- matrix(par[c(1, 2)], ncol = 1)                  # вектор дополнительных параметров  
  # переводим в матрицу с одним столбцом
  y_li <- X %*% beta                                       # оценка линейного индекса
  y_est <- y_li + theta[1] * y_li ^ 2 +                    # оценка математического ожидания 
    theta[2] * y_li ^ 3                             # латентной переменной
  
  n_obs <- nrow(X)                                         # количество наблюдений
  
  L_vec <- matrix(NA, nrow = n_obs,                        # вектор столбец вкладов наблюдений
                  ncol = 1)                                # в функцию правдоподобия
  
  is_y_0 <- (y == 0)                                       # вектор условий (y = 0)
  is_y_1 <- (y == 1)                                       # вектор условий (y = 1)
  
  L_vec[is_y_1] <- pnorm(y_est[is_y_1])                    # вклад наблюдений для которых yi = 1
  L_vec[is_y_0] <- 1 - pnorm(y_est[is_y_0])                # вклад наблюдений для которых yi = 0
  
  lnL_vec <- log(L_vec)                                    # логарифмы вкладов
  
  if(!is_aggregate)                                        # возвращаем вклады
  {                                                        # при необходимости
    return(lnL_vec)
  }
  
  lnL <- sum(lnL_vec)                                      # логарифм функции правдоподобия
  
  return(lnL)
}
# Воспользуемся созданной функцией
# Оценки модели при справедливом ограничении,
# накладываемом нулевой гипотезой
beta.est <- coef(model.probit)                             # достаем оценки из обычной пробит
beta.R <- c(0, 0, beta.est)                                # модели и приравниваем значения
names(beta.R)[c(1, 2)] <- c("theta1", "theta2")            # дополнительных параметров к значениям,
# предполагаемым нулевой гипотезой
print(beta.R)
# Создадим матрицу регрессоров
X.mat <- as.matrix(model.frame(model.probit))              # достаем датафрейм с регрессорами и
X.mat[, 1] <- 1                                            # первращаем его в матрицу, а также
colnames(X.mat)[1] <- "Intercept"                          # заменяем зависимую переменную на константу
head(X.mat, 5)
# Применим функцию
lnL.R <- ProbitLnLExtended(beta.R, data$sub, X.mat)           # считаем логарифм функции правоподобия
# при ограничениях, совпадающую с логарифмом
# функции правдоподобия обычной пробит модели
lnL.R.grad <- grad(func = ProbitLnLExtended,               # считаем градиент данной функции
                   x = beta.R,                             # численным методом
                   y = data$sub, 
                   X = X.mat)
lnL.R.grad <- matrix(lnL.R.grad, ncol = 1)                 # градиент как матрица с одним столбцом
lnL.R.Jac <- jacobian(func = ProbitLnLExtended,            # считаем Якобин данной функции
                      x = beta.R,                          # численным методом
                      y = data$sub, 
                      X = X.mat,
                      is_aggregate = FALSE)
# Реализуем тест
LM.value <- t(lnL.R.grad) %*%                            # считаем статистику теста
  qr.solve(t(lnL.R.Jac) %*% lnL.R.Jac) %*%                 # множителей Лагранжа
  lnL.R.grad
p.value <- 1 - pchisq(LM.value, df = 2)                # рассчитываем p-value теста
# множителей Лагранжа
print(p.value)





##4.2##
# Оценим параметры пробит модели с 
# гетероскедастичной случайной ошибкой
library("glmx")                                           # пакет, позволяющий оценивать пробит

install.packages('zoo')
# модель с гетероскдестичной 
# случайной ошибкой
# Оценим пробит модель без
# учета гетероскедастичности
library("lmtest")                                         # тестирование гипотез


# Оценим пробит модель без
# с учетом гетероскедастичности
model.hetprobit <- hetglm(formula = sub ~ age + series + TV + I(age ^ 2) + age * series 
                          |TV + age,       # линейный индекс уравнения дисперсии
                          data = data,                                 
                          family = binomial(link = "probit"),
                          link.scale = "log")
summary(model.hetprobit)

beta.est <- model.hetprobit$coefficients$mean
re.est <- model.hetprobit$coefficients$scale


# Осуществим тест на гомоскедастичность:
# H0: tau = 0
lrtest(model.hetprobit, model.probit)




##4.3##

# Рассчитаем предельные эффекты
# для индивида


# Предварительные расчеты
prob.Arina <- predict(model.hetprobit, newdata = Arina,     
                      type = "response")                   
li.Arina.adj <- predict(model.hetprobit, newdata = Arina,  
                        type = "link")                     
# отклонению случайной ошибки
sigma.Arina <- predict(model.hetprobit, newdata = Arina,   # оценка стандартного
                       type = "scale")                     # отклонения случайной

li.Arina <- li.Arina.adj * sigma.Arina                     # оценка линейного индекса Арины

# Используем встроенную функцию
library("margins")

# предельный эффект по вероятности
ME.Arina <- margins(model.hetprobit, 
                    data = Arina)
summary(ME.Arina)
Arina.age <- ME.Arina$dydx_age
print(Arina.age)


# предельный эффект по дисперсии
print(exp(2 * (re.est["age"] * Arina$age + re.est["TV"] * Arina$TV)) * 2 * re.est["age"])




##4.4##

#1)
model.probit_ur <- glm(formula = sub ~ age + series + TV + I(age ^ 2) + age * series, 
                      data = data, family = binomial(link = "probit"))  

model.probit_r <- glm(formula = sub ~ series + TV + I(age ^ 2) + age * series, 
                          data = data, family = binomial(link = "probit"))   

lrtest(model.probit_r, model.probit_ur)


# для series
model.probit_ur <- glm(formula = sub ~ age + series + TV + I(age ^ 2) + age * series, 
                       data = data, family = binomial(link = "probit"))  

model.probit_r <- glm(formula = sub ~ TV + I(age ^ 2) + age * series, 
                      data = data, family = binomial(link = "probit"))   

lrtest(model.probit_r, model.probit_ur)

LR_ratio <- -2 * (logLik(model.probit_r) - logLik(model.probit_ur))
p.value <- as.numeric(1 - pchisq(LR_ratio, df=1))  
p.value


#2)
model.probit_r2 <- glm(formula = sub ~ TV + I(age ^ 2), 
                      data = data, family = binomial(link = "probit"))   

lrtest(model.probit_r2, model.probit_ur)

LR_ratio <- -2 * (logLik(model.probit_r2) - logLik(model.probit_ur))
p.value <- as.numeric(1 - pchisq(LR_ratio, df=1))  
p.value


#3)
model.probit_r3 <- glm(formula =  sub ~ I(series + 3 * age * series) + age + TV + I(age ^ 2), 
                       data = data, family = binomial(link = "probit"))   

lrtest(model.probit_r3, model.probit_ur)

LR_ratio <- -2 * (logLik(model.probit_r3) - logLik(model.probit_ur))
p.value <- as.numeric(1 - pchisq(LR_ratio, df=1))  
p.value


#4)
model.probit_r4 <- glm(formula = sub ~ I(series + 3 * age * series) + age + I(age ^ 2), 
                       data = data, offset= I(1 * male), family = binomial(link = "probit"))  

lrtest(model.probit_r4, model.probit_ur)

LR_ratio <- -2 * (logLik(model.probit_r4) - logLik(model.probit_ur))
p.value <- as.numeric(1 - pchisq(LR_ratio, df=1))  
p.value




##4.5##
# Оценим ограниченную модель
model.probit.R <- glm(formula = sub ~ age + series + TV + I(age ^ 2) + age * series,
                      data = data,
                      family = binomial(link = "probit"))

# Оценим полную модель как комбинацию двух моделей
# модель только для мужчин
model.probit.F1 <- glm(formula = sub ~ age + series + TV + I(age ^ 2) + age * series, 
                       data = data[data$male == 1, ],
                       family = binomial(link = "probit"))
# модель только для женщин
model.probit.F0 <- glm(formula = sub ~ age + series + TV + I(age ^ 2) + age * series, 
                       data = data[data$male == 0, ],
                       family = binomial(link = "probit"))

# Считаем логарифмы правдоподобия 
# полной и ограниченной моделей
lnL.F <- logLik(model.probit.F1) + logLik(model.probit.F0) # логарифм правдоподобия 
# полной модели
lnL.R <- logLik(model.probit.R)                            # логарифм правдоподобия 
# ограниченной модели

# Тестируем гипотезу
r <- length(model.probit.R$coefficients) - 2               # число ограничений
t <- 2 * (lnL.F - lnL.R)                                   # статистика теста
p.value <- as.numeric(1 - pchisq(t, df = r))               # p-value теста
print(p.value)




##4.6##

# модель только для capital
model.probit_capital <- glm(formula = sub ~ age + series + TV + I(age ^ 2) + age * series, 
                       data = data[data$residence == 'Capital', ],
                       family = binomial(link = "probit"))

# модель только для village
model.probit_village <- glm(formula = sub ~ age + series + TV + I(age ^ 2) + age * series, 
                       data = data[data$residence == 'Village', ],
                       family = binomial(link = "probit"))

# модель только для city
model.probit_city <- glm(formula = sub ~ age + series + TV + I(age ^ 2) + age * series, 
                       data = data[data$residence == 'City', ],
                       family = binomial(link = "probit"))

# Считаем логарифмы правдоподобия 
# полной и ограниченной моделей
lnL.F <- logLik(model.probit_capital) + logLik(model.probit_village) + logLik(model.probit_city) # логарифм правдоподобия 
# полной модели
lnL.R <- logLik(model.probit.R)                            # логарифм правдоподобия 
# ограниченной модели

# Тестируем гипотезу
r <- length(model.probit.R$coefficients) - 2               # число ограничений
t <- 2 * (lnL.F - lnL.R)                                   # статистика теста
p.value <- as.numeric(1 - pchisq(t, df = r))               # p-value теста
print(p.value)



##5.1##
# Оценим логит модель
model.logit <- glm(formula = sub ~ age + series + TV + I(age ^ 2) + age * series, 
                   data = data,                               
                   # пробит модели
                   family = binomial(link = "logit"))         
summary(model.logit)



##5.2##
coef.logit <- coef(model.logit)
# Отношение шансов - (вероятность успеха) / (вероятность неудачи)
#                    P(y = 1) / P(y = 0)                     

# Оценим, во сколько раз, при прочих равных,
# изменится отношение шансов при
OR.TV <- exp(coef.logit["TV"])                           # получении страховки
print(OR.TV)




##5.3##
OR_age <- exp(coef.logit["age"] + coef.logit["I(age^2)"] * (2 * Arina$age + 1) + coef.logit["age:series"] * Arina$series) ^ 2
print(OR_age)
OR_series <- exp(coef.logit["series"] + coef.logit["age:series"] * Arina$age) ^ 2
print(OR_series)





##6.1##
library("GJRM")                                         # оценивание систем
# бинарных уравнений
library("pbivnorm")                                     # двумерное нормальное распределение

# Оцениваем параметры модели
sub_formula <- sub ~ age + series + TV + I(age ^ 2) + age * series
TV_formula <- TV ~ age + male + internet                   
model_bp <- gjrm(formula = list(sub_formula,        # задаем лист, состоящий из 
                                TV_formula),        # обеих формул
                 data = data,
                 model = "B",                           # указываем тип модели как систему
                 # бинанрных уравнений
                 margins = c("probit", "probit"),       # задаем маржинальные распределения
                 # случайных ошибок уравнений
                 #BivD = "N"
                 )                            # задаем тип совместного распределения
# случайных ошибок (копулу)
summary(model_bp)                                       # посмотрим на результат


##6.3##
# Оценим полную модель как комбинацию двух моделей
lnL_ur <- logLik(model_bp)

# Оценим ограниченную модель, состоит из двух отдельных
model.probit1 <- glm(formula = sub_formula,   
                     data = data, family = binomial(link = "probit"))                                                            
l1 <-  logLik(model.probit1)

model.probit2 <- glm(formula = TV_formula,   
                     data = data, family = binomial(link = "probit"))                                                           
l2 <- logLik(model.probit2)

# правдоподобие = сумма двух отдельных моделей
lnL_r <- l1 + l2

LR_ratio <- -2 * (lnL_r[1] - lnL_ur[1])

p.value <- as.numeric(1 - pchisq(LR_ratio, df = 1))  
print(p.value)



##6.4##
Arina <- data.frame(age=21,
                    series=10,
                    TV=0,
                    'age^2' = 441,
                    'age * series)' =210,
                    male = 0,
                    internet = 0.6)

#1)
p_1 <- predict(model_bp,                                         
               type = "response",
               eq = 1,
               newdata = Arina) 
print(p_1)


#2)
p_2 <- predict(model_bp, 
               type = "response",
               eq = 2, 
              newdata = Arina)
print(p_2)


#3)
rho_est <- model_bp$theta  

x_sub <- c(1, 21, 10, 0, 441, 210)
x_tv <- c(1, 21, 0, 0.6)

coefs_sub <- model_bp$coefficients[1:6]
sub_li <- x_sub %*% coefs_sub

coefs_tv <- model_bp$coefficients[7:10]
TV_li <- x_tv %*% coefs_tv

pbivnorm(x = cbind(sub_li, TV_li), rho = rho_est)


#4)
p_sub1_tv0 <- pbivnorm(x = cbind(sub_li, -TV_li), rho = -rho_est)
p_tv0 <- 1 - pnorm(TV_li)

p_sub1_tv0 / p_tv0




##7.1##
threshold <- 0.5                                           # порог отсечения


# линейно-вероятностная
probs.lin_prob <- predict(lin_prob,  
                        type = "response",
                        newdata = data)                  # вероятность
sub.lin_prob <- as.numeric(probs.lin_prob >= threshold)        # подписка
correct.lin_prob <- mean(sub.lin_prob == data$sub)           # доля верных прогнозов


# пробит модель
probs.probit <- predict(model.probit,  
                        type = "response",
                        newdata = data)                  # вероятность
sub.probit <- as.numeric(probs.probit >= threshold)        # подписка
correct.probit <- mean(sub.probit == data$sub)           # доля верных прогнозов

# логит модель
probs.logit <- predict(model.logit,  
                         type = "response",
                         newdata = data)                   # вероятность
sub.logit <- as.numeric(probs.logit >= threshold)          # подписка
correct.logit <- mean(sub.logit == data$sub)             # доля верных прогнозов

# наивная модель
sub.p <- mean(data$sub)                                  # доля подписки
correct.naive <- max(sub.p, 1 - sub.p)                     # доля верных прогнозов

# система
probs.bp <- predict(model_bp,  
                       type = "response",
                      eq=1,
                       newdata = data)                   # вероятность
sub.bp  <- as.numeric(probs.bp  >= threshold)          # подписка
correct.bp  <- mean(sub.bp  == data$sub)             # доля верных прогнозов


rbind(probit = correct.probit,                             # пробит модель
      linprob = correct.linprob,                               # линейно-вероятностная модель
      logit = correct.logit,
      bp = correct.bp,
      naive = correct.naive) * 100           


##7.2##
# AIC
rbind(linear = AIC(lin_prob),
      probit = AIC(model.probit),
      logit = AIC(model.logit))

# BIC
rbind(linear = BIC(lin_prob),
      probit = BIC(model.probit),
      logit = BIC(model.logit))


# с системой
model.probit1 <- glm(formula = sub_formula,   
                     data = data, family = binomial(link = "probit"))

model.probit2 <- glm(formula = TV_formula,   
                     data = data, family = binomial(link = "probit"))

AIC_probit_probit <- AIC(model.probit1) + AIC(model.probit2)
BIC_probit_probit <- BIC(model.probit1) + BIC(model.probit2)

# AIC
rbind(probit = AIC_probit_probit, 
      system = AIC(model_bp))

# BIC
rbind(probit = BIC_probit_probit, 
      system = BIC(model_bp))

