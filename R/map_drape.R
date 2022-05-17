
#' Get map overlay as array
#'
#' retrieve a 3 dimensional (RGB or other) array for the canvas region.
#'
#' @param res The desired cell resolution of the matrix in canvas CRS units.
#' @param src Default is 'wms_virtualearth'. The server from which to download map data.
#' use `raytrix::map_sources()` to see available built in sources (provided by {gdalwebsrv})
#' or provide your own source. See details...
#' @param alpha default 1, set transparency of overlay data.
#' @details
#' See https://github.com/hypertidy/gdalio and https://gdal.org/drivers/raster/wms.html for examples of custom sources from the web. Alternatively, you can download a file and specify the local path.
#'
#' @export
map_drape <- function(res, src="wms_virtualearth",
                      alpha=1, resample = 'Average', ..., dimension,
                      out_type=c('matrix','raster','terra', 'stars')){

  if (missing(res) & missing(dimension)) stop("Missing Value. You must provide either the desired resolution with 'res' or dimension with 'dimension'")

  src <- get_map_xml(src)

  if (!missing(res)){
    v <- rtrix_data(src, res, resample, ...,
                    band_output_type='Float64',
                    bands = 1:3)
    g <- get_canvas(res)
    target_dim <- g$dimension
  } else {
    v <- rtrix_data(dsn=src, resample=resample,
                    band_output_type='Float64',
                    ..., bands = 1:3,
                    dimension=dimension)
    g <- get_canvas()
    target_dim <- dimension
  }

  vector_to_raster(v, g, target_dim, out_type, alpha)

  # matrix_thing <- function(.v){
  #   m <- matrix(as.numeric(.v), target_dim[1])#[,g$dimension[2]:1, drop = F]
  #   rotate(m)
  # }
  #
  # v2 <- lapply(v, matrix_thing)
  # a <- matrix(NA, target_dim[2],target_dim[1])
  # aa <- array(c(unlist(v2, use.names = FALSE), a), c(target_dim[2], target_dim[1], 4))[,target_dim[1]:1, , drop = FALSE]
  # aa <- aa%>%
  #   scales::rescale(.,to=c(0,1))
  # aa[,,4] <- alpha
  # return(aa)
}

#' View options for Map layers
#'
#' Function to view options that can be used for the `src` value of
#' ratrix::map_drape()
#'
#' @param full.df default FALSE. If TRUE a dataframe with source and names is returned
#'
#' @return A character vector with strings that can be used to set the topogrpahy
#' data source in raytrix::map_drape()
#'
#' @export
map_sources <- function(full.df=FALSE){
  # gdalwebsrv::available_sources()
  df <- read.csv(url("https://raw.githubusercontent.com/hypertidy/gdalwebsrv/master/inst/bundle/gdalwebsrv.csv"),
                 colClasses = c("character", "character"), check.names = FALSE)

  df_sub <- df[ which( !(df$provider %in%c("gibs","tasmap")|
                           df$name %in% c("aws-elevation-tiles-prod", "NASADEM_be"))),]


  if (isFALSE(full.df)) return(df_sub$name)

  return(df_sub)

}

get_map_xml<- function(.src){
  df <- map_sources(TRUE)
  if (.src %in% df$name){
    src <- df$source[df$name == .src]
    return(src)
  } else {
    warning('The requested map data source is not available from the
hypertidy/gdalwebsrv database.
Assuming custom src has been supplied...')
    return(.src)
  }
}
