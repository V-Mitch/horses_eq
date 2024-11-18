library(xml2)
library(dplyr)

zip_file <- "2023 PPs/SIMD20230101AQU_USA.zip"

files_in_zip <- unzip(zip_file, list = TRUE)
xml_content <- unzip(zip_file, files = files_in_zip$Name[1], exdir = tempdir(), junkpaths = TRUE)
