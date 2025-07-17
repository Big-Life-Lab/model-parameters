create_reference_Rmd <- function(
  file_metadata,
  column_metadata,
  column_category_metadata
  ) {
  reference_Rmd_lines <- c()
  
  reference_Rmd_lines <- c(
    reference_Rmd_lines,
    "# Reference"
  )
  
  for(file_metadata_row_index in 1:nrow(file_metadata)) {
    file_name <- file_metadata[file_metadata_row_index, "fileName"]

    reference_Rmd_lines <- c(
      reference_Rmd_lines,
      paste("##", file_name)
    )

    reference_Rmd_lines <- c(
      reference_Rmd_lines,
      file_metadata[file_metadata_row_index, "fileLabel"]
    )

    algorithm_type <- file_metadata[file_metadata_row_index, "algorithmType"]
    if (is.na(algorithm_type) | trimws(algorithm_type) == "") {
      cli::cli_abort(c(
        "Every file type must have an algorithm type",
        "x" = "No algorithm type found for file type {file_name}",
        "i" = "The error is in row {file_metadata_row_index} in the file
               metadata",
        "i" = "The allowed algorithm type values are all, simple-model,
               survival, cox, and fine-and-gray"
      ))
    }
    algorithm_type_display <- paste0(
      "**Algorithm type(s):** ", gsub(";", ", ", algorithm_type)
    )
    reference_Rmd_lines <- c(
      reference_Rmd_lines,
      algorithm_type_display
    )

    column_metadata_for_file <- column_metadata[
      column_metadata$fileName == file_name,
    ]
    if(nrow(column_metadata_for_file) == 0) {
      stop(paste("No column metadata found for file", file_name))
    }

    reference_Rmd_lines <- c(reference_Rmd_lines, "### Columns")

    columns_table_header <- paste0(
      c(
        "| Column Name | Description | Type | Category Values |",
        "|-|-|-|-|"
      ),
      collapse = "\n"
    )
    columns_table_rows <- purrr::pmap_chr(
     column_metadata_for_file,
     function(columnName, columnType, columnLabel, ...) {
        column_categories <- dplyr::if_else(
          columnType == "category",
          .format_column_categories(
            column_category_metadata[
              column_category_metadata$fileName == file_name &
                column_category_metadata$columnName == columnName, ]
          ),
          ""
        )
        columns_table_row <- paste(
          "|", columnName,
          "|", columnLabel,
          "|", columnType,
          "|", column_categories,
          "|"
        )
        return(columns_table_row)
      }
    )
    columns_table_contents <- c(
      columns_table_header,
      columns_table_rows
    )
    reference_Rmd_lines <- c(
      reference_Rmd_lines, paste(columns_table_contents, collapse = "\n"))
  }
  return(cat(reference_Rmd_lines, sep = "\n\n"))
}

#' Formats the categories of a categorical column for display
#' The categories are formatted as:
#' {category_value_1}:{category_description_1}
#' {category_value_2}:{category_description_2}
#' ...
#'
#' @param categories a data.frame containing the metadata for all
#' the categories that need to be formatted. The structure should follow
#' what's in the inst/metadata/column-category.csv file.
#' @returns a string containing the formatted categories
.format_column_categories <- function(categories) {
  if(nrow(categories) == 0) {
    return("")
  }
  category_string <- purrr::pmap_chr(
    categories,
    function(columnValue, desc, ...) {
      return(paste0("<b>", columnValue, ":</b> ", desc))
    }
  )
  return(paste0(category_string, collapse = "<br/>"))
}
