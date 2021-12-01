
#' Get topography matrix
#'
#' retrieve a topographical matrix for the canvas region. Set the resolution
#' of the cell size and the elevation source.
#'
#' @param res The desired cell resolution of the matrix in canvas CRS units.
#' @param src Default is 'aws'. The server from which to download topographic
#' data. Use `raytrix::topo_sources()` to view available sources (via {toppgraphy}).
#' See details.
#' @details
#' See https://github.com/hypertidy/gdalio and https://gdal.org/drivers/raster/wms.html for examples of custom sources from the web. Alternatively, you can download a file and specify the local path.

#' @export
topo_matrix <- function(res, src='aws', resample='CubicSpline', ...) {

    t_src <- get_topo_xml(src)

    v <- rtrix_data(t_src, res, resample, ...)
    g <- get_canvas(res)

    m <- matrix(v[[1]], g$dimension[1])[,g$dimension[2]:1, drop = F]

    rotate(rotate(m)) %>%
      apply(2,rev)
}




#' View options for Topography layers
#'
#' Function to view options that can be used for the `src` value of
#' ratrix::topo_matrix()
#'
#' @return A character vector with strings that can be used to set the topogrpahy
#' data source in raytrix::topo_matrix()
#'
#' @export
topo_sources <- function(){
  top_serv_tibble <- topography::topography_services()
  top_serv_tibble$label
}

get_topo_xml<- function(.src){
  if (.src %in% topo_sources()){
    return(topography::topography_source(.src))
  } else {
    warning('The requested topography data source is not available from {topography}.
         Assuming custom src has been supplied...')
    return(.src)
  }
}
