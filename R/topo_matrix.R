
#' Get topography matrix
#'
#' retrieve a topographical matrix for the canvas region. Set the resolution
#' of the cell size and the elevation source.
#'
#' @param res The desired cell resolution of the matrix in canvas CRS units.
#' @param src Default is 'gebco'. The server from which to download topographic
#' data. Use `raytrix::topo_sources()` to view available sources (via {toppgraphy}).
#' See details.
#' @details
#' See https://github.com/hypertidy/gdalio and https://gdal.org/drivers/raster/wms.html for examples of custom sources from the web. Alternatively, you can download a file and specify the local path.

#' @export
topo_matrix <- function(res, src='gebco', resample='CubicSpline', out_type='matrix', ...) {

    t_src <- get_topo_xml(src)

    v <- rtrix_data(t_src, res, resample,
                    band_output_type='Float64',
                    ...)
    g <- get_canvas(res)

    if (out_type=='matrix'){
      m <- matrix(v[[1]], g$dimension[1])[,g$dimension[2]:1, drop = F]
      m <- rotate(rotate(m)) %>%
        apply(2,rev)
      return(m)
    } else if (out_type=='raster'){
      r <- raster::raster(raster::extent(g$extent), nrows = g$dimension[2], ncols = g$dimension[1], crs = g$projection)
      if (length(v) > 1) {
        r <- raster::brick(replicate(length(v), r, simplify = FALSE))
      }
      r <- raster::setValues(r, do.call(cbind, v))
      return(r)
    }




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
  c(top_serv_tibble$label,
    'aws')
}

get_topo_xml<- function(.src){

  if (.src %in% topo_sources()){
    if (.src == 'aws'){
      return(system.file("extdata", "aws_tiles.xml", package = "raytrix", mustWork = T))
    } else {
      return(topography::topography_source(.src))
    }

  } else {
    warning('The requested topography data source is not available from {topography}.
         Assuming custom src has been supplied...')
    return(.src)
  }
}
