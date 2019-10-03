packages <- c('tm','RColorBrewer', 'SnowballC',  'plyr', 'wordcloud', 'ggplot2', 'gridExtra', 'lsr', 'BayesFactor', 'stringr')
lapply(packages, library, character.only = TRUE)

dat<-read.csv("data/singlecompdescriptions.csv")


#Get words in linear descriptions
text <- subset(dat, pattern=="lin")$desc

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

docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)

dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d1 <- data.frame(word = names(v),freq=v)
d1

#Get words in preiodic descriptions
text <- subset(dat, pattern=="per")$desc

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

docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)

dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d2 <- data.frame(word = names(v),freq=v)
d2


#Get words in RBF descriptions
text <- subset(dat, pattern=="rbf")$desc

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

docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)

dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d3 <- data.frame(word = names(v),freq=v)
d3

#keep words that occured more often than 5 times
d1<-subset(d1, freq>=5)
d2<-subset(d2, freq>=5)
d3<-subset(d3, freq>=5)

#mark words that occured more often in lin than in others
d1$special<-0
for (i in 1:nrow(d1)){
  d1$special[i]<-0.5*(d1$freq[i]-ifelse(d1$word[i] %in% d2$word, d2$freq[paste(d1$word[i])==paste(d2$word)], 0))+
                 0.5*(d1$freq[i]-ifelse(d1$word[i] %in% d3$word, d2$freq[paste(d1$word[i])==paste(d3$word)], 0))
}

#get top 10
dlin<-head(d1[order(-d1$special),], 10)

#mark words that occured more often in periodic than in others
d2$special<-0
for (i in 1:nrow(d2)){
  d2$special[i]<-0.5*(d2$freq[i]-ifelse(d2$word[i] %in% d1$word, d1$freq[paste(d2$word[i])==paste(d1$word)], 0))+
    0.5*(d2$freq[i]-ifelse(d2$word[i] %in% d3$word, d3$freq[paste(d2$word[i])==paste(d3$word)], 0))
}
#keep top 10
dper<-head(d2[order(-d2$special),], 10)

#mark words that occured more often in periodic than in others
d3$special<-0

for (i in 1:nrow(d3)){
  d3$special[i]<-0.5*(d3$freq[i]-ifelse(d3$word[i] %in% d1$word, d1$freq[paste(d3$word[i])==paste(d1$word)], 0))+
    0.5*(d3$freq[i]-ifelse(d3$word[i] %in% d2$word, d2$freq[paste(d3$word[i])==paste(d2$word)], 0))
}
#keep top 10
drbf<-head(d3[order(-d3$special),], 10)

#combine them all
dpattern<-rbind(dlin, dper, drbf)
dpattern$pattern<-rep(c('lin', 'per', 'rbf'), each=10)

#get experimental data
dat<-read.csv("//home/hanshalbe/Desktop/FunctionDescriptions/data/2018-march-29-export_responses.csv")

#mark compositions
dat$comp<-ifelse(dat$plot_number>19, 1, 0)

#subset and extract words
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


#get non-compositions
dd<-subset(dat, comp==0)
#extract words
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
# Remove punctuations
docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)

dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d2 <- data.frame(word = names(v),freq=v)

dpattern$comp<-0
for (i in 1:nrow(dpattern)){
  dpattern$comp[i]<-ifelse(dpattern$word[i] %in% d1$word, d1$word[i], 0)
}

dpattern$spec<-0
for (i in 1:nrow(dpattern)){
  dpattern$spec[i]<-ifelse(dpattern$word[i] %in% d2$word, d2$word[i], 0)
}


#means
dp<-ddply(dpattern, ~pattern, summarize, m1=mean(comp), m2=mean(spec))

#difference
dpattern$diff<-dpattern$comp-dpattern$spec

#remove duplicates
dpattern<-dpattern[!duplicated(dpattern$word),]

#levels
dpattern$word<-factor(dpattern$word, levels=dpattern$word[order(dpattern$pattern)])
#new name for plot
dpattern$Composition<-dpattern$pattern
#map to longer terms
dpattern$Composition<-mapvalues(dpattern$Composition, c("lin","rbf", "per"), c("Linear", "RBF", "Periodic"))
#plot
p1<-ggplot(data=dpattern, aes(x=word, y=diff, col=Composition, fill=Composition, group=Composition)) +
  coord_flip()+ ylab("Frequency count")+xlab("Word")+
  theme(text = element_text(size=20,  family="sans"))+
  geom_bar(stat="identity")+ 
  theme_minimal()+ggtitle("(a) Frequency of occurrence")+
  #various theme changes including reducing white space and adding axes
  theme(axis.line.x = element_line(color="grey20", size = 1),
        axis.line.y = element_line(color="grey20", size = 1))+
  theme(text = element_text(size=20,  family="sans"),
        legend.position = "top")
