source("r/getAnonText-functions.r")

freetext <- readRDS("data/freetext.rds")

anonymised_text <- getAnonText(freetext)

saveRDS("data/deidentified_freetext.rds")
