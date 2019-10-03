library(brms)

dat<-read.csv("data/allmodels.csv")
dat$comp<-ifelse(dat$pid<20, 0, 1)

#Absolute error
m1<-brm(ae~1+(comp|id), data=dat, save_all_pars = TRUE)
m2<-brm(ae~comp+(comp|id), data=dat, save_all_pars = TRUE)
b1<-bayes_factor(m2, m1)
print(b1)
summary(m2)

#Wavelet distance
m3<-brm(dw~1+(comp|id), data=dat, save_all_pars = TRUE)
m4<-brm(dw~comp+(comp|id), data=dat, save_all_pars = TRUE)
b2<-bayes_factor(m4, m3)
print(b2)
summary(m4)

#Empirical evaluations
##Note: Since we're doing maximal comparisons, we have to increase the sample size by a lot!
deval<-read.csv("data/evaluation.csv")
head(deval)
m5<-brm(evaluation ~1+(compositional|sender)+(compositional|evaluator)+(compositional|message), data=deval, save_all_pars = TRUE, iter = 20000)
m6<-brm(evaluation ~compositional+(compositional|sender)+(compositional|evaluator)+(compositional|message), data=deval, save_all_pars = TRUE, iter = 20000)
b3<-bayes_factor(m6, m5)
print(b3)
summary(m6)

#Modeling absolute error
m7<-brm(ae~nls+(nls+nlc|id), data=dat,  save_all_pars = TRUE, iter=5000)
m8<-brm(ae~nls+nlc+(nls+nlc|id), data=dat,  save_all_pars = TRUE, iter=5000)
b4<-bayes_factor(m8, m7)
print(b4)
summary(m8)

#Modeling wavelet distance
m9<-brm(dw~nls+(nls+nlc|id), data=dat,  save_all_pars = TRUE, iter=5000)
m10<-brm(dw~nls+nlc+(nls+nlc|id), data=dat,  save_all_pars = TRUE, iter=5000)
b5<-bayes_factor(m10, m9)
print(b5)
summary(m10)

#Modeling descriptions
dqual<-read.csv("data/quality.csv")
head(dqual)
m11<-brm(m~spec+(comp+spec|sender)+(comp+spec|receiver)+(comp+spec|message), data=dqual,  save_all_pars = TRUE, iter=20000, control = list(adapt_delta = 0.99))
m12<-brm(m~spec+comp+(comp+spec|sender)+(comp+spec|receiver)+(comp+spec|message), data=dqual,  save_all_pars = TRUE, iter=20000, control = list(adapt_delta = 0.99))
b6<-bayes_factor(m12, m11)
print(b6)
summary(m12)
