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

# Do we proceed to a complete refresh of the data. If not, we start with the
# existing file
COMPLETE_REFRESH = FALSE

if (COMPLETE_REFRESH) {
  # What do the names of entries in the files correspond to in the data frame.
  # Obtained by running something like the following
  # list_fields = c()
  # for (i in 1:dim(abstract_files)[1]) {
  #   curr_speaker = process_yml_header(abstract_files$fqfn[i])
  #   list_fields = c(list_fields, names(curr_speaker))
  # }
  # list_fields = unique(list_fields)
  names_list_in_df = list(
    name = "name",
    first_name = "first_name",
    last_name = "last_name",
    institution = "institution",
    institution_country  = "institution_country",
    email = "email",
    web_page = "web_page",
    plenary = "plenary",
    minisymposium = "ms_1",
    minisymposium2 = "ms_2"     
  )
  
  all_participants = 
    data.frame(
      first_name = character(), 
      last_name = character(),
      name = character(),
      email = character(),
      web_page = character(),
      email2 = character(),
      department = character(),
      institution = character(),
      institution_address = character(),
      institution_country = character(),
      plenary = character(),
      ms_1 = character(), # Minisymposium talk
      ms_2 = character(),
      ms_3 = character(),
      ct_1 = character(), # Contributed talk
      ct_2 = character(),
      ct_3 = character(),
      so_1 = character(), # Session organiser
      so_2 = character(),
      local_organiser = numeric(),
      scientific_committee = numeric()
    )
} else {
  all_participants = read.csv("CMPD6-all-participants.csv")
  # Just in case we added some stuff manually, let us sort things a bit
  all_participants = all_participants[order(all_participants$last_name),]
  row.names(all_participants) = 1:dim(all_participants)[1]
}

## ABSTRACTS
# Get list of posted abstracts
abstract_files = data.frame(
  file_name = list.files(path = "../_speakers",
                         pattern = glob2rx("*.md"))
)
abstract_files = abstract_files %>%
  filter(file_name != "template_speaker.md")
abstract_files$fqfn = sprintf("../_speakers/%s", abstract_files$file_name)

for (i in 1:dim(abstract_files)[1]) {
  curr_speaker = process_yml_header(abstract_files$fqfn[i])
  # Add an empty row to the data frame
  all_participants[nrow(all_participants)+1,] <- NA
  curr_row = dim(all_participants)[1]
  # Transcribe required fields
  for (n in names(curr_speaker)) {
    if (n %in% names(names_list_in_df)) {
      if (is.null(curr_speaker[[n]])) {
        all_participants[curr_row,names_list_in_df[[n]]] = NA
      } else {
        all_participants[curr_row,names_list_in_df[[n]]] = 
          curr_speaker[[n]]
      }
    }
  }
}

## Now add people from the minisymposia
minisymposium_files = data.frame(
  file_name = list.files(path = "../_minisymposia",
                         pattern = glob2rx("*.md"))
)
minisymposium_files$fqfn = sprintf("../_minisymposia/%s", minisymposium_files$file_name)
for (i in 1:dim(minisymposium_files)[1]) {
  curr_minisymposium = process_yml_header(minisymposium_files$fqfn[i])
  for (o in curr_minisymposium$organisers) {
    # Add an empty row to the data frame
    all_participants[nrow(all_participants)+1,] <- NA
    curr_row = dim(all_participants)[1]
    # Add the organiser
    all_participants$name[curr_row] = o
  }
  for (s in curr_minisymposium$speakers) {
    # Add an empty row to the data frame
    all_participants[nrow(all_participants)+1,] <- NA
    curr_row = dim(all_participants)[1]
    # Add the speaker
    all_participants$name[curr_row] = s
  }
}

## Remove duplicates
all_participants = all_participants[!duplicated(all_participants$name),]

# Try separating first and last names when not done
for (i in 1:dim(all_participants)[1]) {
  if (is.na(all_participants$last_name[i])) {
    tmp = strsplit(all_participants$name[i], " ")
    all_participants$first_name[i] = tmp[[1]][1]
    all_participants$last_name[i] = tmp[[1]][length(tmp[[1]])]
  }
}

## Sort
all_participants = all_participants[order(all_participants$last_name),]
row.names(all_participants) = 1:dim(all_participants)[1]

## Try to infer country for people missing country
for (i in 1:dim(all_participants)[1]) {
  if (is.na(all_participants$institution_country[i]) ||
      nchar(all_participants$institution_country[i])==0) {
    if (!is.na(all_participants$email[i])) {
      writeLines(paste0("No country for ", all_participants$name[i],
                        " (email ",
                        all_participants$email[i],")"))
      # Places for which it is not obvious
      if (grepl("moffitt.org", all_participants$email[i]) ||
          grepl(".edu", all_participants$email[i])) {
        email_ctry = "USA"
      } else {
        tmp_email = strsplit(all_participants$email[i], "\\.")
        end_email = tmp_email[[1]][length(tmp_email[[1]])]
        idx_ctry = which(codelist$cctld == sprintf(".%s", end_email))
        if (length(idx_ctry)>0) {
          email_ctry = codelist$iso.name.en[idx_ctry]
          writeLines(paste0("Found ", email_ctry))
          all_participants$institution_country[i] = email_ctry
        }
      }
    }
  }
}

write.csv(all_participants, file = "CMPD6-all-participants.csv",
          row.names = FALSE, na = "")
