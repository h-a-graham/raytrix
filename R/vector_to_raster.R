vector_to_raster <- function(v, g, target_dim, out_type, alpha=NULL){

  matrix_thing <- function(.v){
    m <- matrix(.v, target_dim[1])#[,g$dimension[2]:1, drop = F]
    rotate(m)
  }

  if (out_type[1]=='matrix'){
    m <- matrix(v[[1]], target_dim[1])[,target_dim[2]:1, drop = F]
    if (length(v) > 1) {
      v2 <- lapply(v, matrix_thing)
      a <- matrix(NA, target_dim[2],target_dim[1])
      m <- array(c(unlist(v2, use.names = FALSE), a), c(target_dim[2], target_dim[1], 4))[,target_dim[1]:1, , drop = FALSE]
      m <- m%>%
        scales::rescale(.,to=c(0,1))

      m[,,4] <- alpha
    } else {
      m <- rotate(rotate(m)) %>%
        apply(2,rev)
    }
    return(m)

  } else if (out_type[1]=='raster'){
    r <- raster::raster(raster::extent(g$extent), nrows = target_dim[2], ncols = target_dim[1], crs = g$projection)
    if (length(v) > 1) {
      r <- raster::brick(replicate(length(v), r, simplify = FALSE))
    }
    r <- raster::setValues(r, do.call(cbind, v))
    return(r)
  } else if (out_type[1]=='terra'){

    r <- terra::rast(terra::ext(g$extent), nrows = target_dim[2], ncols = target_dim[1], crs = g$projection)
    if (length(v) > 1) {
      nlyr(r) <- length(v)
    }
    r <- terra::setValues(r, do.call(cbind, v))
    return(r)

  } else if (out_type[1]=='stars'){

    aa <- array(unlist(v, use.names = FALSE), c(target_dim[1], target_dim[2], length(v)))[,target_dim[2]:1, , drop = FALSE]
    if (length(v) == 1) aa <- aa[,,1, drop = TRUE]
    r <- stars::st_as_stars(sf::st_bbox(c(xmin = g$extent[1], ymin = g$extent[3], xmax = g$extent[2], ymax = g$extent[4])),
                            nx = g$dimension[1], ny = g$dimension[2], values = aa, nz=length(v))

    r <- sf::st_set_crs(r, g$projection)
    return(r)

  } else {
    stop(sprintf("out_type class: %s is not supported. Please select from:
c('matrix','RasterLayer','SpatRaster', 'stars')"))
  }
}

