# Documentation Development Guide

This directory contains the Quarto project for the model parameter
documentation website.

## Prerequisites

- [Quarto](https://quarto.org/docs/get-started/)
- [R](https://www.r-project.org/) (version 4.2.0 or higher)
- Required R packages which can be seen in the DESCRIPTION file 

## Building the Documentation Locally

To render the documentation on your local machine:

1. Navigate to the project root directory
2. Run the following command:

```bash
quarto render docs
```

The rendered website will be generated in the `docs/dist/` directory.

## AI Agent Support

The build process automatically generates an `llms.md` file in the output 
directory (`docs/dist/llms.md`) that provides a structured overview of the 
site for AI agents. This file contains:

- The website title from `_quarto.yml`
- A list of all pages with their titles and HTML links
- Easy navigation for AI agents to understand the site structure

This file is regenerated automatically every time you run `quarto render` or 
`quarto preview`.

## Viewing/Editing the Documentation

After building, you can preview the documentation locally:

```bash
quarto preview docs
```

This will start a local server and open the documentation in your browser.
The preview will automatically refresh when you make changes to the source
files.

## Deployment

Documentation is automatically built and deployed to GitHub Pages when
changes are pushed to the main branch. The build process is handled by
GitHub Actions workflows in `.github/workflows/`.

