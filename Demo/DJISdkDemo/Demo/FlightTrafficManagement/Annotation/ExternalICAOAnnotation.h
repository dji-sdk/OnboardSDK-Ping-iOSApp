//
//  ExternalICAOAnnotation.h
//  DJISdkDemo
//
//  Created by dji on 9/3/15.
//  Copyright © 2015 DJI. All rights reserved.
//

#import "DJIAircraftAnnotation.h"
#import "ExternalDeviceManager.h"

@interface ExternalICAOAnnotation : DJIAircraftAnnotation

/*
 * Key of the annotation
 */

@property (nonatomic, retain) NSString *annotationName;

/*
 * Label for the 
 */
//@property(nonatomic, retain) UILabel* HVelocity;

@property(nonatomic, retain) UILabel* altitude;
@property(nonatomic, retain) UILabel* detailAltitude;
@property(nonatomic, retain) UILabel* detailIcaoName;
@property(nonatomic, retain) UILabel* detailHeading;
@property(nonatomic, retain) UILabel* detailVelocity;

@property(nonatomic, assign) NSInteger referenceCount;
@property(nonatomic, assign) NSTimeInterval timeInterval;
@property(nonatomic, retain) TrafficThreatData* threatData;
@property (nonatomic,retain) UIView* detailView;


/*
 * Update the altitue, speed at vertical and horizontal on the annotation view.
 */
//- (void) updateAltitude:(int16_t) alt vSpeed:(int16_t)vSpeed andHSpeed:(int16_t)hSpeed;
- (void) updateAltitude;
- (void) showDetailView;
@end
