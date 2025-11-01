#' Creates a folder with model parameter files for testing purposes. The folder
#' is cleaned up after the test is done.
#'
#' @param model_parameter_files a named list containing all the model parameter
#' files to add to the folder. Each name in the list should be name of the file
#' including its extension and each value should be a data frame that contains
#' the file's contents. The named list must contain an entry for the model
#' export file which should be named `model-export.csv`.
#' @param env DO NOT SET THIS. Optional parameter that used for clean up
#' purposes
#' @return a string containing the path to the model export file
#' @examples
#' \dontrun {
#' model_export_file <- data.frame(
#'   fileType = c("model-steps"),
#'   filePath = c("./model-steps.csv")
#' )
#' model_steps_file <- data.frame(
#'   step = c("dummy"),
#'   fileType = c("N/A"),
#'   filePath = c("./dummy.csv"),
#'   notes = c("")
#' )
#' dummy_file <- data.frame(
#'   origVar = c("sex"),
#'   catValue = c("1"),
#'   dummyVariable = c("sex_cat1")
#' )
#'
#' model_export_file_path <- .create_model_parameters_test_dir(list(
#'   "model-export.csv" = model_export_file,
#'   "model-steps.csv" = model_steps_file,
#'   "dummy.csv" = dummy_file
#' ))
#' }
.create_model_parameters_test_dir <- function(
  model_parameter_files, env = parent.frame()) {
  MODEL_EXPORT_FILE_NAME <- "model-export.csv"

  stopifnot(MODEL_EXPORT_FILE_NAME %in% names(model_parameter_files))

  MODEL_PARAMETERS_FOLDER_NAME <- "model-parameters"
  model_parameters_folder_path <- file.path(
    tempdir(), MODEL_PARAMETERS_FOLDER_NAME)
  dir.create(model_parameters_folder_path)
  withr::defer(unlink(model_parameters_folder_path, recursive = TRUE), env)

  for(file_name in names(model_parameter_files)) {
    current_file <- model_parameter_files[[file_name]]
    write.csv(current_file, file.path(model_parameters_folder_path, file_name))
  }

  return(file.path(model_parameters_folder_path, MODEL_EXPORT_FILE_NAME))
}

test_that("files within the model steps file should be validated", {
  model_export_file <- data.frame(
    fileType = c("model-steps"),
    filePath = c("./model-steps.csv")
  )
  model_steps_file <- data.frame(
    step = c("dummy"),
    fileType = c("N/A"),
    filePath = c("./dummy.csv"),
    notes = c("")
  )
  dummy_file <- data.frame(
    origVar = c("sex"),
    catValue = c("1"),
    dummyVariable = c("sex_cat1")
  )

  model_export_file_path <- .create_model_parameters_test_dir(list(
    "model-export.csv" = model_export_file,
    "model-steps.csv" = model_steps_file,
    "dummy.csv" = dummy_file
  ))

  expected_result <- list(
    success = FALSE,
    errors = c(
      "Column <origVariable> not found in file dummy.csv"
    )
  )

  actual_result <- validate_model_parameters(model_export_file_path)

  expect_equal(actual_result, expected_result)
})

test_that("files within model steps whose type is in the fileType column should
          be validated", {
  model_export_file <- data.frame(
    fileType = c("model-steps"),
    filePath = c("./model-steps.csv")
  )
  model_steps_file <- data.frame(
    step = c("fine-and-gray"),
    fileType = c("beta-coefficients"),
    filePath = c("./beta-coefficients.csv"),
    notes = c("")
  )
  beta_coefficients <- data.frame(
    var = c("sex_cat1"),
    type = c("cat"),
    coefficient = c("2")
  )

  model_export_file_path <- .create_model_parameters_test_dir(list(
    "model-export.csv" = model_export_file,
    "model-steps.csv" = model_steps_file,
    "beta-coefficients.csv" = beta_coefficients
  ))

  expected_result <- list(
    success = FALSE,
    errors = c(
      "Column <variable> not found in file beta-coefficients.csv"
    )
  )

  actual_result <- validate_model_parameters(model_export_file_path)

  expect_equal(actual_result, expected_result)
})
