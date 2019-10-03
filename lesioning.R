library(brms)
#This compares the lesioned models against the compositional model
#NOTE: This has been updated to "keep it maximal", following Roger Levy's advise

dat<-read.csv("data/allmodels.csv")



#periodic
mper1<-brm(dw~nwp+(nwp+nlc|id), data=dat, save_all_pars = TRUE)
mper2<-brm(dw~nwp+nlc+(nwp+nlc|id), data=dat, save_all_pars = TRUE)
bper<-bayes_factor(mper2, mper1)


#RBF only
mrbf1<-brm(dw~nwr+(nwr+nlc|id), data=dat, save_all_pars = TRUE)
mrbf2<-brm(dw~nwr+nlc+(nwr+nlc|id), data=dat, save_all_pars = TRUE)
brbf<-bayes_factor(mrbf2, mrbf1)

#Lin only
mlin1<-brm(dw~nwl+(nwl+nlc|id), data=dat, save_all_pars = TRUE)
mlin2<-brm(dw~nwl+nlc+(nwl+nlc|id), data=dat, save_all_pars = TRUE)
blin<-bayes_factor(mlin2, mlin1)

print(bper)
print(brbf)
print(blin)