
# Chasing behaviour data --------------------------------------------------

###### Use files from Chase_datasheets folder in dropbox for this #######

# Reading in and cleaning data

setwd("C:/Users/Owner/OneDrive - University of Canterbury/Pipefish/Pipefish_data/Chase_datasheets")


new_data<-dplyr::bind_rows(lapply(list.files(pattern="Trial"), read.csv))
colnames(new_data) <- c("media_file_path", "time_in_video", "Duration",              
                        "behavior" , "subject" ,"modifier_1" ,"modifier_2","modifier_3" ,"Group_size", "Female", "Male" ,
                        "Chasing_end" , "Chasing_present" , "courtship_events_wrong" , "total_time_of_courtship")

# Adding trial names and time of day etc

library(stringr)

Test_final<-new_data
#Adding in Trial number
Test_final$Trial=substr(Test_final$media_file_path, 27, 33)
#Adding Am or Noon filming times
Test_final$Time_of_Day=str_sub(Test_final$media_file_path, -10)
Test_final$Time_of_Day=str_extract(Test_final$Time_of_Day,"(\\w+)")
Test_final$Time_of_Day <-  ifelse(Test_final$Time_of_Day == "oon", "Noon",
                                  Test_final$Time_of_Day)
#Adding Date filmed 
Test_final$Date_filmed=substr(Test_final$media_file_path, 35, 42)
Test_final$Date_filmed=str_extract(Test_final$Date_filmed,"(\\w+)")

library(dplyr)

# Adding which day filmed (1-7)
Test_final$Day_filmed <- ifelse(Test_final$Trial == "Trial 1" & Test_final$Date_filmed == 8, "7",
                         ifelse(Test_final$Trial == "Trial 2" & Test_final$Date_filmed == 3, "1",
                         ifelse( Test_final$Trial == "Trial 2" & Test_final$Date_filmed == 9, "7",
                         ifelse( Test_final$Trial == "Trial 3" & Test_final$Date_filmed == 3, "1",
                                                       ifelse( Test_final$Trial == "Trial 3" & Test_final$Date_filmed == 4, "2",
                                                               ifelse( Test_final$Trial == "Trial 3" & Test_final$Date_filmed == 5, "3",
                                                                       ifelse( Test_final$Trial == "Trial 3" & Test_final$Date_filmed == 8, "6",
                                                                               ifelse( Test_final$Trial == "Trial 4" & Test_final$Date_filmed == 4, "1",
                                                                                       ifelse( Test_final$Trial == "Trial 4" & Test_final$Date_filmed == 6, "3",
                                                                                               ifelse( Test_final$Trial == "Trial 4" & Test_final$Date_filmed == 7, "4",
                                                                                                       ifelse( Test_final$Trial == "Trial 4" & Test_final$Date_filmed == 10, "7",
                                                                                                               ifelse( Test_final$Trial == "Trial 5" & Test_final$Date_filmed == 6, "2",
                                                                                                                       ifelse( Test_final$Trial == "Trial 5" & Test_final$Date_filmed == 9, "5",
                                                                                                                               ifelse( Test_final$Trial == "Trial 5" & Test_final$Date_filmed == 10, "6",                    
                                                                                                                                       ifelse( Test_final$Trial == "Trial 5" & Test_final$Date_filmed == 11, "7",
                                                                                                                                               ifelse( Test_final$Trial == "Trial 6" & Test_final$Date_filmed == 7, "3",
                                                                                                                                                       ifelse( Test_final$Trial == "Trial 6" & Test_final$Date_filmed == 8, "4",
                                                                                                                                                               ifelse( Test_final$Trial == "Trial 6" & Test_final$Date_filmed == 10, "6",
                                                                                                                                                                       ifelse( Test_final$Trial == "Trial 7" & Test_final$Date_filmed == 10, "3",
                                                                                                                                                                               ifelse( Test_final$Trial == "Trial 7" & Test_final$Date_filmed == 13, "6",
                                                                                                                                                                                       ifelse( Test_final$Trial == "Trial 8" & Test_final$Date_filmed == 10, "3",
                                                                                                                                                                                               ifelse( Test_final$Trial == "Trial 8" & Test_final$Date_filmed == 11, "4",
                                                                                                                                                                                                       ifelse( Test_final$Trial == "Trial 8" & Test_final$Date_filmed == 13, "6",
                                                                                                                                                                                                               ifelse( Test_final$Trial == "Trial 8" & Test_final$Date_filmed == 14, "7",
                                                                                                                                                                                                                       ifelse( Test_final$Trial == "Trial 9" & Test_final$Date_filmed == 10, "2",
                                                                                                                                                                                                                               ifelse( Test_final$Trial == "Trial 9" & Test_final$Date_filmed == 11, "3",
                                                                                                                                                                                                                                       ifelse( Test_final$Trial == "Trial 9" & Test_final$Date_filmed == 13, "5",
                                                                                                                                                                                                                                               ifelse( Test_final$Trial == "Trial 10" & Test_final$Date_filmed == 12, "3",
                                                                                                                                                                                                                                                       NA  ))))))))))))))))))))))))))))

#Trial 10 - because R though it was trail 1
Test_final$Trial <- ifelse(Test_final$Trial == "Trial 1" & Test_final$Date_filmed == 12, "Trial 10",
                           Test_final$Trial)
