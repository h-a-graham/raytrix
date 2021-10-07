#' High Level Data download method.
#'
#' retrieve a raster using vapour::warp from a desired source.
#' This function is taken from {gdalio} https://github.com/hypertidy/gdalio/blob/main/R/gdalio.R
#'
#' @param res The desired cell resolution of the matrix in canvas CRS units.
#' @param src Default is 'aws'. The server from which to download topographic
#' data.
#' @export
rtrix_data <- function(dsn, res, resample, ..., bands = 1L) {
  g <- get_canvas(res)

  if (utils::packageVersion("vapour") <= "0.8.0") {
    ## catch this old case, it keeps confusing me ...
    out <-  vapour::vapour_warp_raster(dsn, extent = g$extent, dimension = g$dimension, wkt = g$projection, bands = bands, resample=resample,  ...)

  } else {
    out <- vapour::vapour_warp_raster(dsn, extent = g$extent, dimension = g$dimension, projection = g$projection, bands = bands, resample=resample, ...)
  }
  out
}

