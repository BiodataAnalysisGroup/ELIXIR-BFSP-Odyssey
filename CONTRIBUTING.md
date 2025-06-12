# Contributing to `Odyssey`

Hi there! Many thanks for taking an interest in improving `Odyssey`. This document outlines how to propose any changes to `Odyssey`.

## Contribution workflow

### GitHub issues

#### What kind of issues can somebody open?

- If you encounter a bug in the app, please open an issue using the Bug Report template.
- For new feature suggestions (i.e., suggestions for improving the app, ??), use the Feature Request template.
- For all other matters, feel free to open an issue using the Blank template.

Once the issue is created, you can assign a reviewer yourself or leave it unassigned — a team member will review it and take it from there.

### Code contribution

If you'd like to write some code for `Odyssey`, the standard workflow is as follows:

1. Check that there isn't already an issue about your idea in the `Odyssey` issues to avoid duplicating work. If there isn't one already, please create one so that others know you're working on this.
2. Fork the `Odyssey` main repository to your GitHub account
3. Make the necessary changes / additions within your forked repository.
4. Submit a Pull Request against the dev branch and wait for the code to be reviewed and merged.

If you're not used to this workflow with git, you can start with some docs from GitHub or even their excellent git resources.

## Resources

Below you can find relevant resources.

*SPLIT ITEMS PER GROUP*

- [R Packages (2e)](https://r-pkgs.org/)
- [Mastering Shiny](https://mastering-shiny.org/)
- [Modularizing Shiny app code](https://shiny.posit.co/r/articles/improve/modules/)

## Fixing typos

You can fix typos, spelling mistakes, or grammatical errors in the documentation directly using the GitHub web interface, as long as the changes are made in the _source_ file. This generally means you'll need to edit [roxygen2 comments](https://roxygen2.r-lib.org/articles/roxygen2.html) in an `.R`, not a `.Rd` file. You can find the `.R` file that generates the `.Rd` by reading the comment in the first line.

## Bigger changes

- If you want to make a bigger change [such as...], it's a good idea to first file an issue and make sure someone from the team agrees that it’s needed. 
- If you’ve found a bug, please file an issue that illustrates the bug with a minimal [reprex](https://www.tidyverse.org/help/#reprex) (this will also help you write a unit test, if needed).

### Pull request process

- Fork the package and clone onto your computer. If you haven't done this before, we recommend using `usethis::create_from_github("BiodataAnalysisGroup/ELIXIR-BFSP-Odyssey", fork = TRUE)`.
- Install all development dependences with `devtools::install_dev_deps()`, and then make sure the package passes R CMD check by running `devtools::check()`. If R CMD check doesn't pass cleanly, it's a good idea to ask for help before continuing. 
- Create a Git branch for your pull request (PR). We recommend using `usethis::pr_init("brief-description-of-change")`.
- Make your changes and run `run_odyssey()` in order to see them.
- Once your ready, commit to git, and then create a PR by running `usethis::pr_push()`, and following the prompts in your browser. The title of your PR should briefly describe the change. The body of your PR should contain `Fixes #issue-number`.
- For user-facing changes, add a bullet to the top of `NEWS.md` (i.e. just below the first header). Follow the style described in <https://style.tidyverse.org/news.html>.

### Code style

- New code should follow the tidyverse [style guide](https://style.tidyverse.org). You can use the [styler](https://CRAN.R-project.org/package=styler) package to apply these styles, but please don't restyle code that has nothing to do with your PR.  
- We use [roxygen2](https://cran.r-project.org/package=roxygen2), with [Markdown syntax](https://roxygen2.r-lib.org/articles/rd-formatting.html), for documentation.  
- We use [testthat](https://cran.r-project.org/package=testthat) for unit tests. Contributions with test cases included are easier to accept.  

## Code of Conduct

Please note that the tidyverse project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this
project you agree to abide by its terms.
