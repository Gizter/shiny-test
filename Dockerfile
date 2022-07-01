# Base image https://hub.docker.com/u/rocker/
FROM rocker/shiny:latest

# expose port
EXPOSE 3838

# system libraries of general use
## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

# copy necessary files
## app folder
RUN mkdir -p /srv/shiny-server/soker
COPY docker.Rproj /srv/shiny-server/soker
COPY server.R /srv/shiny-server/soker
COPY ui.R /srv/shiny-server/soker
COPY renv.lock /srv/shiny-server/soker
COPY server.R /srv/shiny-server/soker
COPY renv  /srv/shiny-server/soker/renv

# install renv & restore packages
RUN Rscript -e 'install.packages("renv")'
RUN Rscript -e 'renv::consent(provided = TRUE)'
RUN Rscript -e 'renv::restore()'

RUN chown -R shiny /srv/shiny-server/
RUN chown -R shiny /var/lib/shiny-server/

# Run as a non-root user
USER 997

# run app on container start
CMD ["R", "-e", "shiny::runApp( '/srv/shiny-server/soker',host = '0.0.0.0', port = 3838)"]
