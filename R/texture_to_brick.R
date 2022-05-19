

#' Covert a rayshader texture to a RasterBrick
#'
#' retrieve rayshader texture as a RasterBrick. This is handy if you want to
#' save the texture as to file with spatial reference or if you want  to plot in
#' an alternative package such as ggplot or tmap etc.
#'
#' @param texture The texture created from a rayshader pipeline.
#' @param out_type set the return class of the raster stack/brick. see details.
#'
#' @details
#' For `out_type`, 'raster' retruns an object of class RasterBrick, 'terra'
#' returns a 'SpatRaster' and 'stars returns a 'stars' object.
#'
#' @return An object of class 'RasterBrick' from the {raster} package.
#' data.
#' @export
texture_to_brick <- function(texture, out_type=c('raster','terra', 'stars')){

  tex_arr <- scales::rescale(texture, to = c(0, 255))
  g <- get_canvas()
  if (out_type[1]=='raster'){
    brk <- raster::brick(tex_arr, xmn = g$extent[1], xmx = g$extent[2],
                  ymn = g$extent[3], ymx = g$extent[4], crs = g$projection)
  } else if (out_type[1]=='terra'){
    brk <- terra::rast(tex_arr)
    terra::ext(brk) <- ext(g$extent)
    terra::crs(brk) <- g$projection
  } else if (out_type[1]=='stars'){
    tex_arr.stars <- lapply(1:dim(tex_arr)[3], function(x) t(tex_arr[,,x])) %>%
      abind()

    brk <- st_as_stars(sf::st_bbox(c(xmin = g$extent[[1]], ymin = g$extent[[3]],
                                     xmax = g$extent[[2]], ymax = g$extent[[4]])),
                        nx=dim(tex_arr)[1], ny=dim(tex_arr)[2],  values=(tex_arr.stars),
                       crs=g$projection, nz=dim(tex_arr)[3])
  }

  return(brk)
}

#' Covert a rayshader heightmap to a Raster
#'
#' Pretty sure we don't need or want this now...
#'
#' @param texture The texture created from a rayshader pipeline.
#'
#' @return An object of class 'RasterBrick' from the {raster} package.
#' data.
#' @export
heightmap_to_raster <- function(heightmap, out_type=c('raster','terra', 'stars')){
  g <- get_canvas()
  if (out_type[1]=='raster'){
    r <- raster::raster(raster::extent(g$extent),
                        nrows = dim(heightmap)[1],
                        ncols = dim(heightmap)[2],
                        crs = g$projection)
    r <- raster::setValues(r, t(heightmap))
  } else if (out_type[1]=='terra'){
    r <- terra::rast(terra::ext(g$extent),
                        nrows = dim(heightmap)[1],
                        ncols = dim(heightmap)[2],
                        crs = g$projection)
    r <- terra::setValues(r, t(heightmap))
  }else if (out_type[1]=='stars'){

    r <- st_as_stars(sf::st_bbox(c(xmin = g$extent[1], ymin = g$extent[3],
                                   xmax = g$extent[2], ymax = g$extent[4])),
                   nx=dim(heightmap)[2], ny=dim(heightmap)[1],
                   values=t(heightmap),
                   crs="+proj=nzmg +datum=WGS84")


  }



}



