# Tests looking at initiation and where the ornament was used more in courtship or competition 
library(dplyr)
final_data <- read.csv("processed_data/courtship_data.csv")

#Which sex initiates more? -----------------------------------------------

chunk<-final_data[c("behavior", "subject", "bout_number", "modifier_2", "Duration", "time_in_video")]
chunk1<-filter(chunk, behavior == "Wiggle") # only looking at active courtship behaviour
chunk2<-filter(chunk, behavior == "Pose")
chunk3<-rbind(chunk1, chunk2)  # combine poses and wiggles 
chunk4<- chunk3[order(chunk3$bout_number),] # sort by bout
chunk5<- chunk4[!(chunk4$subject=="Female" & chunk4$modifier_2  =="Female"),] # remove female-female interactions
chunk6<- chunk5[!(chunk5$subject=="Second female" & chunk5$modifier_2  =="Female"),] # remove female-female interactions
chunk7<-chunk6[!duplicated(chunk6$bout_number), ] #remove all other active courtship except the first active behaviour
chunk7$Initiated <- as.numeric(chunk7$subject == "Female") 
Initiated <- table(chunk7$Initiated) # 0=Male, 1=Female 

# two-sided proportion test
res<-prop.test(x=Initiated[1], n=sum(Initiated), p = NULL, alternative = "two.sided",
               correct = TRUE)


# Graph 
barplot(Initiated, main="Sex initiating courtship",
        xlab="Sex", ylab="Number of courtship events", names.arg=c("Male", "Female"), col=c("black","white"))

# Is ornament used more in courtship or competition -----------------------

Comp<- chunk4[!(chunk4$subject=="Male"),] # active behavs from females
# Number of female displays towards either males or females and those displays split into type of display
a <-sum(Comp$behavior == "Wiggle" & Comp$modifier_2 == "Male") 
b <-sum(Comp$behavior == "Wiggle" & Comp$modifier_2 == "Female")
c <-sum(Comp$behavior == "Pose" & Comp$modifier_2 == "Male")
d <-sum(Comp$behavior == "Pose" & Comp$modifier_2 == "Female")
total <- sum(c(a,b,c,d))
Comp <- matrix(c((a/total),(b/total),(c/total),(d/total)),ncol=2,byrow=TRUE)
colnames(Comp)<-c("Male", "Female")
rownames(Comp)<- c("Wiggle", "Pose")
Comp <- as.table(Comp*100)

# Graph
barplot(Comp,
        ylab = "% of female displays",
        ylim =c(0,100),
        col = yarrr::transparent(c("black","white"), trans.val = .3),
        legend=rownames(Comp))

# Proportion test: do females display (both wiggles and poses) significantly more towards males or females
  # Display towards females = 80 (b+d)
  # Displays towards males = 1429 (a+c)
  # Total number of female displays = 1509

## Really should only do one of these
# Is there a difference between female displays towards female and males
res<-prop.test(x=a+c, n=total, p = NULL, alternative = "two.sided",
               correct = TRUE)
# Is there there a greater proportion of female displays towards males
res1 <- prop.test(x =a+c, n = total, p = 0.5, correct = FALSE,
                  alternative = "greater")


# Making a figure for the publication -----------------------
layout(matrix(c(1,1,2,3), byrow=TRUE, nrow=2))
sex_cols<-c(Female="#7fc97f",Male="#beaed4")

# load the pipefish picture
imager::load.image("../figs/pipefish_photos.png")

barplot(Initiated, 
        xlab="Sex initiating courtship",
        ylab="Number of courtship events", 
        names.arg=c("Male", "Female"), 
        col=sex_cols[c("Male", "Female")])
legend("topright","c)",cex=2,font=2)

barplot(Comp,
        ylab = "% of female displays",
        ylim =c(0,100),
        density=c(0,10,0,10),
        legend=rownames(Comp),
        col=sex_cols["Female"])
legend("topright","d)",cex=2,font=2)
