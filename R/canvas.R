#canvas

# check extent and proj validity... Need to add check for projected CRS.
is_canvas_valid <- function(x){
  # check extent and projection are valid. from {gdlaio}
  # https://github.com/hypertidy/gdalio/blob/main/R/default_grid.R
  has_extent <- is.numeric(x[["extent"]]) && length(x[["extent"]] == 4) && all(!is.na(x[["extent"]])) &&
    diff(x[["extent"]][1:2]) > 0 && diff(x[["extent"]][3:4]) > 0
  if (!has_extent) stop("invalid extent")

  has_proj <- is.character(x[["projection"]]) && length(x[["projection"]] == 1) && !is.na(x[["projection"]])
  if (!has_proj) stop("invalid projection")
  x
}

# check valiity and set default canvas
set_project_canvas <- function(x){

  x <- is_canvas_valid(x)

  options(raytrix.canvas=x)
}

# some kind of check neeed for
is.cartesian <- function(x){
  if (length(grep('Cartesian', sf::st_crs(x)$wkt))>0) {
    return(TRUE)
    } else {
      warning("Canvas CRS converted to EPSG:3857. {rayshader} does not support
            unequal sized grids")
      return(FALSE)
    }

}


# basic call()
set_canvas <- function(xmin,xmax, ymin, ymax, crs){


  canvas0 <- list(extent = c(xmin, xmax, ymin, ymax),
                  projection = st_crs(aoi)$wkt)

  set_project_canvas(canvas0)

}





set_canvas_sf <- function(x, res, mask=T){

  if (!is.cartesian(x)) {
    x <- sf::st_transform(x, crs=3857)
  }

  bounds <- x %>%
    st_bbox()
  canvas0 <- list(extent = c(bounds$xmin, bounds$xmax, bounds$ymin, bounds$ymax),
                projection = st_crs(aoi)$wkt)
  options(raytrix.canvas=canvas0)
}



get_canvas <- function(){

  if (is.null(getOption("raytrix.canvas"))){
    stop("Raytrix canvas has not been set. Please set this using one of the
         following functions: set_canvas(), set_canvas_raster(),
         set_canvas_sf(), set_canvas_centroid()")
  } else {

    getOption("raytrix.canvas")

  }
}




