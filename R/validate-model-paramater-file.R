#' Validates a set of model parameters file
#'
#' @param model_parameters_file_path Path to the model parametera file
#'
#' @return A named list containing the following fields:
#' * success: boolean indicating whether validation failed or succeeded.
#' * errors: A character vector where each item is a validation error message.
#'   this field is only present if validation failed.
#' @export
#'
#' @examples
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
                                    fileEncoding = "UTF-8-BOM")

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
    file_validation <- validate_file(
      model_parameter_file,
      model_parameter_file_row$fileType,
      basename(model_parameter_file_path),
      file_metadata,
      column_metadata,
      column_category_metadata
    )
    file_errors <- c(
      file_errors,
      file_validation 
    )

    MODEL_STEPS_FILE_TYPE <- "model-steps"
    if(model_parameter_file_row$fileType == MODEL_STEPS_FILE_TYPE &
       length(file_validation) == 0) {
      model_step_file_errors <- purrr::pmap(
        model_parameter_file,
        function(step, filePath, fileType, ...) {
          model_step_file_path <- file.path(dirname(model_parameter_file_path), filePath)
          model_step_file <- read.csv(model_step_file_path, fileEncoding = "UTF-8-BOM")
          # Step types whose fileType value cannot be N/A
          NON_NA_FILE_TYPE_STEPS <- c("fine-and-gray", "cox")
          model_step_file_type <- if(step %in% NON_NA_FILE_TYPE_STEPS) {
            fileType
          } else {
            step 
          } 
          validation <- validate_file(
            model_step_file,
            model_step_file_type,
            basename(model_step_file_path),
            file_metadata,
            column_metadata,
            column_category_metadata
          )
          return(validation)
        }
      ) %>% purrr::list_c()
      file_errors <- c(file_errors, model_step_file_errors)
    }
  }
  if (length(file_errors) == 0) {
    return(list(success = TRUE))
  }
  return(list(success = FALSE, errors = file_errors))
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

  file_column_metadata <- column_metadata[.matches_file_type(column_metadata$fileName, file_type),]
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