p1

#read in data again
dat<-read.csv("/home/hanshalbe/Desktop/FunctionDescriptions/data/2018-march-29-export_responses.csv")

#initialize data frame
dd<-data.frame(id=numeric(), pid=numeric(), mark=numeric(), desc=numeric())

#loop through and mark if word appears
for (i in 1:nrow(dat)){
  for (j in 1:nrow(dpattern)){
    mark<-ifelse(grepl(paste(dpattern$word[j]), paste(dat$description[i])),1,0)
    dd<-rbind(dd, data.frame(id=dat$pid[i], pid=dat$plot_number[i], mark=mark, desc=dpattern$pattern[j]))
  }
}

#mark compositional
dd$comp<-ifelse(dd$pid>19, "Compositional", "Non-compositional")

#summarize for RBF (you can do that with any component)
dp<-ddply(subset(dd, desc=="rbf"), ~comp+id, summarize, mu=mean(mark), se=se(mark))

#test
t.test(subset(dp, comp=="Compositional")$mu-subset(dp, comp=="Non-compositional")$mu)
cohensD(subset(dp, comp=="Compositional")$mu-subset(dp, comp=="Non-compositional")$mu)
ttestBF(subset(dp, comp=="Compositional")$mu-subset(dp, comp=="Non-compositional")$mu)

#summarize to plot
dp<-ddply(dd, ~comp+desc, summarize, mu=mean(mark), se=se(mark))
ddp<-ddply(dd, ~comp, summarize, mu=mean(mark), se=se(mark))
dp<-rbind(dp, data.frame(comp=ddp$comp, desc="Overall", mu=ddp$mu, se=ddp$se))
dp$desc<-mapvalues(dp$desc, c("lin", "per", "rbf", "Overall"),  c("Linear", "Periodic", "RBF", "Overall") )
dp$desc<-factor(dp$desc, levels=c("Overall", "Linear", "Periodic", "RBF"))

#limits for plotting
limits <- aes(ymax = mu + se, ymin=mu - se)

#new term for plot
dp$Pattern<-dp$comp

#plotting
p2 <- ggplot(dp, aes(y=mu, x=Pattern, fill=Pattern)) + 
  #bars
  geom_bar(position="dodge", stat="identity", width = 0.75)+
  #0 to 1
  #golden ratio error bars
  geom_errorbar(limits, position="dodge", width=0.31)+
  #point size
  #geom_point(size=3)+
  facet_wrap(~desc, nrow=4)+
  #scale_fill_manual(values=cbbPalette[c(6,7)])+
  #title
  ggtitle("a: Observed subadditivity effect")+theme_classic() +xlab("Pattern")+
  ylab("Mean Estimates")+
  scale_y_continuous(limits = c(0,0.18), expand = c(0, 0)) + 
  theme_minimal()+ggtitle("(b) Probability of occurrence")+
  #various theme changes including reducing white space and adding axes
  theme(axis.line.x = element_line(color="grey20", size = 1),
        axis.line.y = element_line(color="grey20", size = 1))+
  theme(text = element_text(size=20,  family="sans"),
        legend.position = "top")

p2

#save plots
pdf("wordanalysis.pdf", width=12, height=10)
grid.arrange(p1,p2, nrow=1)
dev.off()


#reading in language data that has the individual components likelihoods
#otherwise the same as before
dd<-read.csv('data/langdata.csv')

#how much variance is there even
m1<-brm(mark~1+(1|id), data=subset(dd, desc="per"), family="binomial", save_all_pars = TRUE)

#check periodic
m2<-brm(mark~1+(scale(perl)|id), data=subset(dd, desc="per"), family="binomial", save_all_pars = TRUE)
m3<-brm(mark~scale(perl)+(scale(perl)|id), data=subset(dd, desc="per"), family="binomial", save_all_pars = TRUE)
bper<-bayes_factor(m3, m2)
summary(m3)

#check linear
m4<-brm(mark~1+(scale(linl)|id), data=subset(dd, desc="lin"), family="binomial", save_all_pars = TRUE)
m5<-brm(mark~scale(linl)+(scale(linl)|id), data=subset(dd, desc="lin"), family="binomial", save_all_pars = TRUE)
blin<-bayes_factor(m5, m4)
summary(m5)

#check RBF
m6<-brm(mark~1+(scale(rbfl)|id), data=subset(dd, desc="rbf"), family="binomial", save_all_pars = TRUE)
m7<-brm(mark~scale(rbfl)+(scale(rbfl)|id), data=subset(dd, desc="rbf"), family="binomial", save_all_pars = TRUE)
brbf<-bayes_factor(m7, m6)
summary(m7)