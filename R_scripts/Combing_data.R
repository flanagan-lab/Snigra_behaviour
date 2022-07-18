
# Combining new and original data - still has issues----------------------------------------------------

#### Trying to combine data from Chase_datasheets and BORIS_data (after it has been read in via Readin_data script)

# Issues: courtship bout 117, 342 and 343 are missing from all_dat. 14, 16 and 18 also missing but I know why - no active courtship behaviour in those bouts so deleted from chase data


setwd("C:/Users/Owner/OneDrive - University of Canterbury/Pipefish/Pipefish_data/Chase_datasheets")

new_data<-dplyr::bind_rows(lapply(list.files(pattern="Trial"), read.csv))


colnames(new_data) <- c("media_file_path", "time_in_video", "Duration",              
                        "behavior" , "subject" ,"modifier_1" ,"modifier_2","modifier_3" ,"Group_size", "Female", "Male" ,
                        "Chasing_end" , "Chasing_present" , "courtship_events_wrong" , "total_time_of_courtship")

final_data$combo<-paste(final_data$media_file_path, 
                        final_data$time_in_video, 
                        round(final_data$Duration,3), 
                        round(final_data$total_time_of_courtship,3), sep="_")
new_data$combo<-paste(new_data$media_file_path, 
                      new_data$time_in_video, 
                      round(new_data$Duration,3) ,
                      round(new_data$total_time_of_courtship,3), sep="_")


# sarah's new line with dummy code
all_dat <- merge(final_data, new_data[,c("combo","media_file_path", "time_in_video", "Duration" , "total_time_of_courtship",
                                         "Group_size", "Female", "Male","Chasing_end" , "Chasing_present"
)], 
by="combo")


