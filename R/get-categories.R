#' Get the category values for a category set(s)
#'
#' @param category_set A `categorySet` value from `column-metadata.csv`, for
#' example `"variable-type"` or `"variable-type;type-start-na"`
#' @param category_set_metadata The data frame read from `category-set.csv`
#'
#' @return A data frame with the columns `columnValue` and `desc`
get_categories <- function(category_set, category_set_metadata) {
  set_names <- strsplit(category_set, ";")[[1]]
  categories <- category_set_metadata[
    category_set_metadata$categorySet %in% set_names,
    c("columnValue", "desc")
  ]
  if (nrow(categories) == 0) {
    stop(glue::glue("No categories found for category set {category_set}"))
  }
  rownames(categories) <- NULL
  categories
}
