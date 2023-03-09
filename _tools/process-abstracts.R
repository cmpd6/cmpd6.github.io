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
abstracts = read.csv("CMPD6-abstracts.csv", skip = 1)
colnames(abstracts) = c("type_of_talk", "minisymposium_name",
                        "first_name", "last_name",
                        "email", "web_page",
                        "affiliation", "level_study",
                        "talk_title", "talk_abstract",
                        "vote_S", "vote_KL", "vote_J",
                        "sent")
abstracts$first_name = str_trim(str_to_title(abstracts$first_name))
abstracts$last_name = str_trim(str_to_title(abstracts$last_name))

# Get list of posted abstracts
abstract_files = data.frame(
  file_name = list.files(path = "../_speakers",
                         pattern = glob2rx("*.md"))
)
abstract_files = abstract_files %>%
  filter(file_name != "template_speaker.md")
abstract_files$fqfn = sprintf("../_speakers/%s", abstract_files$file_name)

speaker_info = list()
fields = c()
for (i in 1:dim(abstract_files)[1]) {
  curr_speaker = process_yml_header(abstract_files$fqfn[i])
  speaker_info[[i]] = list()
  speaker_info[[i]] = curr_speaker
  fields = c(fields,names(curr_speaker))
}
# Prepare the fields
fields = unique(fields)
# Make columns for all the fields we have found
for (f in fields) {
  abstract_files = cbind(abstract_files,
                         rep(NA, dim(abstract_files)[1]))
  colnames(abstract_files)[dim(abstract_files)[2]] = f
}
# Fill in the information
for (i in 1:dim(abstract_files)[1]) {
  for (n in names(speaker_info[[i]])) {
    if (speaker_info[[i]][n] != "NULL") {
      abstract_files[i, n] = speaker_info[[i]][n]
    }
  }
}
# Try to infer country for people missing country
for (i in 1:dim(abstract_files)[1]) {
  if (is.na(abstract_files$institution_country[i])) {
    writeLines(paste0("No country for ", abstract_files$name[i],
                      " (email ",
                      abstract_files$email[i],")"))
    # Places for which it is not obvious
    if (grepl("moffitt.org", abstract_files$email[i]) ||
        grepl(".edu", abstract_files$email[i])) {
      email_ctry = "USA"
    } else {
      tmp_email = strsplit(abstract_files$email[i], "\\.")
      end_email = tmp_email[[1]][length(tmp_email[[1]])]
      email_ctry = countrycode(end_email,
                               origin = "iso2c",
                               destination = "country.name")
    }
    writeLines(paste0("Found ", email_ctry))
    abstract_files$institution_country[i] = email_ctry
  }
}

## MINISYMPOSIA
# (Not processing here, but we need the information)
minisymposium_files = data.frame(
  file_name = list.files(path = "../_minisymposia",
                         pattern = glob2rx("*.md"))
)
minisymposium_files$fqfn = sprintf("../_minisymposia/%s", minisymposium_files$file_name)
# Each minisymposium is a list in the following list
minisymposium_info = list()
# We keep track of the minisymposium names in a vector for easy access
minisymposium_files$title = rep(NA, dim(minisymposium_files)[1])
# fields = c()
for (i in 1:dim(minisymposium_files)[1]) {
  curr_minisymposium = process_yml_header(minisymposium_files$fqfn[i])
  minisymposium_info[[i]] = list()
  minisymposium_info[[i]] = curr_minisymposium
  minisymposium_files$title[i] = curr_minisymposium$title
#  fields = c(fields,names(curr_minisymposium))
}
# Prepare the fields
# fields = unique(fields)
# Make columns for all the fields we have found
# for (f in fields) {
#   minisymposium_files = cbind(minisymposium_files,
#                          rep(NA, dim(minisymposium_files)[1]))
#   colnames(minisymposium_files)[dim(minisymposium_files)[2]] = f
# }
# # Fill in the information
# for (i in 1:dim(minisymposium_files)[1]) {
#   for (n in names(minisymposium_info[[i]])) {
#     if (minisymposium_info[[i]][n] != "NULL") {
#       minisymposium_files[i, n] = minisymposium_info[[i]][n]
#     }
#   }
# }


