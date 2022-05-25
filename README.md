README
================
Hai Vo

This is an repository of my “Schedule assign” shiny web app. This app
allow user to assign schedule to the group of people working on a shift
basis. This app using `{ompr}` as an interface to write mathematics MIP
model and `{glpk}` as a solver. You can read Vietnamese manual [here](https://github.com/vohai611/shiny-schedule-assign/blob/master/app/Introduction.md)

Please visit the app
[here](https://haivo.shinyapps.io/schedule-optimizer/)

# Docker

You could also build this app images by running the following command

``` bash
git clone https://github.com/vohai611/shiny-schedule-assign.git
cd shiny-schedule-assign
docker build -t shiny-app ./
```
