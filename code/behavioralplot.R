#Behavioral Plots

#packages
packages <- c('jsonlite', 'ForeCA',  'plyr', 'splines', 'TSclust', 'ggplot2', 'ggthemes', 'ggsignif', 'gridExtra')
lapply(packages, library, character.only = TRUE)

#read in participants' data
mj<-fromJSON("data/2018-april-13-export.json")
#read in list of functions
d<-read.csv("data/list.csv")

#spline function to recover drawings
myspline<-function(x, y, xnew){
  if(length(x)>3){
    #splines that connect all points
    isp <- interpSpline(x,y)
    #predict
    ypred<-predict(isp,xnew)$y
    #if smaller than 4
  } else{
    #use polynomial regression
    dpoly<-data.frame(x=x, y=y)
    #fit model
    m<-lm(y~poly(x,degree=(length(dpoly$x)-1)), data=dpoly)
    #prediction
    ypred<-predict(m, newdata=data.frame(x=xnew))
  }
  #rescale
  ypred<-ypred-min(ypred)
  ypred<-ypred/max(ypred)
  return(ypred)
}

#initialize variables
id<-pid<-ae<-ran<-dw<-numeric()
#loop over participants
for (idn in 1:length(mj)){
  #loop over trials
  for (trial in 1:6){
    #X of points
    x<-as.numeric(mj[[idn]]$responses$datapoints[[trial]][-c(1:2),1])
    #y of points
    y<-as.numeric(mj[[idn]]$responses$datapoints[[trial]][-c(1:2),2])
    #remove duplicates
    ndup<-!duplicated(x)
    x<-x[ndup]
    y<-y[ndup]
    #smoothed line
    y<-myspline(x,y, 1:length(true))
    #get truth
    pn<-mj[[idn]]$responses$shownDescription$plot_number[trial]
    true<-as.numeric(d[pn+1,-1])/max(d[pn+1,-1])
    #absolute error
    ae<-c(ae, sum(abs(true-y)))
    #random baseline
    ran<-c(ran, sum((true-sample(y))^2))
    #wavelet distance
    dw<-c(dw, as.numeric(diss.DWT(rbind(as.numeric(true), as.numeric(y)))))  
    #plot id and participant id
    pid<-c(pid, pn)
    id<-c(id, idn)
  }
}

dp<-data.frame(id, pid, ae, ran, dw)

#mark type of function
dp$compositional<-ifelse(dp$pid<19, "Non-compositional", "Compositional")
#standard error
se<-function(x){sd(x)/sqrt(length(x))}
#means and se for absolute error
dm<-ddply(dp, ~compositional, summarize, m=mean(ae), se=se(ae))
#mean per person
dpoint<-ddply(dp, ~pid+compositional, summarize, ae=mean(ae))
#SEs
dsum<-data.frame(m=dm$m,compoisitional=dm$compositional,ymin=dm$m-dm$se, ymax=dm$m+dm$se)

#function that outputs mean, lower limit and upper limit of 95% CI
data_summary <- function(x) {
  m <- mean(x, na.rm=TRUE)
  sem <-sd(x, na.rm=TRUE)/sqrt(sum(!is.na(x)))
  ymin<-m-1.96*sem
  ymax<-m+1.96*sem
  return(c(y=m,ymin=ymin,ymax=ymax))
}

pd2<-position_dodge(0.1)

