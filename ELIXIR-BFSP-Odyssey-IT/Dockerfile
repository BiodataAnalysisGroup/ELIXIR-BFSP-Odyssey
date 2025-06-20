# ARG 

# FROM rocker/rocker-versioned2:latest
FROM bioconductor/bioconductor_docker:RELEASE_3_18

ENV SHINY_INPUT_DIR="/shiny_input"
ENV SHINY_OUTPUT_DIR="/shiny_output"

# get the get put functions
# Update the package lists and install Python and pip
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && apt-get clean

# Install Python dependencies using pip
RUN pip3 install galaxy-ie-helpers

# install Bioc
RUN Rscript -e "options(repos = c(CRAN = 'https://cran.r-project.org')); install.packages('BiocManager')" && \
    Rscript -e "BiocManager::install(ask=FALSE)" 

# since this is an app not in a package, we need to handle the dependencies separately
# maybe even use a script?
RUN Rscript -e "options(repos = c(CRAN = 'https://cran.r-project.org')); options(Ncpus = 2); install.packages('remotes'); remotes::install_github('paulzierep/ELIXIR-BFSP-Odyssey')"

#clone the repo
# RUN apt-get install -y git
# RUN git clone https://github.com/paulzierep/shiny-phyloseq.git && echo 'redo3' 

RUN apt-get install net-tools

USER root

RUN mkdir -p /shiny_input /shiny_output
RUN chown rstudio:rstudio /shiny_input /shiny_output

USER rstudio

ADD app_setup.R /app_setup.R

EXPOSE 3838

CMD Rscript /app_setup.R
