---
first_name: Ernesto
last_name: Lima
name: Ernesto Lima
institution: The University of Texas at Austin
institution_country: USA
email: ernesto.lima@utexas.edu
minisymposium: yes
hide: no
---

## Development and calibration of a stochastic, multiscale agent-based model for predicting tumor and vasculature growth

Agent-based models (ABMs) are a powerful tool for simulating tumor growth. However, they suffer from high computational costs—especially if the stochastic nature of phenotypic transitions is included in the formulation of the model. To address these limitations, we have developed two multiscale ABMs, one avascular and one vascular, and calibrated them to experimental data.
 
 The avascular model is a coarse-grained two-scale ABM (cgABM) calibrated with time-resolved microscopy measurements of BT474 human breast carcinoma cells grown with different initial conditions. The model consists of a reaction-diffusion type model capturing the spatiotemporal evolution of glucose and growth factors in the tumor microenvironment, coupled with a lattice-free ABM to simulate individual cell dynamics. We perform a global sensitivity analysis to identify the relative importance of model parameters, followed by a Bayesian calibration that accounts for the stochasticity of the cgABM. The results show that the cgABM can reliably predict the spatiotemporal evolution of breast cancer cells observed by microscopy data.
 
 The vascularized multiscale model of tumor angiogenesis combines an ABM of tumor and endothelial cell dynamics with a continuum model that captures the spatiotemporal variations in the concentration of vascular endothelial growth factor. We first calibrate ordinary differential equation models to time-resolved protein concentration data to estimate the rates of secretion and consumption of vascular endothelial growth factor by endothelial and tumor cells, respectively. These parameters are then input into the multiscale model while the remaining model parameters are calibrated to time-resolved confocal microscopy images obtained within a 3D vascularized microfluidic platform. The model is able to globally recapitulate angiogenic vasculature density. Additionally, the model's ability to predict local vessel morphology is assessed and shows promising results.
 
 Our multiscale ABMs demonstrate the ability to predict tumor growth and angiogenesis with experimental data, providing a platform for systematic testing of mathematical predictions of tumor dynamics.


