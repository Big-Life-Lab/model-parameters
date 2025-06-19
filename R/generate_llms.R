#' Generate llms.md file for AI agents
#'
#' This function reads the _quarto.yml configuration file, extracts the website
#' title and sidebar contents, and generates an llms.md file in the output 
#' directory for AI agents to understand the site structure.
#'
#' @return NULL (invisibly). The function is called for its side effects.
#' @export
generate_llms <- function() {
  # Check if _quarto.yml exists
  if (!file.exists("_quarto.yml")) {
    stop("Could not find _quarto.yml file in the current directory")
  }
  
  # Read and parse the YAML file
  tryCatch({
    quarto_config <- yaml::read_yaml("_quarto.yml")
  }, error = function(e) {
    stop("Failed to read _quarto.yml file: ", e$message)
  })
  
  # Validate YAML structure
  if (is.null(quarto_config$website)) {
    stop("Invalid _quarto.yml structure: missing 'website' section")
  }
  
  if (is.null(quarto_config$website$title)) {
    stop("Invalid _quarto.yml structure: missing 'website.title'")
  }
  
  if (is.null(quarto_config$website$sidebar) || 
      is.null(quarto_config$website$sidebar$contents)) {
    stop("Invalid _quarto.yml structure: missing 'website.sidebar.contents'")
  }
  
  # Extract title and sidebar contents
  title <- quarto_config$website$title
  sidebar_contents <- quarto_config$website$sidebar$contents
  
  # Check for nested sidebar contents (not supported)
  for (item in sidebar_contents) {
    if (!is.null(item$section) || !is.null(item$contents)) {
      stop("Nested sidebar contents are not supported")
    }
  }
  
  # Generate the llms.md content
  llms_content <- paste0("# ", title, "\n\n")
  
  # Add page links
  for (item in sidebar_contents) {
    if (!is.null(item$href) && !is.null(item$text)) {
      # Convert .qmd to .html for the link
      html_href <- gsub("\\.qmd$", ".html", item$href)
      llms_content <- paste0(llms_content, "- [", item$text, "](", 
                            html_href, ")\n")
    }
  }
  
  # Determine output directory
  output_dir <- Sys.getenv("QUARTO_PROJECT_OUTPUT_DIR")
  if (output_dir == "") {
    # Default to 'dist' if environment variable not set
    output_dir <- "dist"
  }
  
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Write the llms.md file
  llms_file_path <- file.path(output_dir, "llms.md")
  
  tryCatch({
    writeLines(llms_content, llms_file_path)
  }, error = function(e) {
    stop("Failed to write llms.md file: ", e$message)
  })
  
  message("Generated llms.md file at: ", llms_file_path)
  
  invisible(NULL)
}
