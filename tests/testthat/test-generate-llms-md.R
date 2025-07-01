#' Sets up and cleans up the tests for the llms.md file generation
#'
#' It sets up the following:
#' * Creating a test quarto project directory
#' * Writing the provided _quarto.yml configuration to the project directory
#' @param quarto_project_dir_name string that has the name of the test quarto
#' project directory
#' @param quarto_yml_content named list containing the _quarto.yml
#' configuration
#' @param env used for clean-up. Don't set this.
#' @return A named list with the following fields:
#' * quarto_project_dir_path: The path to the test quarto project directory
#' * quarto_render_cmd: A function that runs the quarto render command and
#' * returns its output
setup_test <- function(
  quarto_project_dir_name, quarto_yml_content, env = parent.frame()) {
  temp_dir <- tempdir()
  quarto_project_dir_path <- file.path(temp_dir, quarto_project_dir_name)
  dir.create(quarto_project_dir_path, recursive = TRUE)
  withr::defer(unlink(quarto_project_dir_path, recursive = TRUE), env)

  yaml::write_yaml(quarto_yml_content,
                   file.path(quarto_project_dir_path, "_quarto.yml"))

  render_function <- function() {
    return(system2(
      "quarto",
      args = c("render", quarto_project_dir_path),
      stderr = TRUE,
      stdout = TRUE
    ))
  }

  return(list(
    quarto_project_dir_path = quarto_project_dir_path,
    quarto_render_cmd = render_function
  ))
}

test_that("generate_llms_script correctly generates the llmd.md file", {
  output_dir_name <- "dist"

  # Create a test _quarto.yml file
  quarto_yml_content <- list(
    project = list(
      type = "website",
      `output-dir` = output_dir_name,
      `post-render` = file.path(getwd(), "../../docs/generate_llms_script.R")
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
  
  setup_info <- setup_test("test_quarto_project", quarto_yml_content)

  setup_info$quarto_render_cmd()

  output_dir <- file.path(setup_info$quarto_project_dir_path, output_dir_name)
  llms_md_file <- file.path(output_dir, "llms.md")
  expect_true(file.exists(llms_md_file))

  content <- readLines(llms_md_file)

  expect_snapshot(content)
})

test_that("generate_llms_script throws an error for nested sidebar contents", {
  output_dir_name <- "dist"

  nested_yml_content <- list(
    project = list(
      type = "website",
      `output-dir` = output_dir_name,
      `post-render` = file.path(getwd(), "../../docs/generate_llms_script.R")
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
  
  setup_info <- setup_test("test_nested_sidebar", nested_yml_content)

  output <- suppressWarnings(setup_info$quarto_render_cmd())

  expect_equal(attr(output, "status"), 1)
  expect_match(
    output, "Nested sidebar contents are not supported", all = FALSE)
})

test_that("generate_llms_script handles file write permission issues", {
  skip_on_cran()
  skip_on_ci()

  if (.Platform$OS.type == "unix") {
    skip("Skipping, not on unix system")
  }
  
  output_dir_name <- "dist"

  quarto_yml_content <- list(
    project = list(
      type = "website",
      `output-dir` = output_dir_name,
      `post-render` = file.path(getwd(), "../../docs/generate_llms_script.R")
    ),
    website = list(
      title = "Test Site",
      sidebar = list(
        contents = list(
          list(href = "index.qmd", text = "Home")
        )
      )
    )
  )
  
  setup_info <- setup_test("test_permissions", quarto_yml_content)

  output_dir_path <- file.path(
    setup_info$quarto_project_dir_path, output_dir_name
  )
  Sys.chmod(output_dir_path, mode = "0444")
  withr::defer(Sys.chmod(output_dir_path, mode = "0755"))

  output <- suppressWarnings(setup_info$quarto_render_cmd())

  expect_equal(attr(output, "status"), 1)
  expect_match(output, "Failed to write llms.md file", all = FALSE)
})
