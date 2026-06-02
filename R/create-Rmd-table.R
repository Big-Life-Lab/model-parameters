create_Rmd_table <- function(file_type, file_metadata, column_metadata, column_category_metadata) {
  column_metadata_rows <- column_metadata[.matches_file_type(column_metadata$fileName, file_type), ]
  if(nrow(column_metadata_rows) == 0) {
    stop(glue::glue("No column metadata rows found for file {file_type}"))
  }
  
  rmd_table <- data.frame(
    column_name = c(),
    column_label = c(),
    column_type = c(),
    column_category_value = c(),
    column_category_label = c()
  )
  for(column_metadata_row_index in 1:nrow(column_metadata_rows)) {
    column_metadata_row <- column_metadata_rows[column_metadata_row_index, ]
    
    if(column_metadata_row$columnType == "category") {
      column_categories_metadata_rows <- column_category_metadata[column_category_metadata$fileName == file_type & column_category_metadata$columnName == column_metadata_row$columnName, ]
      if(nrow(column_categories_metadata_rows) == 0) {
        stop(glue::glue("No column categories metadata rows found for file {file_type} for column {column_metadata_row$columnName}"))
      }
      for(column_categories_metadata_rows_index in 1:nrow(column_categories_metadata_rows)) {
        column_categories_metadata_row <- column_categories_metadata_rows[column_categories_metadata_rows_index, ]
        if(column_categories_metadata_rows_index == 1) {
          rmd_table <- rbind(
            rmd_table,
            data.frame(
              column_name = c(column_metadata_row$columnName),
              column_label = c(column_metadata_row$columnLabel),
              column_type = c(column_metadata_row$columnType),
              column_category_value = c(column_categories_metadata_row$columnValue),
              column_category_label = c(column_categories_metadata_row$desc)
            )
          )
        }
        else {
          rmd_table <- rbind(
            rmd_table,
            data.frame(
              column_name = c(""),
              column_label = c(""),
              column_type = c(""),
              column_category_value = c(column_categories_metadata_row$columnValue),
              column_category_label = c(column_categories_metadata_row$desc)
            )
          )
        }
      }
    }
    else {
      rmd_table <- rbind(
        rmd_table,
        data.frame(
          column_name = c(column_metadata_row$columnName),
          column_label = c(column_metadata_row$columnLabel),
          column_type = c(column_metadata_row$columnType),
          column_category_value = c(""),
          column_category_label = c("")
        )
      )
    }
  }

  return(
    DT::datatable(
      rmd_table,
      options = list(
        columnDefs = list(list(className = "dt-left", targets = "_all"))
      ),
      colnames = c("Name", "Label", "Type", "Category Name", "Category Label")
    )
  )
}