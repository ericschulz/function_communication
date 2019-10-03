library(BayesFactor)
library(plyr)

#Rating from two independent raters
d<-read.csv("data/ranking.csv")

#correlation between raters
cor.test(d$Rater1, d$Rater2)
correlationBF(d$Rater1, d$Rater2)


#experimentally obtained ratings
dr<-read.csv("data/ratingexp.csv")


ds<-ddply(dr, ~pid, summarize, m=mean(rate))
ds<-ds[order(ds$pid),]
dr<-d[order(d$Participant.ID),]

#correlation between mean of raters and mean of experimental ratings
cor.test(dr$Average, ds$m)
correlationBF(dr$Average, ds$m)