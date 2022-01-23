#' create a faded alpha layer for a texture map
#'
#' ...
#'
#' @param texture ...
#' @param sf_feature ...
#' @param alpha_1_buff ...
#' @param kernel_dim ...
#' @param kernel_extent ...
#' @param ... passed to `rayimage::render_convolution_fft`
#' @details
#' ...
#' @export
alpha_sf <- function(texture, sf_feature, alpha_1_buff,
                     kernel_dim=c(9,9), kernel_extent=9, ...){

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
    texture[,,4] <- i[,,4]
  } else if (dim(texture)[3]==3){
    texture <- abind::abind(texture, i[,,1])
  } else ('stop... incorrect number of bands. ')
  texture
}

