//
//  DJIAircraftAnnotation.h
//
//   
//  Copyright (c) 2015 DJI. All rights reserved.


#import "DJIAnnotation.h"

@interface DJIAircraftAnnotation : DJIAnnotation
/*
 * Drone's flying direction
 */
@property(nonatomic, assign) double heading;
@property(nonatomic, assign) double currentAircraftHeight;
@property(nonatomic, assign) double currentAircraftSpeedXY;
@property(nonatomic, assign) double currentAircraftSpeedZ;
/*
 * Drone's head direction, pitch, and roll
 */
@property(nonatomic, assign) double currentAircraftYaw;
@property(nonatomic, assign) double currentAircraftRoll;
@property(nonatomic, assign) double currentAircraftPitch;

/*
 * Camera's head direction which agaist the Drone's head direction.
 */
@property(nonatomic, assign) float currentCameraYaw;


/*
 *Camera view on the drone
 */
@property(nonatomic, retain) UIView* cameraViewBg;
// Camera image
@property(nonatomic, retain) UIImageView* cameraImageView;

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate heading:(CGFloat)heading;
- (void) setHeading:(double)heading;

/*
 * Based on current aircraft's attitude data, update the UI of the aircraft
 */
- (void) updateAttitudes;

@end
