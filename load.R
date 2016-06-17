
library("tidyr")

# Load the data from csv file, this comes from the Qualtrics survey, headers are loaded separately as the second row is extra header info not needed 
header <- read.csv("Facebook.csv", nrows=1, header=FALSE, stringsAsFactors=FALSE)
data <- read.csv("Facebook.csv", skip=2, header=FALSE, stringsAsFactors=FALSE)
names(data) <- header[1,]

# Load the eye tracking data from csv file, this comes from the Qualtrics survey, headers are loaded separately as the second row is extra header info not needed 
eye_header <- read.csv("Eyetracking.csv", nrows=1, header=FALSE, stringsAsFactors=FALSE)
eye_data <- read.csv("Eyetracking.csv", skip=2, header=FALSE, stringsAsFactors=FALSE)
names(eye_data) <- eye_header[1,]

library("dplyr")
data <- bind_rows(data, eye_data)

# Delete the extra fields added by Qualtrics which are blank or nonrelevant
delete <- c("V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10", "SC0_0", "SC0_1", "SC0_2", "logo", "intro", "error.message", "thanks", "LocationLatitude", "LocationLongitude", "LocationAccuracy","instructions","Q385")
delete <- c(delete, "profile.f001", "profile.f002", "profile.f003", "profile.f004", "profile.f005", "profile.f006", "profile.f007", "profile.f008", "profile.f009", "profile.f010", "profile.f011", "profile.f012", "profile.f013", "profile.f014", "profile.f015", "profile.f016", "profile.f017", "profile.f018", "profile.f019", "profile.f020", "profile.f021", "profile.f022", "profile.f023", "profile.f024", "profile.f025", "profile.f026", "profile.f027", "profile.f028", "profile.f029", "profile.f030", "profile.f031", "profile.f032", "profile.f033", "profile.f034", "profile.f035", "profile.f036")
delete <- c(delete, "profile.m001", "profile.m002", "profile.m003", "profile.m004", "profile.m005", "profile.m006", "profile.m007", "profile.m008", "profile.m009", "profile.m010", "profile.M011", "profile.m012", "profile.m013", "profile.m014", "profile.m015", "profile.m016", "profile.m017", "profile.m018", "profile.m019", "profile.m020", "profile.m021", "profile.m022", "profile.M023", "profile.m024", "profile.m025", "profile.m026", "profile.m027", "profile.m028", "profile.m029", "profile.m030", "profile.m031", "profile.m032", "profile.m033", "profile.m034", "profile.m035", "profile.m036")

data <- data[, !(names(data) %in% delete)] 
names(data)[1]="id"

eye_data <- eye_data[, !(names(eye_data) %in% delete)] 
names(eye_data)[1]="id"


# Remove variables no longer needed
rm(delete)
rm(header)
rm(eye_header)
rm(eye_data)

# The first schools data for tv.use hours was incorrect due to a validation error and should be marked as NA
data$tv.use[1:9] <- NA
# One entry was recorded as 24, which would suggested they were watching 24 hours of tv a day, assuming this is an error it is being removed
data$tv.use[data$tv.use==24] <- NA


# Code some the relevant totals

# Coding the Prompted Recall data

# Profile ratings - 
# Unhealthy: 01:03, 10:12, 19:21, 28:30
# Healthy: 04:06, 13:15, 22:24, 31:33
# Nonfood: 07:09, 16:18, 25:27, 34:36
# Celebrity: 02, 05, 08, 11, 14, 17, 20, 23, 26, 29, 32, 36
# Peer: 01, 04, 07, 10, 13, 16, 19, 22, 27, 31, 34
# Sponsored: 03, 06, 09, 12, 15, 18, 21, 24, 25, 30, 33, 35

p01 <- as.integer(data$familiarity_1)
p02 <- as.integer(data$familiarity_3)
p03 <- as.integer(data$familiarity_2)
p04 <- as.integer(data$familiarity_5)
p05 <- as.integer(data$familiarity_6)
p06 <- as.integer(data$familiarity_44)
p07 <- as.integer(data$familiarity_8)
p08 <- as.integer(data$familiarity_9 + data$familiarity_37)
p09 <- as.integer(data$familiarity_10)
p10 <- as.integer(data$familiarity_11)
p11 <- as.integer(data$familiarity_12)
p12 <- as.integer(data$familiarity_13)
p13 <- as.integer(data$familiarity_14)
p14 <- as.integer(data$familiarity_15)
p15 <- as.integer(data$familiarity_16)
p16 <- as.integer(data$familiarity_17)
p17 <- as.integer(data$familiarity_18 + data$familiarity_38)
p18 <- as.integer(data$familiarity_19)
p19 <- as.integer(data$familiarity_20)
p20 <- as.integer(data$familiarity_21)
p21 <- as.integer(data$familiarity_22)
p22 <- as.integer(data$familiarity_23)
p23 <- as.integer(data$familiarity_24)
p24 <- as.integer(data$familiarity_25)
p25 <- as.integer(data$familiarity_26)
p26 <- as.integer(data$familiarity_27 + data$familiarity_39)
p27 <- as.integer(data$familiarity_28)
p28 <- as.integer(data$familiarity_29)
p29 <- as.integer(data$familiarity_30)
p30 <- as.integer(data$familiarity_31)
p31 <- as.integer(data$familiarity_32)
p32 <- as.integer(data$familiarity_33)
p33 <- as.integer(data$familiarity_41)
p34 <- as.integer(data$familiarity_35 + data$familiarity_40)
p35 <- as.integer(data$familiarity_36)
p36 <- as.integer(data$familiarity_4)


