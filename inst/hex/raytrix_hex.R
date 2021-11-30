# ---- HEX LOGO ----------

library(raytrix)
library(rayshader)
library(scico)
library(sf)
library(graticule)
library(rayrender)
library(rayimage)

# proj and resolution
prj <- '+proj=tpeqd +lat_1=60 +lat_2=65'
.res <-5e4

# get graticule and graticule area
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

set_canvas_sf(grat_area)

# Download Data
gebco <- topo_matrix(.res,
                     src = '/vsicurl/https://public.services.aad.gov.au/datasets/science/GEBCO_2019_GEOTIFF/GEBCO_2019.tif',
                     resample = 'average'
)

# Colours setup
biasScico <- function(bias, palette='bilbao', direction=1, n=256){
  pal <- colorRampPalette(scico(n, palette = palette, direction = direction), bias=bias)
  return(pal(n))
}

bathypal <- biasScico(1.2, palette = 'oslo')
bathy_hs = height_shade(gebco, texture = bathypal)

sphere_pal <- biasScico(1.2, palette='romaO', direction=1, n=5)

# Rayshade
diamonMap <- gebco %>%
  sphere_shade(texture = create_texture(sphere_pal[1], sphere_pal[2],
                                        sphere_pal[3],sphere_pal[4],
                                        sphere_pal[5],),
               zscale = .res*4e-3) %>%
  add_overlay(generate_altitude_overlay(bathy_hs, gebco, 0, 0), alphalayer = 1)  %>%
  add_shadow(texture_shade(gebco, detail = 0.6, contrast=5, brightness=15),0) %>%
  add_overlay(generate_line_overlay(grat, canvasExent(),gebco, color = 'grey90'), rescale_original = F, alphalayer = 0.9)

# PLot 3d with rgl
plot_3d(diamonMap, gebco, zscale=.res*1e-2, baseshape='hex', windowsize = 1000,
        theta = -90, phi = 89, fov = 0, zoom = 0.65)

#save as an obj
save_obj(filename = 'inst/hex/HexRayRender3.obj')

# render with rayrender
scene <- generate_ground(depth=-10, material = diffuse(checkercolor="grey50")) %>%
  add_object(obj_model('inst/hex/HexRayRender3.obj', texture = T)) %>%
  add_object(sphere(x=-10,y=300,z=-240,radius=25,material=light(color = '#FFA271',
                                                                 intensity = 50)))

render_scene(filename = 'inst/hex/HexRayRender10.png',scene,
             parallel=TRUE,samples=100, lookfrom=c(-1,2200,0),
             width = 1000,
             height = 1000)

add_title('inst/hex/HexRayRender10.png',
          title_text = "raytrix",
                       title_font = 'Megrim',
                       title_offset = c(205, 125),
                       title_color = 'grey80',
                       title_size = 180,
          filename = 'inst/hex/HexRayRender10A.png')


add_vignette('inst/hex/HexRayRender10A.png',
             filename = 'inst/hex/HexRayRender10B.png')



