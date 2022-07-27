library(dplyr)
library(tidyr)
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
active <- aggregate(Duration ~  courtship_events + behavior+subject, data=dat, sum)
active <- active[order(active$courtship_events),]

#Collect extra info from original dataframe that I want to add
extra <- Test_final[c(9:14)]
#merge the two dataframes together
active1 <- merge(extra, active,  by="courtship_events")

#Remove double ups
active <- distinct(active1)

#Calculate proportion 
active <- active %>% mutate (Proportion = Duration/total_time_of_courtship)

# Removing single pringles (when one one sex displays with no response from the other sex)
check <- table(active$courtship_events,active$subject)
 check1 <- check[apply(check, 1, function(row) all(row !=0 )), ]

check2 <- as.data.frame(check1)

library(dbplyr)
keep <- check2$Var1
 keep <-keep[!duplicated(keep)]
 keep <- as.data.frame(keep)
 colnames(keep) <- "courtship_events"
 
 active$courtship_events <-as.factor(active$courtship_events)

 Act_dat <- merge(keep, active, by="courtship_events")
 Act_dat <- Act_dat[order(Act_dat$courtship_events),]
 
 bouts <-unique(Act_dat$courtship_events)
 counts<- Act_dat[!duplicated(Act_dat$courtship_events), ]
 count <-filter(counts, Day_filmed == "7" )
 sum(count$total_time_of_courtship)
 count(count$courtship_events)
 
 
 ### Adding zeros for singles
 
 check <- table(active$courtship_events,active$subject)
 zero <- as.data.frame(check)
 zero <- zero %>% filter(Freq==0)
 

 
 
 #when female = 0 only male displayed for that courtship event and visa versa 
 colnames(zero) <- c("courtship_events", "subject", "Proportion")
 zero$behavior <- ifelse(zero$subject == "Female", "diplay",
                         ifelse(zero$subject == "Male", "Wiggle",
                                NA))
 
 ### Analysing single sex courtship
 zero_dis <- zero
 zero_dis$subject <- ifelse(zero_dis$subject == "Female", "Male_only",
                            ifelse(zero_dis$subject == "Male", "Female_only",
                                   NA))
Female_only <- zero_dis[c(zero_dis$subject == "Female_only"),]
 
 single_dis <- c(50, 56)
 res <- chisq.test(single_dis, p = c(1/2, 1/2))
 
 
 extra <- active[1:6]
 
Zero <- merge(zero, extra, by="courtship_events")

info <- active[c(1:8,10)]
 
Zero1 <- rbind(Zero, info) 
Zero <- Zero1[order(Zero1$courtship_events),]
 zero <-Zero[!duplicated(Zero),]

 
 # Graphing
data_summary <- function(x) {
  m <- mean(x)
  ymin <- m-sd(x)
  ymax <- m+sd(x)
  return(c(y=m,ymin=ymin,ymax=ymax))
}

library(ggplot2)
col1 <- c("#d73027",  "#fc8d59", "#fee090", "#99d594",
         "#e0f3f8", "#91bfdb", "#4575b4")
col2 <- c("#fc8d59","#91bfdb")
col3 <- c("#d73027","#91bfdb")
ggplot(Act_dat, aes(x=Time_of_Day, y=Proportion, color=subject, shape=subject)) +
   theme(panel.background = element_blank())+
  geom_jitter(position=position_dodge(0.8))+ stat_summary(fun.data=data_summary, color="black",
                                                          position=position_dodge(0.8))



ggplot(Act_dat, aes(x=Time_of_Day, y=Proportion, color=Time_of_Day)) + ggtitle("Without zeros")+
  theme(panel.background = element_blank(), )+
  geom_jitter(position=position_jitter(0.2))+
  stat_summary(fun.data=data_summary, color="black", position=position_dodge(0.8))
  

