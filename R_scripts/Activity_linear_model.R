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
 
 

# Graphing the data -------------------------------------------------------


 
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




# Creating a linear model to look at active behaviour ---------------------


# linear model using ONLY reciprocated courtship
active_both$Log_prop <- log(active_both$Proportion)
model1 <-lmer(Log_prop~ subject + Time_of_Day + Day_filmed + (1|Trial/bout_number), 
              data=active_both)
summary(model1)
anova(model1)

qqnorm(resid(model1))
qqline(resid(model1))


emmeans(model1, list(pairwise ~ Time_of_Day), adjust = "tukey")

confint(model1)




# linear model with ALL data and including zero proportions
active_long$Log_prop <- log(active_long$proportion)
model2 <-lmer(proportion ~ subject + Time_of_Day + Day_filmed + (1|Trial/bout_number), data=active_long)
summary(model2)
anova(model2)
#normally distributed errors check
hist(summary(model2)$residuals)
qqnorm(summary(model2)$residuals)
plot(model2, select=c(1))

active$resd <-summary(model1)$residuals

model1 <-lm(Log_prop ~ subject + Time_of_Day + Day_filmed, data=active_both)
E <- rstandard (model1)
boxplot(E ~ bout_number, data=active_both, axes =FALSE,
        ylim=c(-2,2))
abline(0,0);axis(2)


# checking significance
model0 <-lmer(Log_prop ~ 1 + (1|Trial)+(1|bout_number), data=active)

model1 <-lmer(Log_prop ~ subject + Time_of_Day + Day_filmed + (1|Trial)+(1|bout_number), data=active)
summary(model1)
anova(model1)


model2 <-lmer(Log_prop ~ Time_of_Day + Day_filmed + (1|Trial)+(1|bout_number), data=active)

model3 <-lmer(Log_prop ~ subject + Day_filmed + (1|Trial)+(1|bout_number), data=active)

model4 <-lmer(Log_prop ~ subject + Time_of_Day  + (1|Trial)+(1|bout_number), data=active)
summary(model4)

model5 <-lmer(Log_prop ~ subject + (1|Trial)+(1|bout_number), data=active)


model6 <-lmer(Log_prop ~ Time_of_Day + (1|Trial)+(1|bout_number), data=active)


model7 <-lmer(Log_prop ~ Day_filmed + (1|Trial)+(1|bout_number), data=active)
anova(model0, model6)

Activity <- AIC(model0, model1, model2, model3, model4, model5, model6, model7)


Activity$Model <- c("Interecpt", "subject + Time_of_Day + Day_filmed" ,
                    "Time_of_Day + Day_filmed", "subject + Day_filmed ",
                    "subject + Time_of_Day", "subject ", "Time_of_Day",
                    "Day_filmed")
colnames(Activity) <- c("Model", "df", "AIC")

Activity <- Activity[,c(3,1,2)]


model5 <-lmer(Log_prop ~ subject + Time_of_Day + (1|Trial)+(1|bout_number), data=active)
summary(model5)
anova(model5)

anova