## Comparisons
# Do we have more information in the csv file than in the md files?
for (i in 1:dim(abstracts)[1]) {
  idx_firstname = which(abstract_files$first_name == abstracts$first_name[i])
  idx_lastname = which(abstract_files$last_name == abstracts$last_name[i])
  idx_presenter = intersect(idx_firstname, idx_lastname)
  # We store the information for the current presentation in a list
  presenter = list()
  if (length(idx_presenter) == 0) {
    ## New presentation
    # We don't seem to have a file for this person, let's populate what is needed
    presenter$first_name = abstracts$first_name[i]
    presenter$last_name = abstracts$last_name[i]
    presenter$name = paste(presenter$first_name,presenter$last_name)
    presenter$institution = abstracts$affiliation[i]
    presenter$institution_country = NA
    presenter$email = abstracts$email[i]
    if (nchar(abstracts$web_page[i])>0) {
      presenter$web_page = abstracts$web_page[i]
    }
    presenter$plenary = FALSE
  } else {
    # We already have a file. We check if the csv contains more information
    # and if so, add it
    presenter$first_name = abstracts$first_name[i]
    presenter$last_name = abstracts$last_name[i]
    presenter$name = paste(presenter$first_name,presenter$last_name)
    presenter$institution = abstracts$affiliation[i]
    if (!is.na(abstract_files$institution_country[idx_presenter])) {
      presenter$institution_country = 
        abstract_files$institution_country[idx_presenter]
    } 
    if (nchar(abstracts$email[i])>0) {
      presenter$email = abstracts$email[i]
    }
    if (nchar(abstracts$web_page[i])>0) {
      presenter$web_page = abstracts$web_page[i]
    }
    # # Check some info from the existing files themselves
    # tmp = process_yml_header(abstract_files$fqfn[idx_presenter])
    # # Plenaries can only already exist, so set to FALSE unless it is
    # # indeed a plenary
    # if (!tmp$plenary) {
    #   presenter$plenary = FALSE
    # }
  }
  ## COMMON INFO
  # Type of talk
  if (abstracts$type_of_talk[i] == "Contributed Talk") {
    presenter$minisymposium = FALSE
  } else if (abstracts$type_of_talk[i] == "I am presenting as part of a minisymposium") {
    presenter$minisymposium = TRUE
    # We find the minisymposium
    minisymp_title = abstracts$minisymposium_name[i]
    minisymp_idx = which(minisymposium_files$title == minisymp_title)
    if (length(minisymp_idx)>0) {
      presenter$minisymposium_title = 
        gsub(".md", "", 
             minisymposium_files$file_name[minisymp_idx])
    }
  }
  presenter$hide = FALSE
  ## END of YAML HEADER, put it in the output
  OUT = paste0("---\n", 
               as.yaml(presenter),
               "---\n")
  # Things that go in the md part of the file, not the yaml header
  if (nchar(abstracts$talk_title[i])>0) {
    OUT = paste0(OUT, "\n## ",
                 abstracts$talk_title[i],
                 "\n\n")
  }
  if (nchar(abstracts$talk_abstract[i])>0) {
    OUT = paste0(OUT,
                 abstracts$talk_abstract[i],
                 "\n\n")
  }
  # Prepare save of file
  file_name = sprintf("%s-%s.md",
                      tolower(gsub(" ", "-", abstracts$first_name[i])),
                      tolower(gsub(" ", "-", abstracts$last_name[i])))
  if (TESTING) {
    #write_yaml(OUT, file = file_name)
    cat(OUT, file = file_name, sep = "\n")
  } else {
    #write(OUT, file = sprintf("../_speakers/%s", file_name))
    cat(OUT, file = sprintf("../_speakers/%s", file_name), sep = "\n")
  }
}