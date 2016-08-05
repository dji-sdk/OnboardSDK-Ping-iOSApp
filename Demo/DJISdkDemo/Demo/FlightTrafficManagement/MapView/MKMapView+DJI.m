//
//  MKMapView+DJI.m
//
//
//  Created by DJI on 15-4-30.
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "AppGlobal.h"
#import "MKMapView+DJI.h"


@implementation MKMapView (DJI)

- (void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated invalidCoordinateHandler:(void (^)(void))handler
{
    if (!CLLocationCoordinate2DIsValid(region.center)) {
        if (handler) {
            handler();
        }
    } else {
        MKCoordinateRegion fitRegion = [self regionThatFits:region];
        if (isnan(fitRegion.center.latitude)) {
            // iOS 6 will result in nan.
            fitRegion.center.latitude = region.center.latitude;
            fitRegion.center.longitude = region.center.longitude;
            fitRegion.span.latitudeDelta = 0;
            fitRegion.span.longitudeDelta = 0;
        }
        [self setRegion:fitRegion animated:animated];
        

    }
}

- (void)zoomToFitAnnotationsAnimated:(BOOL)animated
{
    [self zoomToFitAnnotationsAnimated:animated edgePadding:UIEdgeInsetsZero];
}

- (void)zoomToFitAnnotationsAnimated:(BOOL)animated edgePadding:(UIEdgeInsets)insets
{
    if ([self.annotations count] == 0) {
        return;
    }
    
    MKMapRect mapRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.annotations) {
        MKMapPoint mapPoint = MKMapPointForCoordinate([annotation coordinate]);
        mapRect = MKMapRectUnion(mapRect, MKMapRectMake(mapPoint.x, mapPoint.y, 0.1, 0.1));
    }
    
    [self setVisibleMapRect:mapRect edgePadding:insets animated:animated];
}

- (double)determineAltitudeForCoordinateRegion:(MKCoordinateRegion)coordinateRegion  andWithViewport:(CGSize)viewport {

    
    // Calculate a new bounding rectangle that is corrected for the aspect ratio
    // of the viewport/camera -- this will be needed to ensure the resulting
    // altitude actually fits the polygon in view for the observer.
    
    
    CLLocationCoordinate2D upperLeftCoord = CLLocationCoordinate2DMake(coordinateRegion.center.latitude + coordinateRegion.span.latitudeDelta / 2, coordinateRegion.center.longitude - coordinateRegion.span.longitudeDelta / 2);
    CLLocationCoordinate2D upperRightCoord = CLLocationCoordinate2DMake(coordinateRegion.center.latitude + coordinateRegion.span.latitudeDelta / 2, coordinateRegion.center.longitude + coordinateRegion.span.longitudeDelta / 2);
    CLLocationCoordinate2D lowerLeftCoord = CLLocationCoordinate2DMake(coordinateRegion.center.latitude - coordinateRegion.span.latitudeDelta / 2, coordinateRegion.center.longitude - coordinateRegion.span.longitudeDelta / 2);
    
    CLLocationDistance hDist = MKMetersBetweenMapPoints(MKMapPointForCoordinate(upperLeftCoord), MKMapPointForCoordinate(upperRightCoord));
    CLLocationDistance vDist = MKMetersBetweenMapPoints(MKMapPointForCoordinate(upperLeftCoord), MKMapPointForCoordinate(lowerLeftCoord));
   
        CLLocationCoordinate2D southCoordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude - coordinateRegion.span.latitudeDelta, coordinateRegion.center.longitude);
        CLLocationCoordinate2D northCoordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude + coordinateRegion.span.latitudeDelta, coordinateRegion.center.longitude);
        CLLocationCoordinate2D westCoordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude, coordinateRegion.center.longitude - coordinateRegion.span.longitudeDelta);
        CLLocationCoordinate2D eastCoordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude, coordinateRegion.center.longitude + coordinateRegion.span.longitudeDelta);
        if (eastCoordinate.longitude > 180.0f) {
            eastCoordinate.longitude = -180 + (eastCoordinate.longitude - 180);
        }

        if (westCoordinate.longitude < -180.0f) {
            westCoordinate.longitude = 180 + (westCoordinate.longitude + 180);
        }

        CLLocation *southLocation = [[CLLocation alloc] initWithLatitude:southCoordinate.latitude longitude:southCoordinate.longitude];
        CLLocation *northLocation = [[CLLocation alloc] initWithLatitude:northCoordinate.latitude longitude:northCoordinate.longitude];
        CGFloat distanceHeight = [southLocation distanceFromLocation:northLocation];

        CLLocation *westLocation = [[CLLocation alloc] initWithLatitude:westCoordinate.latitude longitude:westCoordinate.longitude];
        CLLocation *eastLocation = [[CLLocation alloc] initWithLatitude:eastCoordinate.latitude longitude:eastCoordinate.longitude];
        CGFloat distanceWidth = [eastLocation distanceFromLocation:westLocation];
    
    double adjacent;
    double newHDist, newVDist;
    
    if (distanceHeight > distanceWidth) {
        newVDist = vDist;
        newHDist = (viewport.width / viewport.height) * vDist;
        
        adjacent = vDist / 2;
    } else {
        newVDist = (viewport.height / viewport.width) * hDist;
        newHDist = hDist;
        
        adjacent = hDist / 2;
    }
    
    double result = adjacent / tan(RADIAN(15));
    return result;
}
@end
