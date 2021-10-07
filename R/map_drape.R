
#' Get map overlay as array
#'
#' retrieve a map matrix for the canvas region. Set the resolution
#' of the cell size and the elevation source.
#'
#' @param res The desired cell resolution of the matrix in canvas CRS units.
#' @param src Default is 'aws'. The server from which to download topographic.
#' @param alpha default 1, set transparency of overlay
#' data.
#' @export
map_drape <- function(res, src="wms_arcgis_mapserver_ESRI.WorldImagery_tms",
                      alpha=1, resample = 'Average', ...){
  src <- get_map_xml(src)
  v <- rtrix_data(src, res, resample, ..., bands = 1:3)
  g <- get_canvas(res)

  matrix_thing <- function(.v){
    m <- matrix(.v, g$dimension[1])#[,g$dimension[2]:1, drop = F]

    rotate <- function(x) t(apply(x, 2, rev))
    rotate(m)
  }

  v2 <- lapply(v, matrix_thing)
  a <- matrix(NA, g$dimension[1],g$dimension[2])
  aa <- array(c(unlist(v2, use.names = FALSE), a), c(g$dimension[1], g$dimension[2], 4))[,g$dimension[2]:1, , drop = FALSE]
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
    stop('The requested topography data source is not available.
         Use gdalwebsrv::available_sources() to get available options.')
  }
}