# Create data frames groups into celebrity, peer, and sponsored
rating<- data.frame(data$id, p01, p02, p03, p04, p05, p06, p07, p08, p09, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36)

# Convert any of the NAs into 0s
rating[is.na(rating)] <- 0

# Converting to long format
rating_long <- gather(rating, profile, rating, p01:p36)

# Any 2s should be changed to 1, this is where the user incorrectly ticked the product of the opposite gender in addition to their own
rating_long[rating_long == 2] <- 1


# Create data frames for each of the nine conditions

# Unhealthy Peer
unhealthy_peer <- data.frame(id = data$id, recall = p01)
unhealthy_peer <- rbind(unhealthy_peer, data.frame(id = data$id, recall = p10))
unhealthy_peer <- rbind(unhealthy_peer, data.frame(id = data$id, recall = p19))
unhealthy_peer <- rbind(unhealthy_peer, data.frame(id = data$id, recall = p28))
unhealthy_peer$product <- factor(1, levels = c(1,2,3), labels = c("Unhealthy", "Healthy","NonFood"))
unhealthy_peer$endorse <- factor(1, levels = c(1,2,3), labels = c("Peer", "Celebrity","Sponsored"))

# Unhealthy Celebrity
unhealthy_celebrity <- data.frame(id = data$id, recall = p02)
unhealthy_celebrity <- rbind(unhealthy_celebrity, data.frame(id = data$id, recall = p11))
unhealthy_celebrity <- rbind(unhealthy_celebrity, data.frame(id = data$id, recall = p20))
unhealthy_celebrity <- rbind(unhealthy_celebrity, data.frame(id = data$id, recall = p29))
unhealthy_celebrity$product <- factor(1, levels = c(1,2,3), labels = c("Unhealthy", "Healthy","NonFood"))
unhealthy_celebrity$endorse <- factor(2, levels = c(1,2,3), labels = c("Peer", "Celebrity","Sponsored"))

# Unhealthy Sponsored
unhealthy_sponsored <- data.frame(id = data$id, recall = p03)
unhealthy_sponsored <- rbind(unhealthy_sponsored, data.frame(id = data$id, recall = p12))
unhealthy_sponsored <- rbind(unhealthy_sponsored, data.frame(id = data$id, recall = p21))
unhealthy_sponsored <- rbind(unhealthy_sponsored, data.frame(id = data$id, recall = p30))
unhealthy_sponsored$product <- factor(1, levels = c(1,2,3), labels = c("Unhealthy", "Healthy","NonFood"))
unhealthy_sponsored$endorse <- factor(3, levels = c(1,2,3), labels = c("Peer", "Celebrity","Sponsored"))

# Healthy Peer
healthy_peer <- data.frame(id = data$id, recall = p04)
healthy_peer <- rbind(healthy_peer, data.frame(id = data$id, recall = p13))
healthy_peer <- rbind(healthy_peer, data.frame(id = data$id, recall = p22))
healthy_peer <- rbind(healthy_peer, data.frame(id = data$id, recall = p31))
healthy_peer$product <- factor(2, levels = c(1,2,3), labels = c("Unhealthy", "Healthy","NonFood"))
healthy_peer$endorse <- factor(1, levels = c(1,2,3), labels = c("Peer", "Celebrity","Sponsored"))

# Healthy Celebrity
healthy_celebrity <- data.frame(id = data$id, recall = p05)
healthy_celebrity <- rbind(healthy_celebrity, data.frame(id = data$id, recall = p14))
healthy_celebrity <- rbind(healthy_celebrity, data.frame(id = data$id, recall = p23))
healthy_celebrity <- rbind(healthy_celebrity, data.frame(id = data$id, recall = p32))
healthy_celebrity$product <- factor(2, levels = c(1,2,3), labels = c("Unhealthy", "Healthy","NonFood"))
healthy_celebrity$endorse <- factor(2, levels = c(1,2,3), labels = c("Peer", "Celebrity","Sponsored"))

