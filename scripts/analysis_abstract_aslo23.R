#detection of words in abstracts
library(stringr)
library(RColorBrewer)

Abs_data<-read.csv("./Data/Abstracts.csv")
Abstracts<-tolower(Abs_data$X.Main...Submission.Information..Abstract.Description)
Title<-tolower(Abs_data$Application.Name)
N<-length(Abstracts)

words<-c("climate change","climate warming","warming","warmer","carbon","greenhouse gas","greenhouse gases","CO2","methane","emissions","storage","GHG","mitigating","adaptation","mitigation","blue carbon","carbon capture")

n<-length(words)
Abs_results<-data.frame(word1=FALSE,word2=FALSE,word3=FALSE,word4=FALSE,word5=FALSE,word6=FALSE,word7=FALSE,word8=FALSE,word9=FALSE,word10=FALSE,word11=FALSE,word12=FALSE,word13=FALSE,word14=FALSE,word15=FALSE,word16=FALSE,word17=FALSE)

for (i in 1:N) {
text<-Abstracts[i]
Abs_results[i,]<-str_detect(text, words)
 }

Abs_results2<-Abs_results

for (i in 1:n) {
  V<-Abs_results[,i]
  V[V==FALSE]<-0
  V[V==TRUE]<-1
  Abs_results2[,i]<-V
}

Abs_results2$climate_change<-ifelse(rowSums(Abs_results2[,1:4])>=1,1,0)
Abs_results2$GHG<-ifelse(rowSums(Abs_results2[,5:10])>=1,1,0)
Abs_results2$mitigation_adaptation<-ifelse(rowSums(Abs_results2[,11:17])>=1,1,0)
Abs_results2$climate_change_related_topics<-ifelse(rowSums(Abs_results2[,1:17])>=1,1,0)

summary_abst<-colSums(Abs_results2)[18:21]/nrow(Abs_results2)
mypalette<-brewer.pal(10,"Paired")


barplot(summary_abst,names.arg=c("Climate warming", "GHG","Mitigation,\n Adaptation", "All climate \nchange related"),col=mypalette[5:8],xlab="Topics",ylab="Proportion of Abstracts\n of ASM 2023",font.lab=2,cex.lab=1.2,cex.axis=1.2)

