# The goal of this script -----------------------------------------------------

# This script is analysing whether group size impacted male wiggle duration.

# Log duration was the response variable, 
# group size was a fixed effect and courtship event was a random effect

# SPF: I am going to adjust this so it is consistent with the activity model
# and have bout nested within trial

# Setup -----------------------------------------------------------------------

library(report)
library(lme4)
library("lmerTest")
library(emmeans)
library("ggplot2")  
library(broom.mixed)
library(vioplot)


# read in the data
final_data<-read.csv("processed_data/courtship_data.csv")

# Subsetting data to only include male wiggles ------------------------------------------------------------

### subsetting data to only include wanted information ###
group<-final_data[c("behavior", "subject", "bout_number", "modifier_2", "modifier_3", "Duration", "time_in_video", "Trial")]
group1<-filter(group, behavior == "Wiggle")
group_model<- group1[!(group1$subject=="Female"),]
group<- group_model[!(group_model$subject=="Second female"),]

# Removing any leading or trailing spaces in dataframe
group<-data.frame(lapply(group,trimws))

# Fix some typos in modifier_3:
group$modifier_3[group$modifier_3==33]<-3
group$modifier_3[group$modifier_3=="None" & group$time_in_video==442.104]<-3
group$modifier_3[group$modifier_3=="None" & group$time_in_video==641.583]<-4

# changing things to factor or numeric
group$modifier_3 <- as.factor(group$modifier_3)
group$Duration <- as.numeric(group$Duration)
group$bout_number <- as.factor(group$bout_number)

# log transform duration
group$logDuration <- log(group$Duration)

# Exploratory plots ------------------------------------------------------------
# Creating a violin plot to look at distribution of data
# modifier_3 contains the group number
vioplot(group$Duration[group$modifier_3 == "2"], group$Duration[group$modifier_3 == "3"], group$Duration[group$modifier_3 == "4"],
        group$Duration[group$modifier_3 == "5"], group$Duration[group$modifier_3 == "6"], names=c("2", "3", "4", "5", "6"))
##vioplot(group$Duration ~ group$modifier_3,
        #xlab = "Group size", ylab = "Duration of wiggle", main="Duration distribution")

# Checking duration and log duration
par(mfrow=c(1,2))
hist(group$Duration)
hist(group$logDuration)




# Creating a scatterplot with all data points
ggplot(data  = group,
       aes(x = modifier_3,
           y = Duration
       ))+
  geom_point(size = 1.2,
             alpha = .8,
             position = "jitter")+
  geom_line(data = fortify(lm(Duration ~ modifier_3, data=group)), aes(x = modifier_3, y = .fitted))+
  #geom_smooth(method = lm,
  #se     = FALSE, 
  #col    = "black",
  ##size   = .5, 
  #alpha  = .8)+ # to add regression line# to add some random noise for plotting purposes
  theme_minimal()+
  theme(legend.position = "none")+
  labs(title = "Group size and male wiggle duration")





# Log Duration ------------------------------------------------------------


Malegroup <-lmer(logDuration ~ modifier_3 + (1|Trial/bout_number), data=group)
summary(Malegroup)
# fixed effect parameter estimates (coefficients)
coef(summary(Malegroup))


plot(resid(Malegroup), pch = 16, col = "red")

plot(Malegroup, which=1)

# Q-Q plot
qqnorm(group$logDuration, pch = 1, frame = FALSE)
qqline(group$logDuration, col = "steelblue", lwd = 2) #these look pretty nice

# Fleur reported in her thesis that group size didn't matter...
# let's check that my results are not deviated substantially due to change in random effects

origModel<-lmer(logDuration ~ modifier_3 + (1|bout_number), data=group)
summary(origModel) # no, it still matters...


# Grouping >5 fish together in one group and removing extreme values --------

group_merged <- group
group_merged<- group_merged[order(group_merged$modifier_3),]
group_merged$groupsize <- group_merged$modifier_3
group_merged$groupsize <- as.numeric(as.character(group_merged$groupsize))
group_merged$groupsize[group_merged$groupsize>4] <- 5
group_merged$groupsize <- as.factor(group_merged$groupsize)
str(group_merged)
# plotting the data 
ggplot(data  = group_merged,
       aes(x = groupsize,
           y = logDuration,
           col = bout_number))+
  geom_point(size = 1.2,
             alpha = .8,
             position = "jitter")+
  geom_smooth(method = lm,
              se     = FALSE, 
              col    = "black",
              size   = .5, 
              alpha  = .8)+ # to add regression line# to add some random noise for plotting purposes
  theme_minimal()+
  theme(legend.position = "none")+
  labs(title = "Group size and male wiggle duration")

# linear model

group_model <-lmer(logDuration ~ groupsize + (1|Trial/bout_number), data=group_merged)
summary(group_model)
# get some estimates
anova(group_model)
coef(group_model)
e <-emmeans(group_model, list(pairwise ~ groupsize), adjust = "tukey")

write.csv(e, "Groupsize_posthoc.csv", row.names = FALSE)

# check some assumptions
plot(group_model, which=1)

plot(ranef(group_model))
plot(group_model)

# Q-Q plot
qqnorm(group_merged$logDuration, pch = 1, frame = FALSE)
qqline(group_merged$logDuration, col = "steelblue", lwd = 2)



# Determining whether random effects is making a difference on the --------

# Create null model
group_null <- lmer(logDuration ~ 1 + (1|Trial/bout_number), data = group_merged) 
summary(group_null)
  #'Duration' can be "explained" by courtship events
anova(group_null)


# Comparing the models 
anova(group_null, group_model)

# Get p-values 
anova(group_model)

# Histogram of residuals 

ggplot(data = group_merged, aes(x = resid(group_model))) +
  geom_histogram(fill = 'steelblue', color = 'black') +
  labs(title = 'Histogram of Residuals', x = 'Residuals', y = 'Frequency')

# AIC values 
AIC(group_null, group_model)

