#' Create a faded alpha layer based on an sf object for a texture map
#'
#' This function enables the creation of custom alpha layers for map textures.
#' It allows for the blending of layers at varying distances from an area/feature
#' defined by an sf object
#'
#' @param texture A 3 or 4 layer array. This can be a rayshader-generated
#' texture/hillshade or array generated with `raytrix::map_drape`.
#' @param sf_feature object of class sf. Sets the focal region with highest alpha.
#' @param alpha_1_buff Default 10. The distance away from the sf object that
#' should have no transparency (i.e. an alpha value of 1).
#' @param kernel_dim Default c(11, 11). The dimension of the gaussian kernel. see: `rayimage::render_convolution_fft`
#' @param kernel_extent Default 9. Extent over which to calculate the kernel. see `rayimage::render_convolution_fft`
#' @param ... passed to `rayimage::render_convolution_fft`
#' @details
#' ...
#' @export
alpha_sf <- function(texture, sf_feature, alpha_1_buff=10,
                     kernel_dim=c(11,11), kernel_extent=9, ...){

  geom_type <- unique(st_geometry_type(sf_feature))

  if (geom_type %in% c('MULTILINESTRING', 'LINESTRING','POLYGON', 'MULTIPOLYGON', 'POINT', 'MULTIPOINT')){
    buffered_sf <- sf_feature %>% st_buffer(., alpha_1_buff)
    lo <- rayshader::generate_polygon_overlay(buffered_sf, extent = canvasExent(),
                                              width=dim(texture[,,1])[2],
                                              height=dim(texture[,,1])[1],
                                              linecolor = "white",
                                              palette = "white",)
  } else {
    stop(sprintf("A geometry type of %s is not supported please use any from:
'MULTILINESTRING', 'LINESTRING','POLYGON', 'MULTIPOLYGON', 'POINT', 'MULTIPOINT'", geom_type))
  }

  i <- rayimage::render_convolution_fft(lo, kernel_dim=kernel_dim, ...) %>%
    scales::rescale(., c(0,1))

  if (dim(texture)[3]==4){
    texture[,,4] <- i[,,1]
  } else if (dim(texture)[3]==3){
    texture <- abind::abind(texture, i[,,1])
  } else ('stop... incorrect number of bands. ')
  texture
}

