validate_model_parameters <- function(model_parameters_file_path) {
  # Read all the metadata files
  file_metadata <- read.csv(
    system.file("metadata/file-metadata.csv", package = "model.parameters"),
    fileEncoding = "UTF-8-BOM"
  )
  column_metadata <-
    read.csv(
      system.file("metadata/column-metadata.csv", package = "model.parameters"),
      fileEncoding = "UTF-8-BOM"
    )
  column_category_metadata <-
    read.csv(
      system.file("metadata/column-category.csv", package = "model.parameters"),
      fileEncoding = "UTF-8-BOM"
    )
  
  if (!file.exists(model_parameters_file_path)) {
    stop(
      glue::glue(
        "No model parameters file found at path {model_parameters_file_path}. The working directory is {getwd()}"
      )
    )
  }
  
  model_parameters_file <- read.csv(model_parameters_file_path,
                                    encoding = "UTF-8-BOM")
  model_parameters_file_errors <- validate_file(
    model_parameters_file,
    "model-export",
    basename(model_parameters_file_path),
    file_metadata,
    column_metadata,
    column_category_metadata
  )
  if (length(model_parameters_file_errors) > 0) {
    stop(cat(model_parameters_file_errors, sep = "\n"))
  }
  
  # The list of errors in all the model parameter files
  file_errors <- c()
  for (model_parameters_file_index in 1:nrow(model_parameters_file)) {
    model_parameter_file_row <-
      model_parameters_file[model_parameters_file_index,]
    model_parameter_file_path <-
      file.path(dirname(model_parameters_file_path),
                model_parameter_file_row$filePath)
    
    if (!file.exists(model_parameter_file_path)) {
      stop(
        glue::glue(
          "No model parameter file found at path {model_parameter_file_path}. The working directory is {getwd()}"
        )
      )
    }
    
    model_parameter_file <- read.csv(model_parameter_file_path,
                                     fileEncoding = "UTF-8-BOM")
    file_errors <- c(
      file_errors,
      validate_file(
        model_parameter_file,
        model_parameter_file_row$fileType,
        basename(model_parameter_file_path),
        file_metadata,
        column_metadata,
        column_category_metadata
      )
    )
  }
  if (length(file_errors) == 0) {
    return(TRUE)
  }
  return(file_errors)
}

validate_file <- function(file,
                          file_type,
                          file_name,
                          file_metadata,
                          column_metadata,
                          column_category_metadata) {
  current_file_metadata <- file_metadata[file_metadata$fileName == file_type,]
  
  if (nrow(current_file_metadata) == 0) {
    stop(glue::glue("No rows found in file metadata for file type {file_type}"))
  }
  
  file_column_metadata <- column_metadata[column_metadata$fileName == file_type,]
  if (nrow(file_column_metadata) == 0) {
    stop(glue::glue("No rows found in columns metadata for file type {file_type}"))
  }
  
  errors <- c()
  file_columns <- colnames(file)
  for (column_metadata_row_index in 1:nrow(file_column_metadata)) {
    column_metadata_row <-
      file_column_metadata[column_metadata_row_index,]
    
    if (!column_metadata_row$columnName %in% file_columns) {
      if (column_metadata_row$optional == "FALSE") {
        errors <- c(
          errors,
          glue::glue(
            "Column <{column_metadata_row$columnName}> not found in file {file_name}"
          )
        )
      }
      next
    }
    
    current_column_values <- file[[column_metadata_row$columnName]]
    for (column_values_index in 1:length(current_column_values)) {
      column_value <- current_column_values[column_values_index]
      switch(column_metadata_row$columnType,
             "number" = {
               if (column_value == "N/A") {
                 next
               }
               suppressWarnings({
                 numeric_column_value <- as.numeric(column_value)
               })
               if (is.na(numeric_column_value)) {
                 errors <- c(
                   errors,
                   glue::glue(
                     "Error in row {column_values_inde} in column {column_metadata_row$columnName} in file {file_name}. Expected number or N/A but got {column_value}"
                   )
                 )
               }
             },
             "category" = {
               column_categories_metadata <- column_category_metadata[column_category_metadata$fileName == file_type &
                                                                        column_category_metadata$columnName == column_metadata_row$columnName,]
               if (nrow(column_category_metadata) == 0) {
                 stop(
                   glue::glue(
                     "No categories metadata found for file {file_type} for column {column_category_metadata$columnName}"
                   )
                 )
               }
               
               column_values <- column_categories_metadata$columnValue
               if (!column_value %in% column_values) {
                 errors <- c(
                   errors,
                   glue::glue(
                     "Error in row {column_values_index} in column {column_metadata_row$columnName} in file {file_name}. Expected one of {paste(column_values, collapse=',')} but got {column_value}"
                   )
                 )
               }
             })
    }
  }
  return(errors)
}