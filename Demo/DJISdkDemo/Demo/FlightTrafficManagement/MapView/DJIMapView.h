//
//  DJIMapView.h

//
//  Created by DJI on 15-6-10.
//  Copyright (c) 2015 DJI All rights reserved.
//

/**
 * Main Features：
 * 1. Show the customized DJIAnnotation including userAnnotation, aircraftAnnotation, as well as homeAnnotation.
 * 2. Use MKOverlayView draw the aircraft flying path as well as  the path from aircraft to the home if the draw path flags are
 *    set as true.
 * 3. Draw the safe fly circle to remind user to set waypoint in the safe fly area.
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DJIAircraftAnnotation.h"
#import "DJIHomeAnnotation.h"
#import "DJIUserAnnotation.h"
#import "DJIBaseView.h"



/*
 * If the mode that aircraft is always at center of map is enabled,
 * DJIMapViewUpdateTypeAircraftInCenter will be used to identify.
 */
typedef NS_ENUM(NSUInteger, DJIMapViewUpdateType) {
    DJIMapViewUpdateTypeNone,
    DJIMapViewUpdateTypeAircraftInCenter
};

/*
 * Standard map types
 */
typedef NS_ENUM(NSInteger, CustomMapType) {
    CustomMapTypeNormal = 0,
    CustomMapTypeSatalite = 1,
    CustomMapTypeHybrid = 2,
};


@interface DJIMapView :DJIBaseView
{
    DJIAircraftAnnotation* _gsAircraftAnnotation;
    DJIHomeAnnotation *_homeAnnotation;
    DJIUserAnnotation *_userAnnotation;
}

@property (strong, nonatomic) MKMapView *mapView;

@property(nonatomic, retain) DJIAircraftAnnotation* gsAircraftAnnotation;
@property(nonatomic, retain) DJIHomeAnnotation* homeAnnotation;


/**
 *  Radian value on the transform to.
 */
@property CATransform3D transformForHeading;


/**
 *  Used to update aircraft's position on map
 */
@property (nonatomic, assign) DJIMapViewUpdateType updateType;

/**
 *  Color of the line from homepoint to aircraft
 */
@property (nonatomic, strong) UIColor *homeLineColor;
@property (nonatomic, assign) BOOL showHomeAicraftLine;

/*
 * Based on mobile current location to have a circle to remind user about the 
 * safe flying area.
 */
@property (nonatomic, strong) CLLocation *mobileLocation;
@property (nonatomic, assign) CGFloat limitRadius;
@property (nonatomic, assign) BOOL enabledRemindingCircle;




/**
 *  Zoom the map and show the aircraft at the center
 */
- (void)zoomToAircraft;

/**
 *  Zoom the map and show the home point at the center
 */
- (void)zoomToHomePoint;

/**
 *  Zoom the map and show the coordinate at the center
 *
 *  @param coordinate
 */
- (void)zoomToCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 *  Add or update the aircraft annoation view's position and heading.
 *
 *  @param coordinate
 *  @param heading
 */
-(void) updateAircraftLocation:(CLLocationCoordinate2D)coordinate withHeading:(CGFloat)heading;


/**
 *  Update camera direction
 *
 *  @param direction
 */
//- (void)updateAircraftCameraDirection:(CGFloat)direction;

- (void)updateUserLocationHeading:(CGFloat)heading;

- (void)updateUserLocation:(CLLocationCoordinate2D)userCoordinate;

/**
 * Update aircraft annotation and its view on the map
 */
- (void)updateAircraftAnnotation:(CLLocationCoordinate2D)coordinate withYawDegree:(double)yawDegree andRollDegree:(double)rollDegree;

/**
 *  Update homepoint's location on the map
 */
- (void)updateHomeAnnotation:(CLLocationCoordinate2D)coordinate;

/**
 * Once enable CompassDevice mode, the annotations on the map view 
 * need to be transformed.
 */
- (void)updateMapAnnotationTransform;

/**
 *  Adjust aircraft annotation view transformation on the map
 */
- (void)updateAircraftTransform;


/**
 * Set the current location of the user on the map is not valide because its precision is pretty low
 *  @param validate YES means valid，NO means invalid，
 */
- (void)setUserLocationValidate:(BOOL)validate;

/**
 *  Update the reminding circle
 *
 */
- (void)updateRemindingCircle;

/**
 *  Remove the reminding circle
 */
- (void)removeRemindingCircle;

/**
 * To make this delegate method can be called in child class DJIGSMapView, so declare it here.
 */
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated;


/**
 *  Clean the map view on the annotation views, such as home point, user, aircraft etc.
 */
- (void) cleanMapView;
@end