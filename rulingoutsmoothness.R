#This script compares the compositional account against different Matern functions

#Bayesian multi-level regression package
library(brms)

#read in comp model data (pre-computed in Matlab)
dat<-read.csv("data/allmodels.csv")

#read in Matern data (pre-computed in Matlab)
d<-read.csv("/home/hanshalbe/Desktop/FunctionDescriptions/data/neglokfuncssmooth.csv", header=FALSE)

#get Matern data into right format
m<-matrix(as.numeric(d), ncol=3, byrow = TRUE)
d<-data.frame(m, pid=0:39)

#intialize matern likelihood
dat$m1<-dat$m2<-dat$m3<-0

#add to data
for (i in 0:39){
  dat$m1[dat$pid==i]<-d$X1[i+1]
  dat$m2[dat$pid==i]<-d$X2[i+1]
  dat$m3[dat$pid==i]<-d$X3[i+1]
}

#First comparison: Matern 1/2 vs Compositional
m1<-brm(dw~m1+(1|id), data=dat, save_all_pars = TRUE)
m2<-brm(dw~m1+nlc+(1|id), data=dat, save_all_pars = TRUE)
bae1<-bayes_factor(m2, m1)

#Second comparison: Matern 3/2 vs. Compositional
m3<-brm(dw~m2+(1|id), data=dat, save_all_pars = TRUE)
m4<-brm(dw~m2+nlc+(1|id), data=dat, save_all_pars = TRUE)
bae2<-bayes_factor(m4, m3)

#Third comparison: Matern 5/2 vs. Compositional
m5<-brm(dw~m3+(1|id), data=dat, save_all_pars = TRUE)
m6<-brm(dw~m3+nlc+(1|id), data=dat, save_all_pars = TRUE)
bae3<-bayes_factor(m6, m5)

print(bae1, bae2, bae3)