#First plot: absolute error
p1<-ggplot(dp, aes(x = compositional, y = ae, fill=compositional, color=compositional))+
  geom_dotplot(binaxis='y', stackdir='center',stackratio=1.2, dotsize=3, binwidth=0.3, position=pd2, alpha=0.5) +
  stat_summary(fun.data=data_summary, color="red")+
  theme_minimal()+ylim(c(0,51))+ theme(text = element_text(size=20,  family="sans"))+
  #colors and fill
  scale_fill_manual(values = colorblind_pal()(3)[2:3])+
  scale_color_manual(values = colorblind_pal()(3)[2:3])+
  geom_signif(comparisons=list(c("Non-compositional", "Compositional")), annotations="BF=4.1",
              y_position = 50, tip_length = 0, vjust=0, col="black", size=1.2, textsize=7) +
  xlab("Pattern")+ylab("Error")+
  #no legend
  theme(legend.position="none", strip.background=element_blank(), legend.key=element_rect(color=NA))+
  #labe x-axis
  #scale_x_continuous(breaks = c(1,2), labels = c("Compositional", "Spectral"))+
  ggtitle("(a) Absolute error")+
  #various theme changes including reducing white space and adding axes
  theme(axis.line.x = element_line(color="grey20", size = 1),
        axis.line.y = element_line(color="grey20", size = 1))

p1


#Second plot: Wavelet distance
p2<-ggplot(dp, aes(x = compositional, y = dw, fill=compositional, color=compositional))+
  geom_dotplot(binaxis='y', stackdir='center',stackratio=1.2, dotsize=3, binwidth=0.03, position=pd2, alpha=0.5) +
  stat_summary(fun.data=data_summary, color="red")+
  theme_minimal()+ylim(c(0,5))+ theme(text = element_text(size=20,  family="sans"))+
  #colors and fill
  scale_fill_manual(values = colorblind_pal()(3)[2:3])+
  scale_color_manual(values = colorblind_pal()(3)[2:3])+
  geom_signif(comparisons=list(c("Non-compositional", "Compositional")), annotations="BF=11.7",
              y_position = 5, tip_length = 0, vjust=0, col="black", size=1.2, textsize=7) +
  xlab("Pattern")+ylab("Error")+
  #no legend
  theme(legend.position="none", strip.background=element_blank(), legend.key=element_rect(color=NA))+
  #labe x-axis
  #scale_x_continuous(breaks = c(1,2), labels = c("Compositional", "Spectral"))+
  ggtitle("(b) Wavelet distance")+
  #various theme changes including reducing white space and adding axes
  theme(axis.line.x = element_line(color="grey20", size = 1),
        axis.line.y = element_line(color="grey20", size = 1))

p2


#Plot 3: Evaluations of performance
dev<-read.csv("data/evaluation.csv")
#reverse scoring
dev$rating<-100-dev$evaluation
#remap factor names
dev$compositional<-mapvalues(dev$compositional, c("compositional", "spectral"), c("Compositional", "Non-compositional"))
#plot everything
p3<-ggplot(dev, aes(x = compositional, y = rating, fill=compositional, color=compositional))+
  geom_dotplot(binaxis='y', stackdir='center',stackratio=1.2, dotsize=2, binwidth=.21, position=pd2, alpha=0.5) +
  stat_summary(fun.data=data_summary, color="red")+
  theme_minimal()+ylim(c(0,104))+ theme(text = element_text(size=20,  family="sans"))+
  #colors and fill
  scale_fill_manual(values = colorblind_pal()(3)[2:3])+
  scale_color_manual(values = colorblind_pal()(3)[2:3])+
  geom_signif(comparisons=list(c("Non-compositional", "Compositional")), annotations="BF>100",
              y_position = 102, tip_length = 0, vjust=0, col="black", size=1.2, textsize=7) +
  xlab("Pattern")+ylab("100-Rating")+
  #no legend
  theme(legend.position="none", strip.background=element_blank(), legend.key=element_rect(color=NA))+
  #labe x-axis
  #scale_x_continuous(breaks = c(1,2), labels = c("Compositional", "Spectral"))+
  ggtitle("(c) Ratings")+
  #various theme changes including reducing white space and adding axes
  theme(axis.line.x = element_line(color="grey20", size = 1),
        axis.line.y = element_line(color="grey20", size = 1))

p3

#save plots
pdf("behavioral.pdf", width=14.5, height=5)
grid.arrange(p1,p2,p3, nrow=1)
dev.off()
