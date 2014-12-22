library("httr")
library("rvest")

get_regions <- function(species, year = "allyrs") {
  tbl <- get_birds(species = species, extent = "Rg", year = year)
  
  names(tbl) <- c("Region", "Species", "Max_BE", "BE_Category", "Sq_number", 
                  "Atlasser", "Num_PC", "Percent_PC", "Abundance", "Num_of_Squares")
  tbl
  
}

get_squares <- function(species, reg_num, year = "allyrs") {
  tbl <- get_birds(species = species, extent = "Sq", 
                   reg_num = as.character(reg_num), year = year)
  
  names(tbl) <- c("Region", "Square", "Species", "Max_BE", "BE_Category", "Sq_number", 
                  "Atlasser", "Num_PC", "Percent_PC", "Abundance", "Num_of_Squares")
  tbl
  
}

get_birds <- function(species, extent, reg_num = NULL, year = "allyrs") {
  url <- "http://www.birdatlas.bc.ca/bcdata/datasummaries.jsp"
  
  if (extent == "Rg" && is.null(reg_num)) {
    reg_num <- "0"
  }
  
  args = list(extent=extent, 
              summtype="SqList", 
              year=year, 
              byextent1="Prov", 
              byextent2="Sq", 
              region2="1", 
              squarePC="", 
              region1="0", 
              square="", 
              region3=reg_num, 
              species1=species, 
              lang="en")
  
  res <- GET(url, query = args)
  
  res <- content(res)
  
  tbl <- html_table(res, fill = TRUE)[[2]][-c(1,2),]
  
  tbl
}

breeding_colours_hex <- function(categories) {
  cols <- ifelse(categories == "CONF", "red", 
                 ifelse(categories == "POSS", "yellow", 
                        "orange"))
  
  hex_cols <- rgb(t(col2rgb(cols)), maxColorValue = 255)
  hex_cols
}
