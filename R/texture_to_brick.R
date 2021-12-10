

#' Covert a rayshader texture to a RasterBrick
#'
#' retrieve rayshader texture as a RasterBrick. This is handy if you want to
#' save the texture as to file with spatial reference or if you want  to plot in
#' an alternative package such as ggplot or tmap etc.
#'
#' @param texture The texture created from a rayshader pipeline.
#'
#' @return An object of class 'RasterBrick' from the {raster} package.
#' data.
#' @export
texture_to_brick <- function(texture){

  # r <- raster::raster(raster::extent(get_canvas()$extent),
  #                     nrows = dim(texture)[1],
  #                     ncols = dim(texture)[2],
  #                     crs = get_canvas()$projection)
  #
  # raster::brick(r, values = scales::rescale(texture, to = c(0, 255)))

  raster::brick(scales::rescale(texture, to = c(0, 255)),
                xmn = get_canvas()$extent[1],
                xmx = get_canvas()$extent[2],
                ymn = get_canvas()$extent[3],
                ymx = get_canvas()$extent[4],
                crs = get_canvas()$projection)
}

#' Covert a rayshader heightmap to a Raster
#'
#' retrieve rayshader texture as a RasterBrick. This is handy if you want to
#' save the texture as to file with spatial reference or if you want  to plot in
#' an alternative package such as ggplot or tmap etc.
#'
#' @param texture The texture created from a rayshader pipeline.
#'
#' @return An object of class 'RasterBrick' from the {raster} package.
#' data.
#' @export
heightmap_to_raster <- function(heightmap){

  r <- raster::raster(raster::extent(get_canvas()$extent),
                      nrows = dim(heightmap)[1],
                      ncols = dim(heightmap)[2],
                      crs = get_canvas()$projection)

  raster::setValues(r, rotate(heightmap))
}



