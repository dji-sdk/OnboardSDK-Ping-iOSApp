//
//  DJIAircraftAnnotation.m
//
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "AppGlobal.h"
#import "DJIAircraftAnnotation.h"


@implementation DJIAircraftAnnotation
{
    NSString* _annotationTitle;
}

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate heading:(CGFloat)heading
{
    DJIAircraftAnnotation *instance = [self annotationWithCoordinate:coordinate];
    if (instance) {
        instance.heading = heading;
    }
    
    return instance;
}

-(id) init
{
    self = [super init];
    if (self) {
        _annotationTitle = nil;
        self.annotationType = GSAnnotationTypeAircraft;
    }
    
    return self;
}

-(void) setAnnotationTitle:(NSString*)title
{
    _annotationTitle = title;
}

-(NSString*) title
{
    return _annotationTitle;
}

- (void) setHeading:(double)heading {
    _heading = heading;
}



- (id) createAnnotationViewFor:(MKMapView *)mapView {
    self.mapView = mapView;
    self.annotationView = [self createAnnotationViewFor:mapView withIdentity:@"GSAnnotationTypeAircraft" andTag:aircraft_annotation_view_tag];
    return self.annotationView;
}

/*
 * Add the Drone icon as well as the camera icon,
 */
- (void)setImageForAnnotationView{
    
    // Add camera view
    if (!self.cameraViewBg)
    {
        self.cameraViewBg = [[UIView alloc]init];
        self.cameraViewBg.frame = CGRectMake(0, 0, 1, 1);
    }
    
    [self.cameraImageView removeFromSuperview];
    RELEASE_SAFELY(self.cameraImageView);
    
    self.cameraImageView = [[UIImageView alloc]init];
    self.cameraImageView.frame = CGRectMake(-27, -64, 54, 64);
    [self.cameraViewBg addSubview:self.cameraImageView];
    
    self.cameraImageView.image = [UIImage imageNamed:@"osd_attitude_gimbal"];
    [self.annotationView addSubview:self.cameraViewBg];
    
    // Add Drone view
    if (!self.annotationViewBg)
    {
        self.annotationViewBg = [[UIView alloc]init];
        self.annotationViewBg.frame = CGRectMake(0, 0, 1, 1);
    }
    
    [self.annotationImageView removeFromSuperview];
    RELEASE_SAFELY(self.annotationImageView);
    self.annotationImageView = [[UIImageView alloc]init];
    self.annotationImageView.frame = CGRectMake(-75, -75, 150, 150);
    [self.annotationViewBg addSubview:self.annotationImageView];
    
    self.annotationImageView.image = [UIImage imageNamed:@"map_ann_aircraft"];
    [self.annotationView addSubview:self.annotationViewBg];

}


- (void) updateAttitudes {
     [self.annotationViewBg setTransform:CGAffineTransformMakeRotation(_currentAircraftYaw * M_PI/180)];
     [self.cameraViewBg setTransform:CGAffineTransformMakeRotation(_currentCameraYaw* M_PI/180)];
}

@end
