# Process list of abstracts
library(yaml)
library(dplyr)
library(stringr)
library(countrycode)



all_participants = read.csv("CMPD6-registrations.csv") %>%
  arrange(Last.Name,First.Name)

N = dim(all_participants)[1]

if (FALSE) {
  # One sided only
  people = data.frame(
    firstname = rep(all_participants$First.Name, times = 1, each = 2),
    lastname = rep(all_participants$Last.Name, times = 1, each = 2),
    organisation = rep(all_participants$Organization, times = 1, each = 2)
  )
} else {
  # Two sided. However, badges are created from right to left, top to bottom.
  # So we need to list names as
  # A, B, C, A, B, C, D, E, F, D, E, F, etc.
  people = data.frame(
    firstname = rep(NA, times = 2*N),
    lastname = rep(NA, times = 2*N),
    organisation = rep(NA, times = 2*N)
  )
  nb_pages = N/3
  person_nb = 1
  for (page in 1:floor(nb_pages)) {
    people$firstname[6*(page-1)+1] = all_participants$First.Name[person_nb]
    people$firstname[6*(page-1)+2] = all_participants$First.Name[person_nb+1]
    people$firstname[6*(page-1)+3] = all_participants$First.Name[person_nb+2]
    people$firstname[6*(page-1)+4] = all_participants$First.Name[person_nb]
    people$firstname[6*(page-1)+5] = all_participants$First.Name[person_nb+1]
    people$firstname[6*(page-1)+6] = all_participants$First.Name[person_nb+2]
    people$lastname[6*(page-1)+1] = all_participants$Last.Name[person_nb]
    people$lastname[6*(page-1)+2] = all_participants$Last.Name[person_nb+1]
    people$lastname[6*(page-1)+3] = all_participants$Last.Name[person_nb+2]
    people$lastname[6*(page-1)+4] = all_participants$Last.Name[person_nb]
    people$lastname[6*(page-1)+5] = all_participants$Last.Name[person_nb+1]
    people$lastname[6*(page-1)+6] = all_participants$Last.Name[person_nb+2]
    people$organisation[6*(page-1)+1] = all_participants$Organization[person_nb]
    people$organisation[6*(page-1)+2] = all_participants$Organization[person_nb+1]
    people$organisation[6*(page-1)+3] = all_participants$Organization[person_nb+2]
    people$organisation[6*(page-1)+4] = all_participants$Organization[person_nb]
    people$organisation[6*(page-1)+5] = all_participants$Organization[person_nb+1]
    people$organisation[6*(page-1)+6] = all_participants$Organization[person_nb+2]
    person_nb = person_nb+3
  }
}

# \participant{Large-font Name}{Small-font Name}{Affiliation}{Pronoun}{}
OUT = sprintf("\\participant{%s}{%s}{%s}{(\\qquad | \\qquad)}{}",
              str_trim(people$firstname), 
              str_trim(people$lastname),
              str_trim(people$organisation))

fileConn<-file("participants.tex")
writeLines(OUT, fileConn)
close(fileConn)
