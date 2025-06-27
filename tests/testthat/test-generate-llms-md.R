#' Sets up and cleans up the tests for the llms.md file generation
#'
#' It sets up the following:
#' * Creating a test quarto project directory
#' * Updating the working directory to the test quarto project directory.
#' * Setting the QUARTO_PROJECT_OUTPUT_DIR env variable
#' @param quarto_project_dir_name string that has the name of the test quarto
#' project directory
#' @param env used for clean-up. Don't set this.
#' @return A named list with the following fields:
#' * quarto_project_dir: The path to the test quarto project directory
#' * output_dir: The path to the directory where the rendered document
#'               will be
setup_test <- function(quarto_project_dir_name, env = parent.frame()) {
  temp_dir <- tempdir()
  quarto_project_dir_path <- file.path(temp_dir, quarto_project_dir_name)
  dir.create(quarto_project_dir_path, recursive = TRUE)
  withr::defer(unlink(quarto_project_dir_path, recursive = TRUE), env)

  return(list(
    quarto_project_dir_path = quarto_project_dir_path,
    quarto_render_cmd = paste0("quarto render ", quarto_project_dir_path)
  ))
}

test_that("generate_llms_md creates llms.md file with correct content", {
  setup_info <- setup_test("test_quarto_project")
  
  output_dir_name <- "dist"

  # Create a test _quarto.yml file
  quarto_yml_content <- list(
    project = list(
      type = "website",
      `output-dir` = output_dir_name,
      `post-render` = file.path(getwd(), "../../generate_llms_script.R")
    ),
    website = list(
      title = "Test Documentation Site",
      sidebar = list(
        contents = list(
          list(href = "index.qmd", text = "Home"),
          list(href = "guide.qmd", text = "User Guide"),
          list(href = "reference.qmd", text = "Reference")
        )
      )
    )
  )
  yaml::write_yaml(quarto_yml_content, 
                   file.path(setup_info$quarto_project_dir_path, "_quarto.yml"))
  
  system(setup_info$quarto_render_cmd)

  output_dir <- file.path(setup_info$quarto_project_dir_path, output_dir_name)
  llms_md_file <- file.path(output_dir, "llms.md")
  expect_true(file.exists(llms_md_file))

  content <- readLines(llms_md_file)

  expect_snapshot(content)
})

test_that("generate_llms_md throws error for nested sidebar contents", {
  setup_info <- setup_test("test_nested_sidebar")

  output_dir_name <- "dist"

  # Create a test _quarto.yml file
  nested_yml_content <- list(
    project = list(
      type = "website",
      `output-dir` = output_dir_name,
      `post-render` = file.path(getwd(), "../../generate_llms_script.R")
    ),
    website = list(
      title = "Test Site",
      sidebar = list(
        contents = list(
          list(
            section = "Getting Started",
            contents = list(
              list(href = "index.qmd", text = "Home"),
              list(href = "guide.qmd", text = "Guide")
            )
          )
        )
      )
    )
  )
  
  yaml::write_yaml(nested_yml_content, 
                   file.path(setup_info$quarto_project_dir_path, "_quarto.yml"))

  output <- suppressWarnings(system2(
    "quarto", args = c("render", setup_info$quarto_project_dir_path),
    stderr = TRUE, stdout = TRUE
  ))

  expect_equal(attr(output, "status"), 1)
  expect_match(output, "Nested sidebar contents are not supported", all = FALSE)
})

test_that("generate_llms_md handles file write permission issues", {
  skip_on_cran()
  skip_on_ci()

  if (.Platform$OS.type == "unix") {
    skip("Skipping, not on unix system")
  }

  setup_info <- setup_test("test_permissions")
  
  quarto_yml_content <- list(
    website = list(
      title = "Test Site",
      sidebar = list(
        contents = list(
          list(href = "index.qmd", text = "Home")
        )
      )
    )
  )
  
  yaml::write_yaml(quarto_yml_content, 
                   file.path(setup_info$quarto_project_dir, "_quarto.yml"))
  
  Sys.chmod(setup_info$output_dir, mode = "0444")
  withr::defer(Sys.chmod(setup_info$output_dir, mode = "0755"))

  expect_error({
      model.parameters::generate_llms_md()
  }, "Failed to write llms.md file")
})
