##### Creating a for loop #####
library(tidyverse)

courtfiles<-list.files(path="C:/Users/Owner/OneDrive - University of Canterbury/Pipefish/BORIS output/Final_sheets", pattern="csv",full.names=TRUE)
# path and folder where spreadsheets are kept
courtdat<-data.frame(matrix(ncol=13,nrow=0)) # creating an empty data frame for data to be placed in. 
# creating a for loop, read following lines again and again till i = length of courtfiles i.e. number of spreadsheets I need to load from BORIS output


courtdat<- lapply(courtfiles, function(file){           #no function so we just put file
  temp<-scan(file, "character", sep='\n', quiet = TRUE) #scan through data to line ending 
  nlines<- grep("Time,", temp)                      #fine line that starts with Time
  dat<-read.csv(file, skip=nlines-1) # skip everything above line that starts with Time
  dat$Modifier.3<-as.character(dat$Modifier.3) # Mod 3 has both numbers and words change to character
  dat$file.name<-file         ## add something in here to cut the path of file name so its just sample
  return(dat)
})   
courtdat<-bind_rows(courtdat)

dat1<-courtdat







extract_times <- function(dat1){
  
  nn <- nrow(dat1)
  
  
  starting_points <- c()
  end_points <- c()
  
  #get where observations start
  for(i in 1:nn){
    d <- dat1[i,]
    
    behavior <- d$Behavior
    
    if(behavior == "Start"){
      print("start")
      starting_points <- c(starting_points, i)
    }
    
    if(behavior == "Stop"){
      print("end")
      end_points <- c(end_points, i)
    }
    
    
  }
  return(list(starting_points,end_points))
}
  
#select chunks of data and using the function created dat1
  times<-extract_times(dat1) ### change to courtdat when not using snip
  starting_points<-times[[1]]
  end_points<-times[[2]]
  observation_chunks <- list()
 
  n2 <- length(starting_points) ### is this setting the length to the numberof starting points?
  
  for(j in 1:n2){
    start <- starting_points[j]
    print(start)
    end <- end_points[j]
    print(end)
    
    dat <- dat1[start:end, ]
    print(dat)
    
    observation_chunks[[j]] <- dat
    
  }
  
  
  #extract the information we want from chunks of observations
  
  useful_list <- lapply(seq_along(observation_chunks), function(chunk){
    
    
    x <- observation_chunks[[chunk]]
    x$Modifier.1[is.na(x$Modifier.1)]<-""
    x$Modifier.2[is.na(x$Modifier.2)]<-""
    x$Modifier.3[is.na(x$Modifier.3)]<-""
    n3 <- nrow(x)
    
    length_of_chunk <- x$Time[n3] - x$Time[1] 
    times <-data.frame()
   
    
    for(k in 1:n3){
      x_row <- x[k,]
      
      if(x_row$Behavior== "Start" | x_row$Behavior== "Stop" ){
        next()
      }else{
        
        selected_behavior <- x_row$Behavior
        selected_subject <- x_row$Subject
        selected_m1 <- x_row$Modifier.1
        selected_m2 <- x_row$Modifier.2 
        selected_m3 <- x_row$Modifier.3
        selected_status <- x_row$Status
        
        if(selected_status=="START"){
          end_row <- x[which   (x$Behavior==selected_behavior &
                               x$Subject== selected_subject & 
                               x$Modifier.1 == selected_m1 &
                               x$Modifier.2 == selected_m2 &
                               x$Modifier.3 == selected_m3 &
                               x$Status == "STOP" &
                                 x$Time>=x_row$Time),]
         
          ####THE PROBLEM IS HERE, there is more than one end !
          
          
         
          
          #if(nrow(end_row)==0){
            
           #if there's no matching stop, use the end of the observation period
           ## end_row <- x[which   ( x$Subject== selected_subject & 
                                    #x$Status == "START" &
                                    #x$Time>x_row$Time),]
         ## browser()
           
           
          #}
          #if(nrow(end_row)==0){
            ##time_elapsed<-0
          ##}else{
          time_elapsed <- end_row$Time[which.min(end_row$Time-x_row$Time)] - x_row$Time
          #}
          if(nrow(end_row)==0){
            print(paste(x_row$Media.file.path,x_row$Time,time_elapsed ))
          }
      
          return_data_per_row <- data.frame("media_file_path"= x_row$Media.file.path,
                                            "time_in_video"= x_row$Time,
                                            "Duration"= time_elapsed,
                                            "behavior"= selected_behavior,
                                            "subject"=selected_subject,
                                            "modifier_1" = selected_m1, 
                                            "modifier_2"= selected_m2,
                                            "modifier_3"= selected_m3)
          
          
          times <-rbind(times, return_data_per_row )
          
        }
        
        if(selected_status == "STOP"){
          next()
        }
        
        if(selected_status == "POINT"){
         
          return_data_per_row <- data.frame("media_file_path"= x_row$Media.file.path,
                                            "time_in_video"= x_row$Time,
                                            "Duration"= 0.00,
                                            "behavior"= selected_behavior,
                                            "subject"=selected_subject,
                                            "modifier_1" = selected_m1, 
                                            "modifier_2"= selected_m2,
                                            "modifier_3"= selected_m3)
          times <-rbind(times, return_data_per_row )
        }
        
        
        
        
      }
      
    
    
    
  
    }
    times$courtship_events <- chunk
    times$total_time_of_courtship <- length_of_chunk
    
    return(times)  
    })
    

  
  
  
  
  final_data <- do.call(rbind, useful_list)
  
  







# Adding extra data to the final spread sheet -------------------------------------------------------------------

#Adding in Trial number
Test_data <-final_data
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

#Trial 10 
Test_final$Trial <- ifelse(Test_final$Trial == "Trial 1" & Test_final$Date_filmed == 12, "Trial 10",
                           Test_final$Trial)
Test_final$Day_filmed <- ifelse( Test_final$Trial == "Trial 10" & Test_final$Date_filmed == 12, "3",
                                 Test_final$Day_filmed)




