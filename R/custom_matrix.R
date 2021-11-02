
#' Provide custom data sources for single Band Raster.
#'
#' Working on it...
#' @param res ...
#' @param src ...
#'
#' @export
custom_matrix <- function(res, src, ...){
  v <- rtrix_data(src, res, resample, ...)
  g <- get_canvas(res)

  m <- matrix(v[[1]], g$dimension[1])[,g$dimension[2]:1, drop = F]

  rotate(rotate(m)) %>%
    apply(2,rev)
}
