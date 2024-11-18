library(xml2)
library(dplyr)

xml_file <- read_xml("2023 PPs/SIMD20230101AQU_USA/SIMD20230101AQU_USA.xml")

# Extract all Race nodes
race_nodes <- xml_find_all(xml_file, ".//Race")

# Extract relevant fields for each Race
race_data <- lapply(race_nodes, function(race) {
    list(
        RaceNumber = xml_find_first(race, ".//RaceNumber") %>% xml_text(),
        DayEvening = xml_find_first(race, ".//DayEvening") %>% xml_text(),
        Distance = xml_find_first(race, ".//Distance/PublishedValue") %>% xml_text(),
        PostTime = xml_find_first(race, ".//PostTime") %>% xml_text(),
        RaceType = xml_find_first(race, ".//RaceType/Description") %>% xml_text(),
        NumberOfRunners = xml_find_first(race, ".//NumberOfRunners") %>% xml_text(),
        Purse = xml_find_first(race, ".//PurseUSA") %>% xml_text()
    )
})

# Convert the list to a data frame
race_df <- do.call(rbind, lapply(race_data, as.data.frame))
View(race_df)

# Extract Starter nodes within each Race
starter_data <- lapply(race_nodes, function(race) {
    race_number <- xml_find_first(race, ".//RaceNumber") %>% xml_text()

    starters <- xml_find_all(race, ".//Starters/Horse")

    lapply(starters, function(horse) {
        list(
            RaceNumber = race_number,
            HorseName = xml_find_first(horse, ".//HorseName") %>% xml_text(),
            RegistrationNumber = xml_find_first(horse, ".//RegistrationNumber") %>% xml_text(),
            Color = xml_find_first(horse, ".//Color/Value") %>% xml_text(),
            Trainer = xml_find_first(horse, ".//Trainer/LastName") %>% xml_text(),
            WeightCarried = xml_find_first(horse, ".//WeightCarried") %>% xml_text()
        )
    })
})

# Flatten nested list and convert to data frame
starter_data_flat <- do.call(rbind, lapply(unlist(starter_data, recursive = FALSE), as.data.frame))
