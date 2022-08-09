library(dplyr)
library(tidyr)
library(lme4)
library("lmerTest")
library(emmeans)

# read in the data
final_data<-read.csv("processed_data/courtship_data.csv")

# Creating a data frame with proportions ----------------------------------

# create test_final using code in Graphs mesocosm --on onedrive 
Test_final1 <- final_data[!(final_data$subject=="Female" & final_data$modifier_2  =="Female"),]
Test_final2 <- Test_final1[!(Test_final1$subject=="Second female" & Test_final1$modifier_2  =="Female"),]
# Selection only wiggle and pose behaviours 
dat <- Test_final2[(Test_final2$behavior == "Wiggle" | Test_final2$behavior == "Pose"),]

#Changing second female into Female (only care about female vs male)
dat$subject <- ifelse(dat$subject == "Second female", "Female",
                      dat$subject)

#### summing female display behaviours together #######

test <-dat
test$behavior <- ifelse(test$subject == "Female" & test$behavior=="Wiggle", "display",
                        ifelse(test$subject == "Female" & test$behavior=="Pose", "display",
                      dat$behavior))
dat <-test

#Get the sum of each active behaviour for each sex in each courtship event
active <- aggregate(Duration ~  bout_number + behavior+subject, data=dat, sum)
active <- active[order(active$bout_number),]

#Merge info from original dataframe to the activity data
active1 <- merge(Test_final1[,9:14], active,  by="bout_number")

#Remove double ups
active <- distinct(active1)

# remove the behavior column because it is not needed (all behaviors are 'active courtship')
active <- active[,colnames(active)!= "behavior"]

# Reformat dataframe --------------------------------------------------------------
# the goal is to have one row for male courtship and one per female per bout, including zeros

# first, convert to wide format, which splits out male/female into columns per bout
active_wide <- pivot_wider(names_from=subject, values_from = Duration, data=active)
# turn NAs into zeroes
active_wide[is.na(active_wide)]<-0
# now reshape to long format, with zeroes included, so there is a column called 'sex'
active_long <- pivot_longer(data=active_wide, 
                            cols=c(Female, Male), 
                            names_to="Sex", 
                            values_to="behavior_duration")


#Calculate proportion 
active_long$proportion <- active_long$behavior_duration/active_long$total_time_of_courtship
active_long$Log_prop <- log(active_long$proportion+0.01)

# Creating dataframe where only BOTH sexes display in one courtship bout --------

reciprocal_bouts <- by(active_long, active_long$bout_number, function(dat){
  # if there is a zero proportion, the bout is NOT reciprocal (return FALSE)
  if(TRUE %in% (dat$proportion == 0)) return(FALSE) 
  else return(TRUE) # if there are no zeros, then it IS reciprocal, return TRUE
})
# get the bout numbers where this is true (as numbers)
reciprocal_bouts <- as.numeric(names(reciprocal_bouts[reciprocal_bouts==TRUE]))

# subset to only keep the reciprocal bouts (this is equivalent to Act_dat in previous version)
active_both <- as.data.frame(active_long[active_long$bout_number %in% reciprocal_bouts,])
active_both$Log_prop <- log(active_both$proportion+0.01)
active_both$Day_filmed <- factor(active_both$Day_filmed)  # convert it to a factor?

# ensure trial and bout_number are factors
active_both$Trial <- factor(active_both$Trial)
active_both$bout_number <- factor(active_both$bout_number)


# Creating data set that includes courtship bouts where only one sex displays --------

# subset active_long to only include bouts that were NOT reciprocal
active_single <- as.data.frame(active_long[!(active_long$bout_number %in% reciprocal_bouts),])
# remove the zero observations
active_single <- active_single[active_single$proportion > 0, ]
  
# summarize the reciprocal from males vs females
single_dis <- table(active_single$Sex)

#Total diaplays = 137
# Female only = 69
# Male only = 68
 
# Calculating whether females or males were more likely to display without response 
single_chisq <- chisq.test(single_dis, p = c(1/2, 1/2))
 
 

# Graphing the data (Fleur) -------------------------------------------------------

# Finding the mean and selecting colours
data_summary <- function(x) {
  m <- mean(x)
  ymin <- m-sd(x)
  ymax <- m+sd(x)
  return(c(y=m,ymin=ymin,ymax=ymax))
}

col1 <- c("#d73027",  "#fc8d59", "#fee090", "#99d594",
         "#e0f3f8", "#91bfdb", "#4575b4")
col2 <- c("#fc8d59","#91bfdb")
col3 <- c("#d73027","#91bfdb")

# Reciprocated courtship 
ggplot(active_both, aes(x=Time_of_Day, y=proportion, color=Sex, shape=Sex)) +
   theme(panel.background = element_blank())+
  geom_jitter(position=position_dodge(0.8))+ stat_summary(fun.data=data_summary, color="black",
                                                          position=position_dodge(0.8))



ggplot(active_both, aes(x=Time_of_Day, y=proportion, color=Time_of_Day)) + ggtitle("Without zeros")+
  theme(panel.background = element_blank(), )+
  geom_jitter(position=position_jitter(0.2))+
  stat_summary(fun.data=data_summary, color="black", position=position_dodge(0.8))
  

