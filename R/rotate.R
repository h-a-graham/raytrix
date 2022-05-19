#' Internal function which is used to rotate matrices and arrays.
#'
#' @param x Matrix
#'
#' @return Rotated matrix
#' @keywords internal
#'
rotate <- function(x){
  t(x[nrow(x):1,])
}

#' Flip Left-Right
#'
#' taken from {rayshader}
#'
#' @param x Matrix
#'
#' @return Flipped matrix
#' @keywords internal
#'
#' @examples
#' #Fake example
fliplit <- function(x) {
  if(length(dim(x)) == 2) {
    x[,ncol(x):1]
  } else {
    x[,ncol(x):1,]
  }
}
