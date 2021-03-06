###########################
# Beta plotting functions #
###########################

require(plotly)

#' Plot the temperature on a time-series graph
#'
#' @param station to plot
#' @param years to plot (can be filled in by begin or end)
#' @param begin year (opt)
#' @param end year (opt)
#' @param mode MD or Date
#' @export
plot.Climate <- function(station, years=NA, begin=NA, end=NA, mode=c("MD", "Date"), FUN=NA) {
  if (!(is.na(begin) & is.na(end))) {
    years <- begin:end
  }
  if (anyNA(years)) {
    stop("You must provide years to plot!")
  }
  p <- NA
  prev <- NA
  # TODO can we not plot NAs?
  for (year in years) {
    temp <- read.ClimateCSV(station, year)
    if (!is.na(FUN)) {
      FUN <- match.fun(FUN)
      if (!is.na(prev)) temp$TempC <- FUN(temp, prev)
      else temp$TempC <- FUN(temp)
    }
    if (anyNA(p)) {
      if (mode=="MD") p <- plot_ly(data=temp, x=~MD, y=~TempC, type="scatter", mode="lines", name=year, opacity=1/sqrt(length(years)))
      if (mode=="Date") p <- plot_ly(data=temp, x=~Date, y=~TempC, type="scatter", mode="lines", name=year)
    } else {
      if (mode=="MD") p <- add_trace(p, data=temp, x=~MD, y=~TempC, mode="lines", name=year, opacity=1/length(years))
      if (mode=="Date") p <- add_trace(p, data=temp, x=~Date, y=~TempC, mode="lines", name=year)
    }
    prev <- temp
  }
  if (max(years)-min(years)==length(years)-1)
    yearNames <- paste(min(years), max(years), sep="-")
  else
    yearNames <- gsub("(20|19){1}([[:digit:]]{2},?)", "'\\2", paste0(years, collapse=", "))
  testTitle <- paste(
    "Plot of station ", station, " (", 
    as.character(read.ClimateHeader(station)$Station.Name), 
    ") years ", yearNames, sep="")
  p <- layout(p, title=testTitle)
  p
}



#' Plot the temperature on an animation
#'
# @param station
# @param years
# @param begin
# @param end
# @param mode
#' @export
plot.ClimateAnimation <- function(station, years, begin=NA, end=NA, accumulate=24, framemult=100) {
  if (!(is.na(begin) & is.na(end))) {
    years <- begin:end
  }
  if (anyNA(years)) {
    stop("You must provide years to plot!")
  }
  p <- NA
  # TODO can we not plot NAs?
  for (year in years) {
    temp <- read.ClimateCSV(station, year) %>%
      plot.AccumulateBy(~Date, accumulate)
    if (anyNA(p)) {
      p <- temp %>%
        plot_ly(
          x = ~Date, 
          y = ~TempC,
          frame = ~Frame, 
          type = 'scatter',
          mode = 'lines', 
          line = list(simplyfy = F)
        ) %>% 
        layout(
          xaxis = list(
            title = "Date"
          ),
          yaxis = list(
            title = "Temp (°C)"
          )
        ) %>% 
        animation_opts(
          frame = framemult, 
          transition = 0, 
          redraw = TRUE
        ) %>%
        animation_slider(
          hide = T
        ) %>%
        animation_button(
          x = 1, xanchor = "right", y = 0, yanchor = "bottom"
        )
    } else {
      # if (mode=="MD") p <- add_trace(p, data=temp, x=~MD, y=~TempC, mode="lines", name=year, opacity=1/length(years))
    }
  }
  if (max(years)-min(years)==length(years)-1)
    yearNames <- paste(min(years), max(years), sep="-")
  else
    yearNames <- gsub("(20|19){1}([[:digit:]]{2},?)", "'\\2", paste0(years, collapse=", "))
  testTitle <- paste(
    "Plot of station ", station, " (", 
    as.character(read.ClimateHeader(station)$Station.Name), 
    ") years ", yearNames, sep="")
  p <- layout(p, title=testTitle)
  p
}

#' Plot the temperature on a map
#'
# @param station
# @param years
# @param begin
# @param end
# @param mode
#' @export
plot.ClimateMap <- function() {
  
}

#' Plot the temperature on an animated map
#'
# @param station
# @param years
# @param begin
# @param end
# @param mode
#' @export
plot.ClimateMapAnimation <- function() {
  
}