# Healthy Sponsored
healthy_sponsored<- data.frame(id = data$id, recall = p06)
healthy_sponsored<- rbind(healthy_sponsored, data.frame(id = data$id, recall = p15))
healthy_sponsored<- rbind(healthy_sponsored, data.frame(id = data$id, recall = p24))
healthy_sponsored<- rbind(healthy_sponsored, data.frame(id = data$id, recall = p33))
healthy_sponsored$product <- factor(2, levels = c(1,2,3), labels = c("Unhealthy", "Healthy","NonFood"))
healthy_sponsored$endorse <- factor(3, levels = c(1,2,3), labels = c("Peer", "Celebrity","Sponsored"))

# Nonfood: 07:09, 16:18, 25:27, 34:36

# Nonfood Peer
nonfood_peer <- data.frame(id = data$id, recall = p07)
nonfood_peer <- rbind(nonfood_peer, data.frame(id = data$id, recall = p16))
nonfood_peer <- rbind(nonfood_peer, data.frame(id = data$id, recall = p27))
nonfood_peer <- rbind(nonfood_peer, data.frame(id = data$id, recall = p34))
nonfood_peer$product <- factor(3, levels = c(1,2,3), labels = c("Unhealthy", "Healthy","NonFood"))
nonfood_peer$endorse <- factor(1, levels = c(1,2,3), labels = c("Peer", "Celebrity","Sponsored"))

# Nonfood Celebrity
nonfood_celebrity <- data.frame(id = data$id, recall = p08)
nonfood_celebrity <- rbind(nonfood_celebrity, data.frame(id = data$id, recall = p17))
nonfood_celebrity <- rbind(nonfood_celebrity, data.frame(id = data$id, recall = p26))
nonfood_celebrity <- rbind(nonfood_celebrity, data.frame(id = data$id, recall = p36))
nonfood_celebrity$product <- factor(3, levels = c(1,2,3), labels = c("Unhealthy", "Healthy","NonFood"))
nonfood_celebrity$endorse <- factor(2, levels = c(1,2,3), labels = c("Peer", "Celebrity","Sponsored"))

# Nonfood Sponsored
nonfood_sponsored <- data.frame(id = data$id, recall = p09)
nonfood_sponsored <- rbind(nonfood_sponsored, data.frame(id = data$id, recall = p18))
nonfood_sponsored <- rbind(nonfood_sponsored, data.frame(id = data$id, recall = p25))
nonfood_sponsored <- rbind(nonfood_sponsored, data.frame(id = data$id, recall = p35))
nonfood_sponsored$product <- factor(3, levels = c(1,2,3), labels = c("Unhealthy", "Healthy","NonFood"))
nonfood_sponsored$endorse <- factor(3, levels = c(1,2,3), labels = c("Peer", "Celebrity","Sponsored"))

prompted_recall <- rbind(unhealthy_peer, healthy_peer, nonfood_peer, unhealthy_celebrity, healthy_celebrity, nonfood_celebrity, unhealthy_sponsored, healthy_sponsored, nonfood_sponsored)

# Any 2s should be changed to 1, this is where the user incorrectly ticked the product of the opposite gender in addition to their own
prompted_recall[prompted_recall == 2] <- 1

# Convert any of the NAs into 0s
prompted_recall[is.na(prompted_recall)] <- 0

# Change Recall into a factor
prompted_recall$recall <- factor(prompted_recall$recall, levels = c(0,1), labels = c("Forgot", "Recalled"))

# Remove the ID as I don't think we need it. This line can be removed if it turns out we do need it
prompted_recall$id <- NULL

# Table for prompted Recall
prompted_recall_table <- xtabs(~product + endorse + recall, data=prompted_recall)

# Delete random stuff
delete <- c("healthy_celebrity", "healthy_peer", "healthy_sponsored", "nonfood_celebrity", "nonfood_peer", "nonfood_sponsored", "p01", "p02", "p03", "p04")
delete <- c(delete, "p05", "p06", "p07")        
delete <- c(delete, "p08", "p09", "p10", "p11", "p12", "p13", "p14", "p15", "p16", "p17", "p18", "p19", "p20", "p21", "p22", "p23", "p24", "p25", "p26")        
delete <- c(delete, "p27", "p28", "p29", "p30", "p31", "p32", "p33", "p34", "p35", "p36", "rating", "unhealthy_celebrity", "unhealthy_peer", "unhealthy_sponsored")

rm(list = delete)
rm(delete)
rm(rating_long)
