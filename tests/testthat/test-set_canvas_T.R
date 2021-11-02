test_that("multiplication works", {
  .lat <- 46.200732
  .long <- -122.187082
  expect_warning(set_canvas_centroid(.lat, .long, radius = 7000))

})

test_that("extent checks", {
  .lat <- 46.200732
  .long <- -122.187082
  set_canvas_centroid(.lat, .long, radius = 7000)

  expect_equal(round(as.numeric(get_canvas()$extent)),
                  c(-13608804, -13594804,   5805575 ,  5819575))
})

test_that("world canvas extent", {
  set_canvas_world()

  expect_equal(as.numeric(get_canvas()$extent),
               c(-180, 180, -90, 90))
})

test_that("world canvas projection", {
  set_canvas_world()

  expect_equal(get_canvas()$projection,
               "+proj=longlat +datum=WGS84")
})
