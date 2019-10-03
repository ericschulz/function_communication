#This code checks if our results can be explained based on visual characteristics alone

#packages
packages <- c('jsonlite', 'ForeCA',  'plyr', 'splines', 'TSclust', 'lmerTest', 'brms')
lapply(packages, library, character.only = TRUE)

#get data
m<-fromJSON("data/function-communication-exp-2-export.json")
#demographics
age<-sex<-numeric()
for (i in 1:length(m)){
  mj<-m[[i]]
  age<-c(age, mj$age)
  sex<-c(sex, mj$gender)

}
table(sex)
table(age)
#remap age to numeric
age<-as.numeric(mapvalues(age, unique(age), c(25,40,60,20,40)))
#mean
mean(age)
#standard error
sd(age)

#spline function
myspline<-function(x, y, xnew){
  if(length(x)>3){
    isp <- interpSpline(x,y)
    ypred<-predict(isp,xnew)$y
    
  } else{
    dpoly<-data.frame(x=x, y=y)
    m<-lm(y~poly(x,degree=(length(dpoly$x)-1)), data=dpoly)
    ypred<-predict(m, newdata=data.frame(x=xnew))
  }
  
  ypred<-ypred-min(ypred)
  ypred<-ypred/max(ypred)
  return(ypred)
}


#Analyze the data
d<-read.csv("data/list.csv")
mj<-fromJSON("data/function-communication-exp-2-export.json")

id<-pid<-ae<-ran<-dw<-numeric()
for (idn in 1:length(mj)){
  for (trial in 1:5){
    x<-as.numeric(mj[[idn]]$responses$datapoints[[trial]][-c(1:2),1])
    y<-as.numeric(mj[[idn]]$responses$datapoints[[trial]][-c(1:2),2])
    ndup<-!duplicated(x)
    x<-x[ndup]
    y<-y[ndup]
    y<-myspline(x,y, 1:length(true))
    pn<-mj[[idn]]$responses$shownDescription$plot_number[trial]
    true<-as.numeric(d[pn+1,-1])/max(d[pn+1,-1])
    ae<-c(ae, sum(abs(true-y)))
    ran<-c(ran, sum((true-sample(y))^2))
    dw<-c(dw, as.numeric(diss.DWT(rbind(as.numeric(true), as.numeric(y)))))  
    pid<-c(pid, pn)
    id<-c(id, idn)
  }
}

#raw memory data
dp<-data.frame(id, pid, ae, ran, dw)

#get mean wavelet distance per function id
dd<-ddply(dp, ~pid, summarize, m=mean(dw))

#get original experiment
dat<-read.csv("data/allmodels.csv")

dat$mem<-0
for (i in 1:nrow(dd)){
  dat$mem[dat$pid==dd$pid[i]]<-dd$m[i]
}
dat$comp<-ifelse(dat$pid<20, "spec", "comp")

#check if memory is all there is to modeling wavelet distance
m1<-brm(dw ~mem+(mem+nlc|id), data=dat, save_all_pars = TRUE, control = list(adapt_delta = 0.99))
m2<-brm(dw ~mem+ nlc+(mem+nlc|id), data=dat, save_all_pars = TRUE, control = list(adapt_delta = 0.99))
b1<-bayes_factor(m2, m1)
print(b1)
summary(m2)

#check if memory is all there is to modeling wavelet distance
m3<-brm(ae ~mem+(mem+nlc|id), data=dat, save_all_pars = TRUE, control = list(adapt_delta = 0.99))
m4<-brm(ae ~mem+ nlc+(mem+nlc|id), data=dat, save_all_pars = TRUE, control = list(adapt_delta = 0.99))
b2<-bayes_factor(m4, m3)


#check if memory is all there is to ratings
dqual<-read.csv("data/quality.csv")


dqual$pair<-paste0(dqual$sender, "+", dqual$receiver)

dqual$mem<-0
for (i in 1:nrow(dd)){
  dqual$mem[dqual$message==dd$pid[i]]<-dd$m[i]
}

m5<-brm(m~mem+(mem+comp|pair), data=dqual, save_all_pars = TRUE, control = list(adapt_delta = 0.99))
m6<-brm(m~mem+comp+(mem+comp|pair), data=dqual, save_all_pars = TRUE, control = list(adapt_delta = 0.99))
b3<-bayes_factor(m6, m5)
