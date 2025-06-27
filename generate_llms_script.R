#!/usr/bin/env Rscript

# Load required libraries
library(yaml)

# Get the directory of this script - handle various ways R scripts can be called
args <- commandArgs(trailingOnly = FALSE)
script_path <- NULL

# Find the --file argument
for (i in seq_along(args)) {
  if (grepl("^--file=", args[i])) {
    script_path <- substring(args[i], 8)
    break
  }
}

# If no --file argument, assume we're in the project root
if (is.null(script_path)) {
  script_dir <- "."
} else {
  script_dir <- dirname(script_path)
}

# Source the generate_llms function directly
source(file.path(script_dir, "R", "generate_llms_md.R"))

# Call the generate_llms function
generate_llms_md()
