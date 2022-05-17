
#' Get topography matrix
#'
#' retrieve a topographical matrix for the canvas region. Set the resolution
#' of the cell size and the elevation source.
#'
#' @param res The desired cell resolution of the matrix in canvas CRS units.
#' @param src Default is 'gebco'. The server from which to download topographic
#' data. Use `raytrix::topo_sources()` to view available sources (via {toppgraphy}).
#' See details.
#' @param resample ...
#' @param out_type ...
#' @param dimension ...
#' @param ... ...
#' @details
#' See https://github.com/hypertidy/gdalio and https://gdal.org/drivers/raster/wms.html for examples of custom sources from the web. Alternatively, you can download a file and specify the local path.

#' @export
topo_matrix <- function(res, src='aws', resample='CubicSpline', out_type=c('matrix','raster','terra', 'stars'), dimension, ...) {

    if (missing(res) & missing(dimension)) stop("Missing Value. You must provide either the desired resolution with 'res' or dimension with 'dimension'")

    t_src <- get_topo_xml(src)

    if (!missing(res)){
      v <- rtrix_data(t_src, res, resample,
                      band_output_type='Float64',
                      ...)
      g <- get_canvas(res)
      target_dim <- g$dimension
    } else {
      v <- rtrix_data(dsn=t_src, resample=resample,
                      band_output_type='Float64',
                      ..., dimension=dimension)
      g <- get_canvas()
      target_dim <- dimension

    }

    vector_to_raster(v, g, target_dim, out_type)

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
