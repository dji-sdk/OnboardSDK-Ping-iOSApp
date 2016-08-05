//
//  DJICustomsMapView.m

//
//  Created by DJI on 15/10/14.
//  Copyright (c) 2015  DJI All rights reserved.
//

#import "DJICustomsMapView.h"
#define MAX_GOOGLE_LEVELS 20



@implementation DJICustomsMapView


static DJICustomsMapView * shareInstance = nil;
+ (DJICustomsMapView *)sharedInstanceWith:(CGRect)frame {
    
    static dispatch_once_t pred;
    dispatch_once( &pred, ^{
        shareInstance = [[self alloc] initWithFrame:frame];
    });
    return shareInstance;
}

// ******************** Overridden Methods ********************
#pragma mark - Overridden Methods

- (void) setRegion:(MKCoordinateRegion)region animated:(BOOL)animated {
    @try
    {
        [super setRegion:region animated:animated];
    }
    @catch (NSException *exception) {
        [self setCenterCoordinate:region.center];
    }
}

- (void)layoutSubviews
{
//    [super layoutSubviews];
}


// ******************** Public methods ********************
#pragma mark - Public Methods

- (double) getZoomLevel {
    MKMapRect mapRect = self.visibleMapRect;
    
    MKZoomScale zoomScale = mapRect.size.width / self.bounds.size.width;
    double zoomExponent = log2(zoomScale);
    double zoomLevel = (double)MAX_GOOGLE_LEVELS - zoomExponent;
    return zoomLevel;
}

- (void) setZoomLevel:(NSInteger)zoomLevel animated:(BOOL)animated {
    double fineZoomLevel = (double) zoomLevel;
    if (zoomLevel >= MAX_GOOGLE_LEVELS && self.mapType != MKMapTypeStandard && self.protectZoomLevel) {
        NSLog(@"setZoomLevel: Entered Protected Zoom Level");
        fineZoomLevel = (float) MAX_GOOGLE_LEVELS - 1.0;
    }
    
    double aspectRatio = self.visibleMapRect.size.width / self.visibleMapRect.size.height;
    MKMapPoint center = MKMapPointForCoordinate(self.region.center);
    
    double newWidth = exp2(MAX_GOOGLE_LEVELS - fineZoomLevel) * self.bounds.size.width;
    double newHeight = newWidth / aspectRatio;
    
    MKMapRect newRect = MKMapRectMake(center.x-(newWidth/2.0), center.y-(newHeight/2.0), newWidth, newHeight);
    [self setVisibleMapRect:newRect animated:animated];
}

- (MKCoordinateRegion) coordinateRegionForZoomLevel:(NSInteger)zoomLevel atCoordinate:(CLLocationCoordinate2D)coordinate {
    double fineZoomLevel = (double) zoomLevel;
    if (zoomLevel >= MAX_GOOGLE_LEVELS && self.mapType != MKMapTypeStandard && self.protectZoomLevel) {
        NSLog(@"coordinateRegionForZoomLevel: Entered Protected Zoom Level");
        fineZoomLevel = (float) MAX_GOOGLE_LEVELS - 1.0;
    }
    
    double aspectRatio = self.visibleMapRect.size.width / self.visibleMapRect.size.height;
    MKMapPoint center = MKMapPointForCoordinate(coordinate);
    
    double newWidth = exp2(MAX_GOOGLE_LEVELS - fineZoomLevel) * self.bounds.size.width;
    double newHeight = newWidth / aspectRatio;
    
    MKMapRect newRect = MKMapRectMake(center.x-(newWidth/2.0), center.y-(newHeight/2.0), newWidth, newHeight);
    return MKCoordinateRegionForMapRect(newRect);
}


// ******************** Helpers ********************
#pragma mark - Helpers

- (double) getFineZoomLevelForRegion:(MKCoordinateRegion)region {
    double centerPixelX = [DJICustomsMapView longitudeToPixelSpaceX: region.center.longitude];
    double topLeftPixelX = [DJICustomsMapView longitudeToPixelSpaceX: region.center.longitude - region.span.longitudeDelta / 2];
    
    double scaledMapWidth = (centerPixelX - topLeftPixelX) * 2;
    CGSize mapSizeInPixels = self.bounds.size;
    double zoomScale = scaledMapWidth / mapSizeInPixels.width;
    double zoomExponent = log2(zoomScale);
    double zoomLevel = (double)MAX_GOOGLE_LEVELS - zoomExponent;
    
    NSLog(@"Fine Zoom Level: %f", zoomLevel);
    return zoomLevel;
}


// ******************** Conversion Helpers ********************
#pragma mark - Conversion Helpers

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395
+ (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (void)checkAndResetZoomScale
{
    CGFloat zoomLevel = [self getZoomLevel];

    if (zoomLevel > 19.00) { //18.999) {
       MKMapCamera *camera = self.camera;
        CGFloat altitude = camera.altitude;
        [self.camera setAltitude:(altitude + 10)];
        NSLog(@"Altitude is %lf\n", altitude);
    }
}


@end
