library("togeojson")
library("sp")
library("rgdal")
library("dplyr")

source("get_birds.R")

# unzip("data/bcatlas_shape.zip", exdir = "data")

## Read in the full grid of squares
squares <- readOGR("data", layer = "bcatlas_squares", stringsAsFactors = FALSE)

## Get species codes
sp_codes <- read.csv("data/bc_bird_codes.csv", stringsAsFactors = FALSE)

## Set species
spps <- c("WIWR", "YERA", "BCHU","RTHU","CAHU","CAVI","BUFF","COGO","BAGO",
          "AWPE","LEBI","NOGO","SWHA","ARTE","LEWO","WISA","WHWO","BRCR",
          "PAWR","GRSP","AMBI","SMLO","SNBU")
# Errors: "SBDO", "BTHU"

for (spp in spps) {
  if (!spp %in% sp_codes$sp_code) print(paste(spp, "is not a valid species code"))
}

for (spp in spps) {
  
  csv_filename <- paste0("data/spp_squares/",spp, "_squares.csv")
  
  if (file.exists(csv_filename)) {
    spp_squares <- read.csv(csv_filename, stringsAsFactors = FALSE)
  } else {
    ## Get the regions the species was detected in
    regions <- get_regions(spp)
    
    ## Get the occupied squares based on the regions
    spp_squares <- lapply(regions, function(x) {
      get_squares(spp, reg_num = x)
    }) %>%
    rbind_all() %>%
    as.data.frame()
    
  }
  
  ## Set the colours based on breeding evidence category
  spp_squares$fill <- breeding_colours_hex(spp_squares$BE_Category)
  spp_squares$stroke <- spp_squares$fill
  spp_squares$Atlasser <- NULL
  
  write.csv(spp_squares, file = csv_filename, row.names = FALSE)
  
  ## Merge the occupied squares with the full grid
  spp_sp_squares <- merge(squares, spp_squares, 
                          by.x = "SQUARE_ID", by.y = "Square", all.x = FALSE)
  
  ## Write the geojson file
  proj4string(spp_sp_squares) <- "" # Seem to need to remove the proj4string
  the_file <- paste0("maps/", spp, ".geojson")
  geojson_write(input = spp_sp_squares, file = the_file)
}

