FROM rocker/shiny-verse
RUN mkdir /shiny-app
COPY ./app /shiny-app/
RUN Rscript /shiny-app/install-packages.R 
EXPOSE 3838
RUN apt-get update &&  apt-get install -y libglpk-dev 
CMD Rscript -e 'shiny::runApp("/shiny-app/", port = 3838, host = "0.0.0.0")'
