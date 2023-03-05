# Process list of minisymposia
library(yaml)
library(dplyr)
library(stringr)

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

## MINISYMPOSIA
minisymposia = read.csv("CMPD6-minisymposia.csv", skip = 1)
colnames(minisymposia) = c("date",
                        "first_name", "last_name",
                        "email",  
                        "level_study",
                        "affiliation",
                        "symposium_title",
                        "symposium_organisers",
                        "symposium_abstract", "symposium_speakers",
                        "symposium_received",
                        "vote_S", "vote_KL", "vote_J",
                        "sent")

minisymposium_files = data.frame(
  file_name = list.files(path = "../_minisymposia",
                         pattern = glob2rx("*.md"))
)
minisymposium_files$fqfn = sprintf("../_minisymposia/%s", minisymposium_files$file_name)
minisymposium_info = list()
fields = c()
for (i in 1:dim(minisymposium_files)[1]) {
  curr_minisymposium = process_yml_header(minisymposium_files$fqfn[i])
  minisymposium_info[[i]] = list()
  minisymposium_info[[i]] = curr_minisymposium
  fields = c(fields,names(curr_minisymposium))
}
# Prepare the fields
fields = unique(fields)
# Make columns for all the fields we have found
for (f in fields) {
  minisymposium_files = cbind(minisymposium_files,
                         rep(NA, dim(minisymposium_files)[1]))
  colnames(minisymposium_files)[dim(minisymposium_files)[2]] = f
}
# Fill in the information
for (i in 1:dim(minisymposium_files)[1]) {
  for (n in names(minisymposium_info[[i]])) {
    if (minisymposium_info[[i]][n] != "NULL") {
      minisymposium_files[i, n] = minisymposium_info[[i]][n]
    }
  }
}


## Comparisons
# Do we have more information in the csv file than in the md files?
for (i in 1:dim(minisymposia)[1]) {
  idx_symposium = which(minisymposium_files$title == minisymposia$symposium_title[i])
  if (length(idx_symposium) == 0) {
    # We don't seem to have a file for this person, let's populate what is needed
    symposium = list()
    symposium$layout = "page"
    symposium$name = minisymposia$symposium_title[i]
    symposium$title = minisymposia$symposium_title[i]
    symposium$hide = FALSE
    ## END of YAML HEADER, put it in the output
    OUT = paste0("---\n", 
                 as.yaml(symposium),
                 "---\n")
    # Things that go in the md part of the file, not the yaml header
    if (nchar(minisymposia$symposium_organisers[i])>0) {
      OUT = paste0(OUT,
                   "### Organisers\n\n",
                   minisymposia$symposium_organisers[i],
                   "\n\n")
    }
    if (nchar(minisymposia$symposium_abstract[i])>0) {
      OUT = paste0(OUT,
                   "### Description\n\n",
                   minisymposia$symposium_abstract[i],
                   "\n\n")
    }
    # Prepare save of file
    file_name = sprintf("%s.md",
                        tolower(gsub(" ", "-", minisymposia$symposium_title[i])))
    write(OUT, file = sprintf("../_minisymposia/%s", file_name))
    #write(OUT, file = sprintf("%s", file_name))
  }
}