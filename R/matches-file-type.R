#' Tests the `fileName` column in the column metadata file for the existence of 
#' a file
#'
#' @param files_names the fileName column
#' @param file_type the file name to check for
#'
#' @return a logical vector
#'
#' @keywords internal
.matches_file_type <- function(file_names, file_type) {
  sapply(strsplit(file_names, ";"), function(names) file_type %in% names)
}