Test_final$Day_filmed <- ifelse( Test_final$Trial == "Trial 10" & Test_final$Date_filmed == 12, "3",
                                 Test_final$Day_filmed)


#Cleaning up data on group size
new_data <-Test_final
new_data <-new_data[ -c(16:27) ] # Not sure why there are so many NA columns
new_data1<- subset(new_data,Group_size!="NA") # remove female-female interactions where group size was NA
new_data1 <- new_data1 %>% mutate_at(vars(Group_size,Female,Male), funs(round(., 1))) 
graph_dat <- new_data1[c(1,9:13,15:19)] # data frame with info needed for graphs
graph_dat <- unique(graph_dat)

#adding in female sizes
library(dplyr)
graph_dat <- graph_dat %>% mutate(Max_length =
                     case_when(Trial =="Trial 1" ~ "115.2", 
                               Trial =="Trial 2" ~ "116.6",
                               Trial =="Trial 3" ~ "121.4",
                               Trial =="Trial 4" ~ "123.6",
                               Trial =="Trial 5" ~ "113.2",
                               Trial =="Trial 6" ~ "119.4",
                               Trial =="Trial 7" ~ "122.2",
                               Trial =="Trial 8" ~ "113.7",
                               Trial =="Trial 9" ~ "116.4",
                               Trial =="Trial 10"~ "113.5",                   
                               ))

graph_dat <- graph_dat %>% mutate(Min_length =
                               case_when(Trial =="Trial 1" ~ "87.8", 
                                         Trial =="Trial 2" ~ "89.8",
                                         Trial =="Trial 3" ~ "90.4",
                                         Trial =="Trial 4" ~ "86.8",
                                         Trial =="Trial 5" ~ "94.2",
                                         Trial =="Trial 6" ~ "83.2",
                                         Trial =="Trial 7" ~ "83.9",
                                         Trial =="Trial 8" ~ "88",
                                         Trial =="Trial 9" ~ "94.8",
                                         Trial =="Trial 10"~ "94.4",                   
                               ))


i<- c(11:13)
graph_dat[ , i] <- apply(graph_dat[ , i], 2,            
                    function(x) as.numeric(as.character(x)))

graph_dat$Difference <- (graph_dat$Max_length - graph_dat$Min_length)

dat <-graph_dat[c("Trial", "Difference", "Max_length")]
dat <-unique(dat)

# Calculating the proportion of chasing
prop_chasing <- table(graph_dat$Trial, graph_dat$Chasing_present )
prop_chasing <- as.data.frame(rbind(prop_chasing))
prop_chasing$No <- as.numeric(prop_chasing$No)
prop_chasing$Yes <- as.numeric(prop_chasing$Yes)
prop_chasing$sum <-prop_chasing$No + prop_chasing$Yes
prop_chasing$Prop_No <- round(prop_chasing$No/prop_chasing$sum, 3)
prop_chasing$Prop_Yes <- round(prop_chasing$Yes/prop_chasing$sum, 3)
prop_chasing$Trial <- rownames(prop_chasing)
prop_chase <- prop_chasing[c(3:6)]
prop_chase <- merge(prop_chase, dat, by="Trial")
prop_long <- gather(prop_chase, Present, Proportion_chasing, Prop_No:Prop_Yes, factor_key=TRUE)



# Graphs - feel free to delete what you like here

library(ggplot2)

# Ending with chasing vs group size
ggplot(graph_dat, aes(x=Chasing_end, y=Group_size))+
  geom_jitter() + stat_summary(fun=median, geom="point", shape=18,
         size=5, color="red") + theme_classic() + labs(title="Median group size")
# Chasing present vs number of males in group
ggplot(graph_dat, aes(x=Chasing_present, y=Male, color=Time_of_Day))+
  geom_jitter(position=position_dodge(0.8)) +
  geom_boxplot(position=position_dodge(0.8)) +
  theme_classic()
# Total duration of courtship bout vs whether chasing was present
ggplot(graph_dat, aes(x=total_time_of_courtship, y=Chasing_present))+
  geom_jitter() +
  stat_summary(fun=median, geom="point", shape=18,size=3, color="red")+
  theme_classic()

# Difference in female body size vs whether chasing was present
ggplot(graph_dat, aes(x=Difference, y=Chasing_present))+
  geom_jitter() + stat_summary(fun=median, geom="point", shape=18,size=3, color="red")+
  theme_classic()

# The proportion of chasing in each trail
ggplot(prop_long, aes(x=Trial, y=Proportion_chasing, color=Present))+
  geom_point() + theme_classic()

# The proportion of chasing vs female size difference with point scales to sample size - way 1
ggplot(prop_chase, aes(x=Difference, y=Prop_Yes, cex=(sum/5)))+
  geom_point() + theme_classic() + labs(x="Female Size Difference (mm)",
                                        y="Proportion of Chasing present")

# The proportion of chasing vs female size difference with point scales to sample size - way 2
prop_chase$samplesize <- prop_chase$sum/10
plot(prop_chase$Prop_Yes ~ prop_chase$Difference, cex=(prop_chase$samplesize),
      pch=16, col="black",
       xlim=c(15,40), xlab="Female Size Difference (mm)", 
       ylab="Proportion of Chasing present")
