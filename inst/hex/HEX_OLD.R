#HEX OLD
library(raytrix)
library(rayshader)
library(scico)
library(sf)
library(graticule)

prj <- '+proj=tpeqd +lat_1=60 +lat_2=65'

grat <- st_graticule() %>%
  st_transform(prj) %>%
  st_geometry() %>%
  st_as_sf() %>%
  st_union()

grat_area <- st_as_sf(graticule(proj = prj, tiles=T)) %>%
  st_make_valid() %>%
  st_union()
grat_area <-  st_multipolygon(lapply(grat_area, function(x) x[1])) %>%st_geometry() %>%
  st_as_sf(crs=prj)

# plot(grat_area, col='red')
# plot(st_geometry(grat), add=T)

set_canvas_sf(grat_area)

gebco <- topo_matrix(2e4,
                     src = '/vsicurl/https://public.services.aad.gov.au/datasets/science/GEBCO_2019_GEOTIFF/GEBCO_2019.tif',
                     resample = 'average',
                     warp_options=c("SOURCE_EXTRA=360")
)

biasTurbo <- function(bias, direction, n=256){
  pal <- colorRampPalette(viridisLite::turbo(n, direction=direction), bias=bias)
  return(pal(n))
}

bathypal <- scico(256, palette = 'oslo')
bathy_hs = height_shade(gebco, texture = bathypal)

diamonMap <- gebco %>%
  height_shade(texture = scico(512, palette = 'vikO', direction=1))%>%
  add_overlay(generate_altitude_overlay(bathy_hs, gebco, 0, 0), alphalayer = 1)  %>%
  add_shadow(ray_shade(gebco,zscale=1e4*1e-2, sun_angle=10, multicore = T),0) %>%
  add_shadow(texture_shade(gebco, detail = 0.3, contrast=5, brightness=10),0) %>%
  add_overlay(generate_line_overlay(grat, canvasExent(),gebco, color = 'grey90'), rescale_original = F, alphalayer = 0.9)

plot_3d(diamonMap, gebco, zscale=2e4, baseshape='hex', windowsize = 1000,
        theta = -90, phi = 89, fov = 0, zoom = 0.65)

render_depth(title_text = "raytrix",
             title_font = 'Megrim',
             title_offset = c(300, 150),
             title_color = 'grey80',
             title_size = 120,
             fstop = 1,
             focallength = 50,
             bokehshape='hex',
             zscale =1*1e-1,
             print_scene_info=FALSE)

# render_highquality(filename = 'ideas/hex.png',
#                    lightdirection = c(0, 60,110, 240),
#                    lightaltitude=c(-45, 90,25, 12),
#                    lightintensity=c(700, 100, 500, 450),
#                    lightcolor = c('#FFCE9A',"white", "#FF9956", "#73A7E1"),
#                    environment_light = 'data/syferfontein_1d_clear_4k.hdr', # download from: https://polyhaven.com/hdris/sunrise-sunset
#                    # cache_filename=cache_f,
#                    samples =100,
#                    title_text = "raytrix",
#                    title_font = 'Megrim',
#                    title_offset = c(200, 80),
#                    title_color = 'grey90',
#                    title_size = 120)

rgl::rgl.close()
