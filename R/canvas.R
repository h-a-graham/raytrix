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
    warning(paste0("Canvas projection is not cartesian. This probably doesn't matter",
                   "Be careful of the units you use to specify `res`"))
    return(FALSE)
  }

}

# check valiity and set default canvas
set_project_canvas <- function(x){
  x <- is_canvas_valid(x)
  options(raytrix.canvas=x)
}



#' set/get the canvas of the rayshader-ratrix project
#'
#' To enable the downloading of rayshader-readable data for a desired extent,
#' it is necessary to set the rayshader-ratrix scene canvas using one of the
#' `set_canvas_x()` functions. See details for additional info.
#'
#' `set_canvas()` offers the most control over the extent and projection of the
#' raytrix canvas. Use `set_canvas_world()` for a basic WGS84 extent of the
#' world; this is deliberately simple, for alternative global projections use
#' `set_canvas()`. `set_canvas_sf()` sets the canvas from an sf or sfc object;
#' this can be especially useful when you intend to plot sf features as
#' overlays. `set_canvas_centroid()` allows for the provision of lat long
#' coordinates and a buffer (in meters) around that point to set the extent;
#' this function takes WGS84 coords by default (although this can be changed)
#' but will always convert to Pseudo Mercator for convenience. To retrieve this
#' information use `get_canvas()` which returns a list including: `extent`,
#' `projection` and (if `res` is provided) `dimension`. `canvasExent()` returns
#' a raytrix extent object which is a copy of a {raster} Extent object. This can
#' be used in combination with {rayshader} functions such as
#' `generate_polygon_overlay()` to provide the extent of the topography matrix.
#'
#' @name raytrix_set_canvas
#' @param bounds numeric vector of length 4. e.g. `c(xmin, xmax, ymin, ymax)`
#' @param projection The Coordinate reference system of the canvas. Eiher a
#' numeric EPSG code or a proj string such as "+proj=longlat +datum=WGS84".
#'
#' @examples
#' # set canvas with Universal Polar Stereographic
#' set_canvas(c(-4e7,  4e7, -4e7,  4e7 ),'+proj=ups')
#' get_canvas()
#' get_canvas(4e4)
#'
#' # set canvas with tilted perspective...
#' set_canvas(c(-3.8e6,  3.8e6, -3.8e6,  3.8e6 ),'+proj=tpers +h=5500000 +lat_0=40')
#' get_canvas(4e4)
#'
#' # set WGS84 global extent
#' set_canvas_world()
#' get_canvas(0.7)
#'
#' # set canvas for Mt. St Helens
#' set_canvas_centroid(46.200732, -122.187082, radius = 7000)
#' get_canvas(10)
#'
#' # set canvas with sf object.
#' library(sf)
#' demo(nc, ask = FALSE, echo = FALSE)
#' set_canvas_sf(nc)
#' get_canvas(7e-3)
#'
#' canvas_extent()
#'
#' @export
set_canvas <- function(bounds, projection){

  is.cartesian(projection)

  if (is.numeric(projection)) {       # if EPSG numeric is given convert to wkt
    projection <- sf::st_crs(projection)$wkt
  }

  canvas0 <- list(extent = c(bounds[1], bounds[2], bounds[3], bounds[4]),
                  projection = projection)

  set_project_canvas(canvas0)

}


#' @name raytrix_set_canvas
#'
#' @export
set_canvas_world <- function() {
  set_project_canvas(list(extent = c(-180, 180,
                                     -90, 90),
                          projection = "+proj=longlat +datum=WGS84"))

}

#' @name raytrix_set_canvas
#' @param .sf The sf/sfc object used to set the extent and projection of the canvas
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
#' @param projection ...
#'
#' @export
set_canvas_centroid <- function(lat, long, radius=5000,
                                projection="+proj=longlat +datum=WGS84"){

  extent_sfc <- sf::st_sfc(sf::st_point(c(long, lat)))%>%
    sf::st_set_crs(projection)

  if (suppressWarnings(!is.cartesian(sf::st_crs(projection)))) {
    extent_sfc <- extent_sfc %>%
      sf::st_transform(crs=3857)
    warning(paste0('`set_canvas_centroid() `converts coordinates to web mercator for convnience.',
            'to set a specific canvas extent and projection use `set_canvas()`'))
  }

  extent_sfc <- extent_sfc %>%
    sf::st_buffer(radius)%>%
    sf::st_bbox()%>%
    sf::st_as_sfc()



  set_canvas_sf(extent_sfc)
}


#' @name raytrix_set_canvas
#'
#' @param res A resolution (i.e pixel dimensions) in the units of the canvas crs
#' (`get_canvas()$`)
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


#' @name raytrix_set_canvas
#' @export
canvasExent <- function(){

  canvas <- get_canvas()

  setClass('Extent', representation(xmin='numeric', xmax='numeric',
                                    ymin='numeric', ymax='numeric'),
           package='raytrix')
  new('Extent', xmin=canvas$extent[1], xmax=canvas$extent[2],
               ymin=canvas$extent[3], ymax=canvas$extent[4])
}


