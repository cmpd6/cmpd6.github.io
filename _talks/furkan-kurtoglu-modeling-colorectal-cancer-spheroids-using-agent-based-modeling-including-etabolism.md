---
speakers:
- Furkan Kurtoglu
name: Modeling Colorectal Cancer Spheroids using Agent-Based Modeling Including Metabolism
categories:
- Minisymposium lectures
name_ms: modelling-the-cancer-microenvironment
ms_number: C1
hide: no
---
Colorectal Cancer (CRC) is the third most diagnosed cancer type worldwide. It is a complex and multi-scale disease that requires advanced techniques to model. We utilize 3-D Agent-Based Modeling (ABM) to scale from a single scale to hundreds of spheroids. A Flux Balance Analysis (FBA) metabolic model is built based on experimental metabolomic and growth data. We integrated the intracellular chemical model into each agent in ABM. Spatial information provides how much metabolite is available locally and exposed pressure from other cells to individual cells that regulate glucose and glutamine transfer reactions. FBA with updated boundaries is used to simulate intracellular reactions that yield biomass. The creation rate of biomass is used for the volumetric growth of agents. Intelligent cells proliferate in the case of having adequate cellular volume. The local microenvironmental concentrations are updated based on diffusion, secretion, and consumption of metabolites. With this approach, we created a multiscale benchmark that controls growth based on the microenvironment. However, the whole computational simulation is expensive and time-consuming; thus, we enhanced this framework with two major improvements: using Deep Neural Network (DNN) as a surrogate model and using adaptive mesh in the microenvironment. The DNN is trained by synthetic data obtained by high-throughput simulations by FBA. Additionally, the portion of the microenvironment which does not contain cells is coarsened to make simulations faster. We developed and calibrated our model based on empirical data in a monolayer setup. DLD-1 cell line spheroid simulations are consistent with experimental data. Our benchmark can be used to find drug targets in high throughput simulations with virtual knockdown effects at multi-scale.
