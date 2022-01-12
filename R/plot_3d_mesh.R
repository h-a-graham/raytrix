#' plot texture over a 3d mesh
#'
#' This is an alternative  to rayshader's `plot_3d` but rather than plotting the
#' elevation as a matrix it converts it to a mesh using {anglr}. For large scenes
#' THis should improve render times. However, this does not work out of the box
#' with `render_highquality()`. FOr now things are a bit experimental.
#'
#' @param height_map a height map matrix generated with either `raytrix::topo_matrix()` or `rayshader::raster_to_matrix()`
#' @param texture The output from a {rayshader} pipeline or output of `raytrix::map_drape()`
#' @param zscale Numeric value controlling the aspect ratio of the scene. used by `rgl::aspect3d()` so it doesn't behave like rayshaders typical zscale arg,
#' @param lit Boolean, default FALSE. Do you want to light the mesh faces?
#' @param ... Not currently used
#'
#' @export
plot_3d_mesh <- function(height_map, texture, zscale=0.2, lit=FALSE,
                         windowsize=600, ...){

  topo_raster <- heightmap_to_raster(height_map)

  texture_rgb <- texture_to_brick(texture)

  .mesh2 <- anglr::as.mesh3d(topo_raster, image_texture=texture_rgb, lit=lit)
  anglr::plot3d(.mesh2)
  rgl::aspect3d(x = 1, y = 1, z = zscale)
  rgl::rgl.clear( type = "bbox" )
  rgl::par3d(windowRect = c(20, 30, windowsize[1], windowsize[length(windowsize)]))
}
