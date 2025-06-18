# model-parameters-template
This repo provides a template for all current model parameter documents. The goal is to describe the model and outline all the steps to go from the starting variables in the model to calculating the outcome of the model. These files provide a transparent, detailed description of the model for publication and/or implementation. See https://big-life-lab.github.io/model-parameters/ for more details.

## Setup

### Installing Dependencies

This project uses [renv](https://rstudio.github.io/renv/) for R dependency
management. To set up the development environment:

1. Open R in the project directory (renv will automatically activate)
2. Install all required dependencies:
   ```r
   renv::restore()
   ```

## Documentation

The `docs/` directory contains the Quarto project for the model parameter
documentation website. This includes all the source files (.qmd),
configuration (_quarto.yml), and supporting assets needed to build and deploy
the documentation. The documentation is automatically built and deployed to
GitHub Pages when changes are pushed to the main branch.
