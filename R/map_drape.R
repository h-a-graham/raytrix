
#' Get map overlay as array
#'
#' retrieve a 3 dimensional (RGB or other) array for the canvas region.
#'
#' @param res The desired cell resolution of the matrix in canvas CRS units.
#' @param src Default is 'wms_virtualearth'. The server from which to download map data.
#' use `raytrix::map_sources()` to see available built in sources (provided by {gdalwebsrv})
#' or provide your own source. See details...
#' @param alpha default 1, set transparency of overlay data.
#' @details
#' See https://github.com/hypertidy/gdalio and https://gdal.org/drivers/raster/wms.html for examples of custom sources from the web. Alternatively, you can download a file and specify the local path.
#'
#' @export
map_drape <- function(res, src="wms_virtualearth",
                      alpha=1, resample = 'Average', ..., dimension){

  if (missing(res) & missing(dimension)) stop("Missing Value. You must provide either the desired resolution with 'res' or dimension with 'dimension'")

  src <- get_map_xml(src)

  if (!missing(res)){
    v <- rtrix_data(src, res, resample, ..., bands = 1:3)
    g <- get_canvas(res)
    target_dim <- g$dimension
  } else {
    v <- rtrix_data(dsn=src, resample=resample,
                    ..., bands = 1:3,
                    dimension=dimension)
    g <- get_canvas()
    target_dim <- dimension
  }

  matrix_thing <- function(.v){
    m <- matrix(as.numeric(.v), target_dim[1])#[,g$dimension[2]:1, drop = F]
    rotate(m)
  }

  v2 <- lapply(v, matrix_thing)
  a <- matrix(NA, target_dim[2],target_dim[1])
  aa <- array(c(unlist(v2, use.names = FALSE), a), c(target_dim[2], target_dim[1], 4))[,target_dim[1]:1, , drop = FALSE]
  aa <- aa%>%
    scales::rescale(.,to=c(0,1))
  aa[,,4] <- alpha
  return(aa)
}

#' View options for Map layers
#'
#' Function to view options that can be used for the `src` value of
#' ratrix::map_drape()
#'
#' @return A character vector with strings that can be used to set the topogrpahy
#' data source in raytrix::map_drape()
#'
#' @export
map_sources <- function(){
  gdalwebsrv::available_sources()
}

get_map_xml<- function(.src){
  if (.src %in% gdalwebsrv::available_sources()){
    return(gdalwebsrv::server_file(.src))
  } else {
    warning('The requested map data source is not available from {gdalwebsrv}.
         Assuming custom src has been supplied...')
    return(.src)
  }
}
