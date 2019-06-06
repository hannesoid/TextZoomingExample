#  ScrollView Text Quality

The sample project contains 

- a scrollview, containing three UILabels

## Instructions
Run sample project on a 2x simulator (iPhone 8 or iPad) or on devices.
Zoom around the whole range.
Observe how the texts look and behave during zoom-scale changes.

### Label 1
Label 1 is a UILabel, which is not further altered. The contentScale remains as initially set by system.
Looks blurry when zoomed in, and pixely when zoomed out: Zoom around continuously betweeen 5% and 10%, it "glitters" due to aliasing

### Label 2
Label 2 gets its `.contentScale` adapted to displayScale * zoomLevel
It looks good when zooming in but may become blurry when zoomed out <= 20%.

### Label 3
Label 2 gets its `.contentScale` adapted to displayScale * zoomLevel * 2.
It looks good when zooming in and is still more readable than Label 2 at zoom scales like 20%.
When zooming around small scales and between 5% and 8% it glitters a bit like label 1.
It also adds higher memory consumption.

Note: When using just zoomLevel as contentScale, it becomes quite blurry.

## Issue
- How to optimize legibility, crispness and smoothness accross wide range of zoom levels, while retaining optimized graphics memory footprint?
- Is there a recommended/ideal way to update `.contentScale` during zooming?
