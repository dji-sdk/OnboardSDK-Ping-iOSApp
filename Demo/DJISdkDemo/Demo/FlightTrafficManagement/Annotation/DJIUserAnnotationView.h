//
//  DJIUserAnnotationView.h
//
//
//  Copyright (c) 2015 DJI All rights reserved.
//

#import <MapKit/MapKit.h>
#import "DJIUserLocationView.h"

@interface MKUserLocation (locationView)

//DJI Testing
- (void) setAnnotationView:(MKAnnotationView *)view;


@end

@interface DJIUserAnnotationView : MKAnnotationView

@property (strong, nonatomic) DJIUserLocationView *userLocationView;

@end
