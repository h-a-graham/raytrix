# raytrix
A {rayshader} plugin providing a spatial framework and convenience functions for 
accessing and translating spatial data

Current plan...

**Project Canvas:**

These functions will lay out the extent and CRS for the rayshader project.

```
set_canvas(xmin, ymin, xmax, ymax, crs)  # basic argument for setting canvas
set_canvas_raster(raster/terra/stars)  # set canvas from a raster data class
set_canvas_sf(sf/sfc, mask = FALSE)  # set canvas from an sf/sfc object
set_canvas_centroid(long, lat, radius, crs=4326)  # set canvas from cetroid and radius
get_canvas()  # retrieves the extent and crs parameters if required for additional steps...
canvasExtent() # get an object of class Extent for using in other {rayshader} functions
```

**Data:**

These functions enable the retrieval of topographical and overlay (map drape)
data in a "rayshader-ready"" format. i.e. matrix for the topo and 4 dimensional 
array for the overlay. Using {vapour} to haness gdal warp functionality...

```
topo_matrix(res, src='aws', ...)  # currently best source is 'aws' possibl limiting?
map_drape(res, src='esri.aerial', alpha=1 ...) # many options now available here - need to check in on API Key requirements.
```

**Future things:**

*other map overlays:*

Lower priority but would still be cool...

```
plot_3d_mesh()
```

*styles:*

Not sure on this yet but... maybe some helpers to condense sequences of shadow/
texture functions.

```
flotsam()
```
