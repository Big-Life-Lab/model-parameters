test_that("generate_llms creates llms.md file with correct content", {
  # Create temporary directory for test
  temp_dir <- tempdir()
  test_project_dir <- file.path(temp_dir, "test_quarto_project")
  dir.create(test_project_dir, recursive = TRUE)
  
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
                   file.path(test_project_dir, "_quarto.yml"))
  
  # Create test output directory
  output_dir <- file.path(test_project_dir, "dist")
  dir.create(output_dir, recursive = TRUE)
  
  # Set environment variable for output directory
  Sys.setenv(QUARTO_PROJECT_OUTPUT_DIR = output_dir)
  
  # Run the generate_llms function
  old_wd <- getwd()
  setwd(test_project_dir)
  
  tryCatch({
    model.parameters::generate_llms()
  }, finally = {
    setwd(old_wd)
  })
  
  # Check that llms.md was created
  llms_file <- file.path(output_dir, "llms.md")
  expect_true(file.exists(llms_file))
  
  # Read and check content
  content <- readLines(llms_file)
  
  # Check title
  expect_true(any(grepl("^# Test Documentation Site$", content)))
  
  # Check page links
  expect_true(any(grepl("\\[Home\\]\\(index\\.html\\)", content)))
  expect_true(any(grepl("\\[User Guide\\]\\(guide\\.html\\)", content)))
  expect_true(any(grepl("\\[Reference\\]\\(reference\\.html\\)", content)))
  
  # Clean up
  unlink(test_project_dir, recursive = TRUE)
  Sys.unsetenv("QUARTO_PROJECT_OUTPUT_DIR")
})

test_that("generate_llms throws error for missing _quarto.yml", {
  # Create temporary directory without _quarto.yml
  temp_dir <- tempdir()
  test_project_dir <- file.path(temp_dir, "test_no_yml")
  dir.create(test_project_dir, recursive = TRUE)
  
  old_wd <- getwd()
  setwd(test_project_dir)
  
  expect_error({
    tryCatch({
      model.parameters::generate_llms()
    }, finally = {
      setwd(old_wd)
    })
  }, "Could not find _quarto.yml file")
  
  # Clean up
  unlink(test_project_dir, recursive = TRUE)
})

test_that("generate_llms throws error for malformed _quarto.yml", {
  # Create temporary directory with malformed YAML
  temp_dir <- tempdir()
  test_project_dir <- file.path(temp_dir, "test_malformed_yml")
  dir.create(test_project_dir, recursive = TRUE)
  
  # Create malformed YAML file
  malformed_yml <- file.path(test_project_dir, "_quarto.yml")
  writeLines("website:\n  title: Test\n  sidebar:\n    - invalid: structure", 
             malformed_yml)
  
  old_wd <- getwd()
  setwd(test_project_dir)
  
  expect_error({
    tryCatch({
      model.parameters::generate_llms()
    }, finally = {
      setwd(old_wd)
    })
  }, "Invalid _quarto.yml structure")
  
  # Clean up
  unlink(test_project_dir, recursive = TRUE)
})

test_that("generate_llms throws error for nested sidebar contents", {
  # Create temporary directory with nested sidebar
  temp_dir <- tempdir()
  test_project_dir <- file.path(temp_dir, "test_nested_sidebar")
  dir.create(test_project_dir, recursive = TRUE)
  
  # Create YAML with nested sidebar structure
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
                   file.path(test_project_dir, "_quarto.yml"))
  
  old_wd <- getwd()
  setwd(test_project_dir)
  
  expect_error({
    tryCatch({
      model.parameters::generate_llms()
    }, finally = {
      setwd(old_wd)
    })
  }, "Nested sidebar contents are not supported")
  
  # Clean up
  unlink(test_project_dir, recursive = TRUE)
})

test_that("generate_llms handles file write permission issues", {
  skip_on_cran()
  skip_on_ci()
  
  # Create temporary directory
  temp_dir <- tempdir()
  test_project_dir <- file.path(temp_dir, "test_permissions")
  dir.create(test_project_dir, recursive = TRUE)
  
  # Create valid _quarto.yml
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
                   file.path(test_project_dir, "_quarto.yml"))
  
  # Create output directory with restricted permissions
  output_dir <- file.path(test_project_dir, "dist")
  dir.create(output_dir, recursive = TRUE)
  
  # Set environment variable
  Sys.setenv(QUARTO_PROJECT_OUTPUT_DIR = output_dir)
  
  # Remove write permissions (only on Unix-like systems)
  if (.Platform$OS.type == "unix") {
    Sys.chmod(output_dir, mode = "0444")
    
    old_wd <- getwd()
    setwd(test_project_dir)
    
    expect_error({
      tryCatch({
        model.parameters::generate_llms()
      }, finally = {
        setwd(old_wd)
        # Restore permissions for cleanup
        Sys.chmod(output_dir, mode = "0755")
      })
    }, "Failed to write llms.md file")
  }
  
  # Clean up
  unlink(test_project_dir, recursive = TRUE)
  Sys.unsetenv("QUARTO_PROJECT_OUTPUT_DIR")
})
