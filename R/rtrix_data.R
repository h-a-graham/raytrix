#' High Level Data download method.
#'
#' retrieve a raster using vapour::warp from a desired source.
#' This function is taken from {gdalio} https://github.com/hypertidy/gdalio/blob/main/R/gdalio.R
#'
#' @param res The desired cell resolution of the matrix in canvas CRS units.
#' @param src The server from which to download topographic or map data. See details:
#' @param resample ...
#' @param ... ...
#' @param bands ...
#' @param dimension ...
#' @details
#' See https://github.com/hypertidy/gdalio and https://gdal.org/drivers/raster/wms.html for examples of custom sources from the web. Alternatively, you can download a file and specify the local path.
rtrix_data <- function(dsn, res, resample, ..., bands = 1L, dimension) {
  if (missing(res) & missing(dimension)) stop("Missing Value. You must provide either the desired resolution with 'res' or dimension with 'dimension'")

  if (!missing(dimension)){
    target_dim <- dimension
    g <- get_canvas()
  } else {
    g <- get_canvas(res)
    target_dim <- g$dimension
  }


  if (utils::packageVersion("vapour") <= "0.8.0") {
    ## catch this old case, it keeps confusing me ...
    out <-  vapour::vapour_warp_raster(dsn, extent = g$extent,
                                       dimension = target_dim,
                                       wkt = g$projection, bands = bands,
                                       resample=resample,  ...)

  } else {
    out <- vapour::vapour_warp_raster(dsn, extent = g$extent,
                                      dimension = target_dim,
                                      projection = g$projection,
                                      bands = bands,
                                      resample=resample,
                                      ...)
  }
  out
}