p <-ggplot(Act_dat, aes(x=Da, y=Proportion, color=Time_of_Day)) +
  theme(panel.background = element_blank(),legend.title=element_blank(), legend.key = element_rect(fill ="White"),
        axis.title=element_text(size=14))+
  scale_color_manual(values=col2)+
   geom_point(aes(shape = subject),position=position_jitter(0.2), alpha = 0.7)+
  stat_summary(fun.data=data_summary, color="black", position=position_dodge(0.8), size=0.7)

p <- ggplot(Act_dat, aes(x=subject, y=Proportion, color=subject)) +
  theme(panel.background = element_blank(),legend.position="none",
        axis.title=element_text(size=14))+
  scale_color_manual(values=col3)+
  geom_point(aes(shape = subject),position=position_jitter(0.2), alpha = 0.4)+
  stat_summary(fun.data=data_summary, color="black", position=position_dodge(0.8), size=0.7)


p+guides(color = FALSE)+labs(x = "Sex", y ="Proportion ")

library(lme4)
library("lmerTest")
# linear model with out zero data
Act_dat$Log_prop <- log(Act_dat$Proportion)
model1 <-lmer(Log_prop~ subject + Time_of_Day + Day_filmed + (1|Trial/courtship_events), 
              data=Act_dat)
summary(model1)
anova(model1)

qqnorm(resid(model1))
qqline(resid(model1))

library(emmeans)
emmeans(model1, list(pairwise ~ Time_of_Day), adjust = "tukey")

confint(model1)




# linear model with zero data
zero$Log_prop <- log(zero$Proportion)
model2 <-lmer(Proportion ~ subject + Time_of_Day + Day_filmed + (1|Trial/courtship_events), data=zero)
summary(model2)
anova(model2)
#normally distributed errors check
hist(summary(model2)$residuals)
qqnorm(summary(model2)$residuals)
plot(model2, select=c(1))

active$resd <-summary(model1)$residuals

model1 <-lm(Log_prop ~ subject + Time_of_Day + Day_filmed, data=Act_dat)
E <- rstandard (model1)
boxplot(E ~ courtship_events, data=Act_dat, axes =FALSE,
        ylim=c(-2,2))
abline(0,0);axis(2)


# checking significance
model0 <-lmer(Log_prop ~ 1 + (1|Trial)+(1|courtship_events), data=active)

model1 <-lmer(Log_prop ~ subject + Time_of_Day + Day_filmed + (1|Trial)+(1|courtship_events), data=active)
summary(model1)
anova(model1)


model2 <-lmer(Log_prop ~ Time_of_Day + Day_filmed + (1|Trial)+(1|courtship_events), data=active)

model3 <-lmer(Log_prop ~ subject + Day_filmed + (1|Trial)+(1|courtship_events), data=active)

model4 <-lmer(Log_prop ~ subject + Time_of_Day  + (1|Trial)+(1|courtship_events), data=active)
summary(model4)

model5 <-lmer(Log_prop ~ subject + (1|Trial)+(1|courtship_events), data=active)


model6 <-lmer(Log_prop ~ Time_of_Day + (1|Trial)+(1|courtship_events), data=active)


model7 <-lmer(Log_prop ~ Day_filmed + (1|Trial)+(1|courtship_events), data=active)
anova(model0, model6)

Activity <- AIC(model0, model1, model2, model3, model4, model5, model6, model7)


Activity$Model <- c("Interecpt", "subject + Time_of_Day + Day_filmed" ,
                    "Time_of_Day + Day_filmed", "subject + Day_filmed ",
                    "subject + Time_of_Day", "subject ", "Time_of_Day",
                    "Day_filmed")
colnames(Activity) <- c("Model", "df", "AIC")

Activity <- Activity[,c(3,1,2)]


model5 <-lmer(Log_prop ~ subject + Time_of_Day + (1|Trial)+(1|courtship_events), data=active)
summary(model5)
anova(model5)

anova