# Process list of abstracts
library(yaml)
library(dplyr)
library(stringr)
library(countrycode)

# Process yaml header
# The markdown files used have just a yaml header; the markdown part
# often causes read_yml to crash. So we process only the header
process_yml_header = function(fqfn) {
  yaml_part = NULL
  con = file(fqfn, "r")
  line = readLines(con, n = 1)
  if (line == "---") {
    in_yaml = TRUE
    while ( in_yaml ) {
      line = readLines(con, n = 1)
      if ( length(line) == 0 ) {
        break
      } else if (line == "---") {
        in_yaml = FALSE
      } else {
        yaml_part = paste0(yaml_part, line, "\n")
      }
    }
  }
  close(con)
  yaml_fields = read_yaml(text = yaml_part)
  return(yaml_fields)
}

# Are we testing (i.e., exporting to the working directory) or in production?
TESTING = FALSE

## ABSTRACTS
# Get list of abstracts from csv file
abstracts_csv = read.csv("CMPD6-abstracts.csv")
# A bit of cleaning of the file
abstracts_csv$first_name = str_trim(str_to_title(abstracts_csv$first_name))
abstracts_csv$last_name = str_trim(str_to_title(abstracts_csv$last_name))
abstracts_csv$email = str_trim(tolower(abstracts_csv$email))
abstracts_csv$full_name = sprintf("%s %s", 
                                 abstracts_csv$first_name,
                                 abstracts_csv$last_name)

# Try to infer country for people missing country
abstracts_csv$institution_country = rep(NA, dim(abstracts_csv)[1])
for (i in 1:dim(abstracts_csv)[1]) {
  if (is.na(abstracts_csv$institution_country[i])) {
    writeLines(paste0("No country for ", abstracts_csv$name[i],
                      " (email ",
                      abstracts_csv$email[i],")"))
    # Places for which it is not obvious
    if (grepl("moffitt.org", abstracts_csv$email[i]) ||
        grepl(".edu", abstracts_csv$email[i]) ||
        grepl(".gov", abstracts_csv$email[i]) ||
        grepl("fredhutch.org", abstracts_csv$email[i])) {
      email_ctry = "USA"
    } else if (grepl("ac.uk", abstracts_csv$email[i])) {
      email_ctry = "UK"
    } else if (grepl("tanya.philippsen@gmail.com", abstracts_csv$email[i])) {
      email_ctry = "Canada"
    } else {
      tmp_email = strsplit(abstracts_csv$email[i], "\\.")
      end_email = tmp_email[[1]][length(tmp_email[[1]])]
      email_ctry = countrycode(end_email,
                               origin = "iso2c",
                               destination = "country.name")
    }
    writeLines(paste0("Found ", email_ctry))
    abstracts_csv$institution_country[i] = email_ctry
  }
}

###
### GENERATE ABSTRACT FILES
###
for (i in 1:dim(abstracts_csv)[1]) {
  # We store the information for the current presentation in a list
  abstract = list()
  abstract$speakers = list(abstracts_csv$full_name[i])
  abstract$name = str_trim(abstracts_csv$talk_title[i])
  if (abstracts_csv$plenary[i] == "P") {
    abstract$categories = list("Plenaries")
  } else if (nchar(abstracts_csv$minisymposium[i])>0) {
    abstract$categories = list("Minisymposium lectures")
    # This is an MS lecture, save which MS it is
    name_ms = tolower(abstracts_csv$name_ms[i])
    name_ms = str_trim(gsub("-\t", "", name_ms))
    name_ms = gsub(" ", "-", name_ms)
    name_ms = gsub("--", "", name_ms)
    abstract$name_ms = name_ms
    abstract$ms_number = abstracts_csv$minisymposium[i]
  } else if (nchar(abstracts_csv$contributed[i])>0) {
    abstract$categories = list("Contributed talks")
  }
  abstract$hide = FALSE
  ## END of YAML HEADER, put it in the output
  OUT = paste0("---\n", 
               as.yaml(abstract),
               "---\n")
  # Things that go in the md part of the file, not the yaml header
  if (nchar(abstracts_csv$talk_abstract[i])>0) {
    OUT = paste0(OUT,
                 abstracts_csv$talk_abstract[i],
                 "\n\n")
  }
  # Prepare save of file
  file_name = sprintf("%s-%s-%s",
                      tolower(gsub(" ", "-", abstracts_csv$first_name[i])),
                      tolower(gsub(" ", "-", abstracts_csv$last_name[i])),
                      tolower(gsub(" ", "-", abstracts_csv$talk_title[i])))
  if (nchar(file_name)>80) {
    # File name is a little long, chop it off
    file_name = substr(file_name, 0, 80)
  }
  file_name = sprintf("%s.md", file_name)
  if (TESTING) {
    cat(OUT, file = sprintf("_talks/%s", file_name), sep = "\n")
  } else {
    cat(OUT, file = sprintf("../_talks/%s", file_name), sep = "\n")
  }
}

###
### GENERATE SPEAKERS FILES
###
speakers = sort(unique(abstracts_csv$full_name))
for (s in speakers) {
  i = which(abstracts_csv$full_name == s)[1]
  # We store the information for the current speaker in a list
  speaker = list()
  speaker$name = abstracts_csv$full_name[i]
  speaker$first_name = abstracts_csv$first_name[i]
  speaker$last_name = abstracts_csv$last_name[i]
  if (nchar(abstracts_csv$website[i])>0) {
    speaker$web_site = abstracts_csv$website[i]
  }
  if (nchar(abstracts_csv$email[i])>0) {
    speaker$email = abstracts_csv$email[i]
  }
  if (nchar(abstracts_csv$institution[i])>0) {
    speaker$institution = abstracts_csv$institution[i]
  }
  if (!is.na(abstracts_csv$institution_country[i])) {
    speaker$institution_country = abstracts_csv$institution_country[i]
  }
  
  speaker$hide = FALSE
  ## END of YAML HEADER, put it in the output
  OUT = paste0("---\n", 
               as.yaml(speaker),
               "---\n")
  # Prepare save of file
  file_name = sprintf("%s-%s.md",
                      tolower(gsub(" ", "-", abstracts_csv$first_name[i])),
                      tolower(gsub(" ", "-", abstracts_csv$last_name[i])))
  if (TESTING) {
    cat(OUT, file = sprintf("_speakers/%s", file_name), sep = "\n")
  } else {
    cat(OUT, file = sprintf("../_speakers/%s", file_name), sep = "\n")
  }
}
