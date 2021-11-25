#' plot texture over a 3d mesh
#'
#' This is an alternative to rayshader's `plot_3d` but rather than plotting the
#' elevation as a matrix it converts
#'
plot_3d_mesh <- function(height_map, texture, zscale=0.2, lit=F,
                         windowsize=600, ...){

  topo_raster <- heightmap_to_raster(height_map)

  texture_rgb <- texture_to_brick(texture)

  .mesh2 <- anglr::as.mesh3d(topo_raster, image_texture=texture_rgb, lit=lit)
  anglr::plot3d(.mesh2)
  rgl::aspect3d(x = 1, y = 1, z = zscale)
  rgl::rgl.clear( type = "bbox" )
  rgl::par3d(windowRect = c(20, 30, windowsize[1], windowsize[length(windowsize)]))
}
