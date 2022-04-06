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

    column_metadata_for_file <- column_metadata[
      column_metadata$fileName == file_name,
    ]
    if(nrow(column_metadata_for_file) == 0) {
      stop(paste("No column metadata found for file", file_name))
    }

    reference_Rmd_lines <- c(reference_Rmd_lines, "### Columns")

    for(column_metadata_row_index in 1:nrow(column_metadata_for_file)) {
      column_name <- column_metadata_for_file[column_metadata_row_index, "columnName"]
      column_type <- column_metadata_for_file[column_metadata_row_index, "columnType"]

      reference_Rmd_lines <- c(reference_Rmd_lines, paste("####", column_name))

      reference_Rmd_lines <- c(
        reference_Rmd_lines,
        column_metadata_for_file[column_metadata_row_index, "columnLabel"]
      )

      reference_Rmd_lines <- c(
        reference_Rmd_lines,
        paste("Type:", column_type)
      )

      if(column_type == "category") {
        column_categories <- column_category_metadata[
          column_category_metadata$fileName == file_name & column_category_metadata$columnName == column_name, ]
        if(nrow(column_categories) == 0) {
          stop(paste("No categories found for column", column_type, "for file", file_name))
        }

        reference_Rmd_lines <- c(
          reference_Rmd_lines,
          paste("##### Categories")
        )
        for(column_category_index in 1:nrow(column_categories)) {
          reference_Rmd_lines <- c(
            reference_Rmd_lines,
            paste("Value:", column_categories[column_category_index, "columnValue"])
          )

          reference_Rmd_lines <- c(
            reference_Rmd_lines,
            paste("Description:", column_categories[column_category_index, "desc"])
          )
        }
      }
    }
  }
  return(cat(reference_Rmd_lines, sep = "\n\n"))
}