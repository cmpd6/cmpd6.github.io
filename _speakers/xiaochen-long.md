---
first_name: Xiaochen
last_name: Long
name: Xiaochen Long
institution: Rice University
institution_country: .na
email: xl81@rice.edu
plenary: no
minisymposium: yes
hide: no
---

## A Branching Process Model of Clonal Hematopoiesis

We propose a hierarchical branching process model for clonal hematopoiesis. The model consists of a basic model that simulates clonal expansions and an observation process that represents the detection procedures. We consider two variants for the basic model, both based on Kendall's birth-death branching process: the first with Poisson migration, which models recurrent mutations from a fixed number of hematopoietic stem cells in spatially constrained niches, and the second with a single clone's expansion with a random starting time point. The latter variant assumes that a single mutation event gives rise to the observed mutant clones, which is appropriate when mutations only occur once. The observation process is a binomial sampling with the sequencing coverage as the total number of samples and the ratio of mutants from the basic model as the probability of detection. We also introduce multiple-timepoint observations and formulate the model as a Hidden Markov Model, which can be estimated using Sequential Monte Carlo methods. Particularly, we derive the pmf of the two-timepoint model for estimation and the transition probability within the hidden layer.
 
 Our basic model, particularly Kendall's birth-death branching process with Poisson migration, produces comparable results to Watson et al. (2020), which can be seen as an approximation of our model under a low mutation rate. Our model's predictions are consistent with the sequencing data from nearly 50,000 healthy individuals in various studies. Furthermore, by incorporating multiple-timepoint settings, our model enables the estimation and prediction of samples collected from a single individual at different times, as well as the depiction of the entire clonal expansion history of the mutant clones from their emergence to dominance.


