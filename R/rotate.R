#' Internal function which is used to rotate matrices and arrays.
#'
rotate <- function(x) t(apply(x, 2, rev))
