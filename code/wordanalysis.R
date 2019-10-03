#This file leads to the plot showing the differences in words that participants used to describe the different patterns

packages <- c('tm','RColorBrewer', 'SnowballC',  'plyr', 'wordcloud', 'ggplot2', 'gridExtra', 'lsr', 'BayesFactor', 'stringr', 'ggsignif')
lapply(packages, library, character.only = TRUE)

dat<-read.csv("data/2018-march-29-export_responses.csv")

dat$comp<-ifelse(dat$plot_number>20, 1, 0)
dd<-subset(dat, comp==1)
text <- dd$description

docs <- Corpus(VectorSource(text))
inspect(docs)

toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")

# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower))
# Remove numbers
docs <- tm_map(docs, removeNumbers)
# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))


docs <- tm_map(docs, removeWords, c("graph", "goes", "dots", "pattern", "back", "right", "side")) # Remove punctuations
docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)

dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d1 <- data.frame(word = names(v),freq=v)


dd<-subset(dat, comp==0)
text <- dd$description

docs <- Corpus(VectorSource(text))
inspect(docs)

toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")

# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower))
# Remove numbers
docs <- tm_map(docs, removeNumbers)
# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))

docs <- tm_map(docs, removeWords, c("graph", "goes", "dots", "pattern", "back", "right", "side")) 
# Remove punctuations
docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)

dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d2 <- data.frame(word = names(v),freq=v)


dd1<-subset(d1, freq>=2)
dd2<-subset(d2, freq>=2)
dd1<-dd1[!(dd1$word %in% dd2$word),]
dd2<-dd2[!(dd2$word %in% dd1$word),]


dp1<-dd1[order(-dd1$freq),][1:20,]
dp1$word<-factor(dp1$word, levels=paste(dp1$word))
p1<-ggplot(data=dp1, aes(x=word, y=freq)) +
  coord_flip()+ ylab("Frequency count")+xlab("Word")+
  geom_bar(stat="identity", fill=colorblind_pal()(3)[2])+ 
  theme_minimal()+ggtitle("(a) Compositional")+
  theme(text = element_text(size=20,  family="sans"))
p1



dp2<-dd2[order(-dd2$freq),][1:20,]
dp2$word<-factor(dp2$word, levels=paste(dp2$word))
p2<-ggplot(data=dp2, aes(x=word, y=freq)) +
  coord_flip()+ ylab("Frequency count")+xlab("Word")+
  theme(text = element_text(size=20,  family="sans"))+
  geom_bar(stat="identity", fill=colorblind_pal()(3)[3])+ 
  theme_minimal()+ggtitle("(b) Non-compositional")+
  #various theme changes including reducing white space and adding axes
  theme(axis.line.x = element_line(color="grey20", size = 1),
        axis.line.y = element_line(color="grey20", size = 1))+
  theme(text = element_text(size=20,  family="sans"))
p2


dat$complex<-0
head(dat)
specdiv<-comdiv<-rep(0, length(unique(dat$pid)))
for(i in 1:length(unique(dat$pid))){
  dd<-subset(dat, pid==i)
  dcomp<-subset(dd, comp==1)
  dspec<-subset(dd, comp==0)
  cw<-paste(dcomp$description[1],dcomp$description[2],dcomp$description[3])
  sw<-paste(dspec$description[1],dspec$description[2],dspec$description[3])
  comdiv[i]<-length(unique(tolower(paste(na.omit(word(cw,1:1000))))))/length(as.vector(tolower(paste(na.omit(word(cw,1:1000))))))
  specdiv[i]<-length(unique(tolower(paste(na.omit(word(sw,1:1000))))))/length(as.vector(tolower(paste(na.omit(word(sw,1:1000))))))
}

t.test(comdiv-specdiv)
cohensD(comdiv-specdiv)
dp<-data.frame(complex=c(comdiv, specdiv), 
              pid=rep(1:length(unique(dat$pid)), 2),
              compositional=rep(c("Compositional", "Non-compositional"), each=length(unique(dat$pid))))

se<-function(x){sd(x)/sqrt(length(x))}
dm<-ddply(dp, ~compositional, summarize, m=mean(complex), se=se(complex))
dpoint<-ddply(dp, ~pid+compositional, summarize, ae=mean(complex))
dsum<-data.frame(m=dm$m,compoisitional=dm$compositional,ymin=dm$m-dm$se, ymax=dm$m+dm$se)
library(ggthemes)

#function that outputs mean, lower limit and upper limit of 95% CI
data_summary <- function(x) {
  m <- mean(x, na.rm=TRUE)
  sem <-sd(x, na.rm=TRUE)/sqrt(sum(!is.na(x)))
  ymin<-m-1.64*sem
  ymax<-m+1.64*sem
  return(c(y=m,ymin=ymin,ymax=ymax))
}


t.test(comdiv-specdiv)
ttestBF(comdiv-specdiv)

p3<-ggplot(dp, aes(x = compositional, y = complex, fill=compositional, color=compositional))+
  geom_dotplot(binaxis='y', stackdir='center',stackratio=1.2, dotsize=3, binwidth=0.01, position=position_dodge(), alpha=0.5) +
  stat_summary(fun.data=data_summary, color="red")+
  theme_minimal()+ylim(c(0,1))+ theme(text = element_text(size=20,  family="sans"))+
  #colors and fill
  scale_fill_manual(values = colorblind_pal()(3)[2:3])+
  scale_color_manual(values = colorblind_pal()(3)[2:3])+
  geom_signif(comparisons=list(c("Non-compositional", "Compositional")), annotations="BF>100",
              y_position = 0.975, tip_length = 0, vjust=0, col="black", size=1.2, textsize=7) +
  xlab("Pattern")+ylab("Diversity")+
  #no legend
  theme(legend.position="none", strip.background=element_blank(), legend.key=element_rect(color=NA))+
  #labe x-axis
  #scale_x_continuous(breaks = c(1,2), labels = c("Compositional", "Spectral"))+
  ggtitle("(c) Lexical diversity")+
  #various theme changes including reducing white space and adding axes
  theme(axis.line.x = element_line(color="grey20", size = 1),
        axis.line.y = element_line(color="grey20", size = 1))

p3

pdf("textdiff.pdf", width=14.5, height=5)
grid.arrange(p1,p2,p3, nrow=1)
dev.off()
