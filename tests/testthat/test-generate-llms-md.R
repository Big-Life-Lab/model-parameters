#' Sets up and cleans up the tests for the llms.md file generation
#'
#' It sets up the following:
#' * Creating a test quarto project directory
#' * Updating the working directory to the test quarto project directory.
#' * Setting the QUARTO_PROJECT_OUTPUT_DIR env variable
#' @param quarto_project_dir string that has the name of the test quarto
#' project directory
#' @param env used for clean-up. Don't set this.
#' @return A named list with the following fields:
#' * quarto_project_dir: The path to the test quarto project directory
#' * output_dir: The path to the directory where the rendered document
#'               will be
setup_test <- function(quarto_project_dir, env = parent.frame()) {
  temp_dir <- tempdir()
  test_project_dir <- file.path(temp_dir, quarto_project_dir)
  dir.create(test_project_dir, recursive = TRUE)
  withr::defer(unlink(test_project_dir, recursive = TRUE), env)

  old_wd <- getwd()
  setwd(test_project_dir)
  withr::defer(setwd(old_wd), env)

  output_dir <- file.path(test_project_dir, "dist")
  dir.create(output_dir, recursive = TRUE)
  Sys.setenv(QUARTO_PROJECT_OUTPUT_DIR = output_dir)
  withr::defer(Sys.unsetenv("QUARTO_PROJECT_OUTPUT_DIR"), env)

  return(list(quarto_project_dir = test_project_dir, output_dir = output_dir))

}

test_that("generate_llms_md creates llms.md file with correct content", {
  setup_info <- setup_test("test_quarto_project")

  # Create a test _quarto.yml file
  quarto_yml_content <- list(
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
                   file.path(setup_info$quarto_project_dir, "_quarto.yml"))
  
  model.parameters::generate_llms_md()
  
  llms_file <- file.path(setup_info$output_dir, "llms.md")
  expect_true(file.exists(llms_file))
  
  content <- capture.output(cat(readChar(llms_file, file.info(llms_file)$size)))

  expect_snapshot(content)
})

test_that("generate_llms_md throws error for missing _quarto.yml", {
  setup_test("test_no_yml")

  expect_error({
    model.parameters::generate_llms_md()
  }, "Could not find _quarto.yml file")
})

test_that("generate_llms_md throws error for malformed _quarto.yml", {
  setup_info <- setup_test("test_malformed_yml")
  
  malformed_yml <- file.path(setup_info$quarto_project_dir, "_quarto.yml")
  writeLines("website:\n  title: Test\n  sidebar:\n    - invalid: structure", 
             malformed_yml)
  
  expect_error({
    model.parameters::generate_llms_md()
  }, "Invalid _quarto.yml structure")
})

test_that("generate_llms_md throws error for nested sidebar contents", {
  setup_info <- setup_test("test_nested_sidebar")
  
  nested_yml_content <- list(
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
                   file.path(setup_info$quarto_project_dir, "_quarto.yml"))
  
  expect_error({
    model.parameters::generate_llms_md()
  }, "Nested sidebar contents are not supported")
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