p <-ggplot(active_both, aes(x=Time_of_Day, y=proportion, color=Time_of_Day)) +
  theme(panel.background = element_blank(),legend.title=element_blank(), legend.key = element_rect(fill ="White"),
        axis.title=element_text(size=14))+
  scale_color_manual(values=col2)+
   geom_point(aes(shape = Sex),position=position_jitter(0.2), alpha = 0.7)+
  stat_summary(fun.data=data_summary, color="black", position=position_dodge(0.8), size=0.7)

p <- ggplot(active_both, aes(x=Sex, y=proportion, color=Sex)) +
  theme(panel.background = element_blank(),legend.position="none",
        axis.title=element_text(size=14))+
  scale_color_manual(values=col3)+
  geom_point(aes(shape = Sex),position=position_jitter(0.2), alpha = 0.4)+
  stat_summary(fun.data=data_summary, color="black", position=position_dodge(0.8), size=0.7)


p+guides(color = FALSE)+labs(x = "Sex", y ="Proportion ")


# Graphing the data (Sarah) -------------------------------------------------------

sexcols<-c(female='#af8dc3',male='#7fbf7b')
nbouts<-length(unique(active_long$bout_number))
time_cols<-c(AM="#7fc97f",Noon="#beaed4")
# differences between the sexes
boxplot(active_long$proportion ~ active_long$Sex,
        xlab="Sex",
        ylab="Proportion of bout spent courting",
        col=NA, border=NA,
        ylim=c(0,1))
points(x=jitter(rep(1,nbouts)),
       y=active_long$proportion[active_long$Sex=="Female"],
       col=scales::alpha(sexcols["female"],0.5)
)
points(x=jitter(rep(2,nbouts)),
       y=active_long$proportion[active_long$Sex=="Male"],
       col=scales::alpha(sexcols["male"],0.5)
)
boxplot(active_long$proportion ~ active_long$Sex,
        xlab="Sex",
        ylab="Proportion of bout spent courting",
        col=scales::alpha("white",0.25),
        border=c(sexcols),
        lwd=2,
        add=TRUE)
points(x=c(1,2),
       y=c(mean(active_long$proportion[active_long$Sex=="Female"]),
           mean(active_long$proportion[active_long$Sex=="Male"])),
       col=sexcols,
       pch=23,
       cex=3.5
       )


# proportion as a function of time of day
boxplot(active_long$proportion ~ active_long$Time_of_Day,
        xlab="Time of Day",
        ylab="Proportion of bout spent courting",
        col=scales::alpha("white",0.25),
        border=c(time_cols),
        lwd=2)

# proportion as a function of day filmed
boxplot(active_long$proportion ~ active_long$Day_filmed,
        xlab="Day filmed",
        ylab="Proportion of bout spent courting",
        col=scales::alpha("white",0.25),
        lwd=2)

# proportion as a function of trial
boxplot(active_long$proportion ~ active_long$Trial,
        xlab="Trial",
        ylab="Proportion of bout spent courting",
        col=scales::alpha("white",0.25),
        lwd=2)

par(mfrow=c(2,2))
hist(active_long$proportion)
hist(log(active_long$proportion+0.01)) 

hist(active_both$proportion)
hist(log(active_both$proportion+0.01)) 

# Creating a linear model to look at active behaviour ---------------------

# What is our question?
### Do males and females spend similar amounts of time courting within a bout? ###
# So: 
# 1. we only want to use the reciprocated courtship bouts
# 2. those data are normally distributed when log-transformed, so we can use lmer (but check assumptions)
# 3. should we ditch day_filmed, since it doesn't have good coverage across other levels?


# linear model using ONLY reciprocated courtship



# model selection
## intercept only
model0a <-lm(Log_prop ~ 1, data=active_both)
model0b <-lmer(Log_prop ~ 1 + (1|Trial/bout_number), data=active_both)

## single variables
model1 <-lmer(Log_prop ~ Sex + (1|Trial/bout_number), data=active_both)
model2 <-lmer(Log_prop ~ Time_of_Day + (1|Trial/bout_number), data=active_both)
model3 <-lmer(Log_prop ~ Day_filmed + (1|Trial/bout_number), data=active_both)

## two variables
model4 <-lmer(Log_prop ~ Time_of_Day + Day_filmed + (1|Trial/bout_number), data=active_both)
model5 <-lmer(Log_prop ~ Sex + Day_filmed + (1|Trial/bout_number), data=active_both)
model6 <-lmer(Log_prop ~ Sex + Time_of_Day  + (1|Trial/bout_number), data=active_both)

## full model
model7 <-lmer(Log_prop ~ Sex + Time_of_Day + Day_filmed + (1|Trial/bout_number), data=active_both)

ActivityAIC <- AIC(model0a,model0b, model1, model2, model3, model4, model5, model6, model7)


ActivityAIC$Model <- c("Interecpt LM", "Intercept with random effects", 
                       "Sex", "Time_of_Day",
                       "Day_filmed",
                    "Time_of_Day + Day_filmed", "Sex + Day_filmed ",
                    "Sex + Time_of_Day", 
                    "Sex + Time_of_Day + Day_filmed" )
ActivityAIC <- ActivityAIC[order(ActivityAIC$AIC),c(3,1,2)]

ActivityAIC

# use intercept w/ random effects (model0b) 
## Random effects intercept
summary(model0b)
anova(model0b)
confint(model0b)

# check some assumptions
par(mfrow=c(1,2))
hist(summary(model0b)$residuals)

qqnorm(resid(model0b))
qqline(resid(model0b))

plot(model0b, select=c(1))
