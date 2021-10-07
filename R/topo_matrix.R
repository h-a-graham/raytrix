
#' Get topography matrix
#'
#' retrieve a topographical matrix for the canvas region. Set the resolution
#' of the cell size and the elevation source.
#'
#' @param res The desired cell resolution of the matrix in canvas CRS units.
#' @param src Default is 'aws'. The server from which to download topographic
#' data.
#' @export
topo_matrix <- function(res, src='aws', resample='CubicSpline', ...) {

    t_src <- get_topo_xml(src)

    v <- rtrix_data(t_src, res, resample, ...)
    g <- get_canvas(res)

    m <- matrix(v[[1]], g$dimension[1])[,g$dimension[2]:1, drop = F]

    rotate <- function(x) t(apply(x, 2, rev))
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
    stop('The requested topography data source is not available.
         Use raytrix::topo_sources() to get available options.')
  }
}
