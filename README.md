# model-parameters-template
This repo provides a template for all current model parameter documents. The goal is to describe the model and outline all the steps to go from the starting variables in the model to calculating the outcome of the model. These files provide a transparent, detailed description of the model for publication and/or implementation. See https://big-life-lab.github.io/model-parameters/ for more details.

# Building the Documentation

The documentation is served by Github pages and its files are stored in the gh-pages branch.

Switch to the gh-pages branch and merge main into it. Then run the following command,

```{r}
bookdown::render_book(input = "./Rmd")
```

Commit and push to update docs.
