#' Generate llms.md file for AI agents
#'
#' This function reads the _quarto.yml configuration file, extracts the website
#' title and sidebar contents, and generates an llms.md file in the output 
#' directory for AI agents to understand the site structure.
#'
#' @export
generate_llms_md <- function() {
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
  
  title <- quarto_config$website$title
  llms_md_title <- paste0("# ", title, "\n\n")

  llms_md_pages_header <- paste0("## Pages", "\n\n")

  sidebar_contents <- quarto_config$website$sidebar$contents
  # Check for nested sidebar contents (not supported)
  for (item in sidebar_contents) {
    if (!is.null(item$section) || !is.null(item$contents)) {
      stop("Nested sidebar contents are not supported")
    }
  }
  llms_md_page_links <- purrr::map_chr(sidebar_contents, ~ {
    if (is.null(.x$href) || is.null(.x$text)) {
      return("")
    }
    link_href <- gsub("\\.qmd$", ".html", .x$href)
    return(paste0("- [", .x$text, "](", link_href, ")\n"))
  })

  llms_content <- paste(
    c(llms_md_title, llms_md_pages_header, llms_md_page_links)
  )

  output_dir <- Sys.getenv("QUARTO_PROJECT_OUTPUT_DIR")
  
  # Write the llms.md file
  llms_file_path <- file.path(output_dir, "llms.md")
  
  tryCatch({
    writeLines(llms_content, llms_file_path)
  }, error = function(e) {
    stop("Failed to write llms.md file: ", e$message)
  })
  
  message("Generated llms.md file at: ", llms_file_path)
}
