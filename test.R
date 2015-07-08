library(sp)
library(rgdal)
library(maptools)
library(rgeos)
library(plyr)
library(dplyr)
library(ggplot2)
library(ggmap)
library(gridExtra)
#
#for no loop see at the end
################
################with loop
#
#setwd("/Users/drisk/Desktop/Natural_Study/Reprocessed/2014/") #except NStoNB dataset
setwd("/Users/drisk/Desktop/Natural_Study/Reprocessed/2015/")
#setwd("/Users/drisk/Desktop/Natural_Study/Reprocessed/NewBrunswick/")
#setwd("/Users/drisk/Desktop/Natural_Study/Reprocessed/NB_RC_TEMP/")
#
system("echo xxx > old.filenames.tab") # obviously don't do this again One time thing Only at the beginning
#
(dirs <- list.dirs(path = ".", full.names = TRUE, recursive = TRUE))
all.filenames<-list.files(dirs, pattern=".csv$", full.names = TRUE)
old.filenames<-read.table("old.filenames.tab")
filenames<-all.filenames[!(all.filenames %in% old.filenames$V1)]
write.table(all.filenames,file="old.filenames.tab",row.names=FALSE)
#
#A lot of works to make sure all have same columns (names and number)
import.list <- llply(filenames, read.table, header=TRUE, sep=",",na.strings="NA", dec=".", strip.white=TRUE,  fill=TRUE)
#
#df1 <- do.call("rbind", import.list)
#read shapefile of the land cover  # note: Shapefiles are made from at least three files, the .shp which is the geometry, the .dbf which is the database, and the .shx which connects the two.
#
Road <- readShapeLines("/Users/drisk/Desktop/nrn_rrn_ns_shp_en/NRN_NS_11_0_ROADSEG.shp")
proj4string(Road) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
Road_pc <- spTransform(Road, CRS = CRS("+init=epsg:2957")) #
#
#
############################################################################################
############################################################################################
#This script is to apply RUNMIN on Picarro 2201 drive-around datasets and calculate e-ratios based on RUNMINS, and normal GLOBAL mins
#Written by Dave Risk and Martin Lavoie, October 20 2014
#
#The script expects 
#     1. A Drive-around file already processed#####
#
#The script does the following:
#      A. Interpolates Picarro output to 1 second resolution in case there are gaps and to apply the RUNMIN interval correctly
#      B. Puts a runmin through the CO2, CH4, and d13CH4 concentrations (look for input areas)
#      C. Calculate ratios
#	D. Outputs summary information for each of the averaged columns 
#
#V2 - Sept 20 2014. Now includes 1 minute averaging in before runmin, general script cleaning
	#And "seeding" of the eratio with 1/1000 the normal values of CO2 and CH4, to start it off on natural
	#The rest will be deviation in eratio from natural 
	#But, this technique controls the sensitivity.  Too much natural eratio, and that's a problem.
#V3 - For New Glasgow Shiny Data
#V4 - This version iterates to test runmins and padding - to examine laplace kurtosis
#v5 - This version counts the number of peaks, and optimizes
############################################################################################