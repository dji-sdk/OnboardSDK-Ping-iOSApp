//
//  DJICustomsMapView.h

//
//  Created by DJI on 15/10/14.
//  Copyright (c) 2015  DJI All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJICustomsMapView : MKMapView

/*! protectZoomLevel - BOOL for turning zoom limitting on to protect against Max zoom bug in iOS 6. In production, this should probably always be true.
 */
@property (nonatomic) BOOL protectZoomLevel;


/*! Get the Google Zoom level for the current region of the map.
 @see http://www.maptiler.org/google-maps-coordinates-tile-bounds-projection/
 */
- (double) getZoomLevel;


/*! Explicitly set the zoom level for the current MKMapView region's center coordinate. Use this method as a utility method for zoom steppers, etc.
 @param zoomLevel - an Integer between 1 and 20.
 */
- (void) setZoomLevel:(NSInteger)zoomLevel animated:(BOOL)animated;


/*! Get the predicted MKCoordinateRegion for a coordinate at a particular zoom level for the current map. This is somewhat equivalent to -regionThatFits.
 @param zoomLevel - an Integer between 1 and 20.
 @param coordinate - A CLLocationCoordinate2D structure that determines the center point of the region to determine
 @discussion This method takes a zoom level and a coordinate and determines a region box that will fit in the MapView at that moment.
 */
- (MKCoordinateRegion) coordinateRegionForZoomLevel:(NSInteger)zoomLevel atCoordinate:(CLLocationCoordinate2D)coordinate;

- (void)checkAndResetZoomScale;

+ (DJICustomsMapView *)sharedInstanceWith:(CGRect)frame;

@end
