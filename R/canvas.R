#canvas

# check extent and proj validity... Need to add check for projected CRS.
# check extent and projection are valid. from {gdlaio}
# https://github.com/hypertidy/gdalio/blob/main/R/default_grid.R
is_canvas_valid <- function(x){
  has_extent <- is.numeric(x[["extent"]]) && length(x[["extent"]] == 4) && all(!is.na(x[["extent"]])) &&
    diff(x[["extent"]][1:2]) > 0 && diff(x[["extent"]][3:4]) > 0
  if (!has_extent) stop("invalid extent")

  has_proj <- is.character(x[["projection"]]) && length(x[["projection"]] == 1) && !is.na(x[["projection"]])
  if (!has_proj) stop("invalid projection")
  return(x)
}

# check if crs is cartesian
is.cartesian <- function(x){
  if (!sf::st_is_longlat(x)) {
    return(TRUE)
  } else {
    warning(paste0("Canvas CRS is not cartesian. This probably doesn't matter",
                   "Be careful of the units you use to specify `res`"))
    return(FALSE)
  }

}

# check valiity and set default canvas
set_project_canvas <- function(x){
  x <- is_canvas_valid(x)
  options(raytrix.canvas=x)
}

#' set a global canvas
#'
#' ...info
#'
#' @export
set_canvas_globe <- function() {
    set_project_canvas(list(extent = c(-180, 180,
                                       -90, 90),
                            projection = "+proj=longlat +datum=WGS84"))

}

#' set/get the canvas of the rayshader-ratrix project
#'
#' To enable the downloading of rayshader-readable data for a desired extent,
#' it is necessary to set the rayshader-ratrix scene canvas using one of the
#' `set_canvas_x()` functions.
#'
#' To retrieve this information use `get_canvas()`
#'
#' @name raytrix_set_canvas
#' @param bounds vector of length 4. e.g. `c(xmin, xmax, ymin, ymax)`
#' @param crs The Coordinate reference system of the canvas. Eiher a numeric
#' EPSG code or a proj string such as "+proj=longlat +datum=WGS84".
#'
#' @export
set_canvas <- function(.bounds, crs){

  is.cartesian(crs)

  # if (is.numeric(crs)) {       # if EPSG numeric is given convert to wkt
  #   crs <- sf::st_crs(crs)$wkt
  # }

  canvas0 <- list(extent = c(.bounds[1], .bounds[2], .bounds[3], .bounds[4]),
                  projection = crs)

  set_project_canvas(canvas0)

}


#' @name raytrix_set_canvas
#' @param .sf The sf/sfc object used to set the extent and crs of the canvas
#' @param mask Default is F. NOT WORKING YET!
#'
#' @export
set_canvas_sf <- function(.sf, mask=F){
  is.cartesian(.sf)
  # if (!is.cartesian(.sf)) {
  #   .sf <- sf::st_transform(.sf, crs=3857)
  # }

  bounds <- .sf %>%
    sf::st_bbox()
  canvas0 <- list(extent = c(bounds$xmin, bounds$xmax, bounds$ymin, bounds$ymax),
                projection = sf::st_crs(.sf)$wkt)

  set_project_canvas(canvas0)
}

#' @name raytrix_set_canvas
#' @param lat ...
#' @param long ...
#' @param radius ...
#' @param crs ...
#'
#' @export
set_canvas_centroid <- function(lat, long, radius=5000,
                                crs="+proj=longlat +datum=WGS84"){

  extent_sfc <- sf::st_sfc(sf::st_point(c(long, lat)))%>%
    sf::st_set_crs(crs)

  if (!suppressWarnings(is.cartesian(sf::st_crs(crs)))) {
    extent_sfc <- extent_sfc %>%
      sf::st_transform(crs=3857)
    warning(paste0('`set_canvas_centroid() `converts coordinates to web mercator for convnience.',
            'to set a specific canvas extent and crs use `set_canvas()`'))
  }

  extent_sfc <- extent_sfc %>%
    sf::st_buffer(radius)%>%
    sf::st_bbox()%>%
    sf::st_as_sfc()



  set_canvas_sf(extent_sfc)
}


#' @name raytrix_set_canvas
#' @export
get_canvas <- function(res){

  if (is.null(getOption("raytrix.canvas"))){
    stop("Raytrix canvas has not been set. Please set this using one of the
         following functions: set_canvas(), set_canvas_raster(),
         set_canvas_sf(), set_canvas_centroid()")
  }

  if (missing(res)){
    return(getOption("raytrix.canvas"))
    } else {

      g <- getOption("raytrix.canvas")

      g$dimension = c(x = ceiling((as.numeric(g$extent[2]-g$extent[1]))/res),
                      y = ceiling((as.numeric(g$extent[4]-g$extent[3]))/res))

      return(g)

      }

}



#' @export
canvasExent <- function(){

  canvas <- get_canvas()

  setClass('Extent', representation(xmin='numeric', xmax='numeric', ymin='numeric', ymax='numeric'))
  new('Extent', xmin=canvas$extent[1], xmax=canvas$extent[2],
               ymin=canvas$extent[3], ymax=canvas$extent[4])
}


