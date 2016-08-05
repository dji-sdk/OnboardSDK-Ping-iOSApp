//
//  DJIUserAnnotation.m
//
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "DJIUserAnnotation.h"
#import "AppGlobal.h"
#import "DJIUserAnnotationView.h"

@implementation DJIUserAnnotation

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate heading:(CGFloat)heading
{
    DJIUserAnnotation *instance = [self annotationWithCoordinate:coordinate];
    if (instance) {
        instance.heading = heading;
    }
    
    return instance;
}


-(id) init {
    self = [super init];
    
    if (self) {
        self.annotationType = GsAnnotationTypeUser;
    }
    
    return self;
}


- (id) createAnnotationViewFor:(MKMapView *)mapView {

    //Create a non-UI MKAnnotationView object for userLocation
    DJIUserAnnotationView* user_location_view = (DJIUserAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"DJIUserAnnotationView"];
    if (nil == user_location_view)
    {
        DJIUserAnnotation *userLocation = (DJIUserAnnotation *)self;
        user_location_view = [[DJIUserAnnotationView alloc] initWithAnnotation:userLocation reuseIdentifier:@"DJIUserAnnotationView"];
        [user_location_view.userLocationView directionViewRotateWithAngle:userLocation.heading];
        
    }
    
    user_location_view.annotation = self;
    user_location_view.enabled = YES; // Note: This view will ignore user's tap event
    mapView.showsUserLocation = YES;
    return user_location_view;

}



@end
