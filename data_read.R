library(xml2)
library(dplyr)

read_data <- function(file_path){
    # for recording time spent to run the function
    start_time <- Sys.time()

    # Load the XML file
    xml_file <- read_xml(file_path)


    # Extract all Race nodes
    race_nodes <- xml_find_all(xml_file, ".//Race")

    # Extract detailed Race information
    race_data <- lapply(race_nodes, function(race) {
        list(
            RaceNumber = xml_find_first(race, ".//RaceNumber") %>% xml_text(),
            DayEvening = xml_find_first(race, ".//DayEvening") %>% xml_text(),
            Distance = xml_find_first(race, ".//Distance/PublishedValue") %>% xml_text(),
            PostTime = xml_find_first(race, ".//PostTime") %>% xml_text(),
            RaceType = xml_find_first(race, ".//RaceType/Description") %>% xml_text(),
            NumberOfRunners = xml_find_first(race, ".//NumberOfRunners") %>% xml_text(),
            Purse = xml_find_first(race, ".//PurseUSA") %>% xml_text(),
            TrackCondition = xml_find_first(race, ".//TrackCondition/Value") %>% xml_text(),
            Weather = xml_find_first(race, ".//Weather") %>% xml_text(),
            MaximumClaimPrice = xml_find_first(race, ".//MaximumClaimPrice") %>% xml_text(),
            ConditionsOfRace = xml_find_first(race, ".//ConditionText") %>% xml_text()
        )
    })

    # Convert race data to a data frame
    race_df <- do.call(rbind, lapply(race_data, as.data.frame))

    # Extract detailed Starter information
    starter_data <- lapply(race_nodes, function(race) {
        race_number <- xml_find_first(race, ".//RaceNumber") %>% xml_text()

        starters <- xml_find_all(race, ".//Starters/Horse")

        lapply(starters, function(horse) {
            list(
                RaceNumber = race_number,
                HorseName = xml_find_first(horse, ".//HorseName") %>% xml_text(),
                RegistrationNumber = xml_find_first(horse, ".//RegistrationNumber") %>% xml_text(),
                Color = xml_find_first(horse, ".//Color/Value") %>% xml_text(),
                Sex = xml_find_first(horse, ".//Sex/Value") %>% xml_text(),
                FoalingDate = xml_find_first(horse, ".//FoalingDate") %>% xml_text(),
                WeightCarried = xml_find_first(horse, ".//WeightCarried") %>% xml_text(),
                Jockey = xml_find_first(horse, ".//Jockey/LastName") %>% xml_text(),
                Trainer = xml_find_first(horse, ".//Trainer/LastName") %>% xml_text(),
                Odds = xml_find_first(horse, ".//Odds") %>% xml_text(),
                PositionAtFinish = xml_find_first(horse, ".//Start/OfficialFinish") %>% xml_text(),
                PostPosition = xml_find_first(horse, ".//PostPosition") %>% xml_text()
            )
        })
    })

    # Flatten and convert to data frame
    starter_data_flat <- do.call(rbind, lapply(unlist(starter_data, recursive = FALSE), as.data.frame))

    # Combine Race and Starter data
    combined_df <- starter_data_flat %>%
        left_join(race_df, by = "RaceNumber")
    end_time <- Sys.time()
    elapsed_time <- start_time - end_time
    print(paste0("Completed: ", file_path, " data downloaded in", round(elapsed_time,2), " seconds"))
    return(combined_df)
    }
