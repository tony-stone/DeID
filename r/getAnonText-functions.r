getAnonText <- function(freetext) {
  anon_text_list <- parallel::mclapply(freetext, getAnonTextJSON, mc.cores = 16L)

  anon_text <- data.table::rbindlist(anon_text_list)

  return(anon_text)
}


getAnonTextJSON <- function(freetext) {
  payload <- tryCatch(jsonlite::fromJSON(getAnonTextHTTPResponse(freetext)),
                      error = function(e) NA)

  # On error
  if(all(is.na(payload))) {
    return(data.frame(freetext,
                      anon_freetext = as.character(NA),
                      status = "ERROR",
                      stringsAsFactors = FALSE))
  }

  # On no route
  if(payload$code != "Ok") {
    return(data.frame(freetext,
                      anon_freetext = as.character(NA),
                      status = "NO_RESPONSE",
                      stringsAsFactors = FALSE))
  }

  return(data.frame(freetext,
                    anon_freetext = payload[["anonymised_text"]],
                    status = "OK",
                    stringsAsFactors = FALSE))
}


getAnonTextHTTPResponse <- function(value) {
  url <- httr::modify_url("http://172.17.0.2",
                          port = "8080",
                          path = "/predict",
                          query = "overview=false")

  httr::content(httr::POST(url, body = paste0('{"freetext":"', value, '"}'), encode = "raw"))
}
