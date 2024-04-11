# Dockerfile
# Manuscript
# About: This image includes r-ver:4.3.3, RStudio, Pandoc, and Quarto.
# It also adds the necessary R packages for the manuscript and
# their system dependencies (ubuntu). Some sensible RStudio preferences
# are also included and the image is set to run on port 8787, with the
# preview port set to 4321.

# Use rocker/r-ver as the base image
FROM rocker/r-ver:4.3.3

# Update linux libraries
RUN apt-get update && apt-get install -y build-essential
RUN apt-get install -y \
    cmake \
    git \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libglpk-dev \
    libicu-dev \
    libpng-dev \
    libssl-dev \
    libxml2-dev \
    make \
    pandoc \
    python3 \
    zlib1g-dev

# Clean up the apt-get installations.
RUN rm -rf /var/lib/apt/lists/*

# Set up environmental variables
ENV S6_VERSION=v2.1.0.2
ENV RSTUDIO_VERSION=2023.12.1+402
ENV DEFAULT_USER=rstudio
ENV PANDOC_VERSION=3.1.13
ENV QUARTO_VERSION=1.4.553

# Install RStudio, Pandoc, and Quarto
RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_quarto.sh

# Set up user
USER ${DEFAULT_USER}

# Install TinyTex
RUN quarto install tinytex --update-path

# Install pak and renv
RUN R -e "install.packages(c('pak', 'renv'), repos = 'https://cloud.r-project.org')"

# Copy RStudio preferences
COPY --chown=${DEFAULT_USER}:${DEFAULT_USER} rstudio-prefs.json /home/${DEFAULT_USER}/.config/rstudio/rstudio-prefs.json

# Change back to root user
USER root

# Default port for RStudio
EXPOSE 8787

# Port for preview
EXPOSE 4321

# Start RStudio
CMD ["/init"]
