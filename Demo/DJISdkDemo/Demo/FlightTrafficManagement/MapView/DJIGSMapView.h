//
//  DJIGSMapView.h
//  GroundStation
//
//  Created by DJI on 15-6-8.
//  Copyright (c) 2015 DJI All rights reserved.
//  Refined by DJI Liu on June 10 2015
//  This class is used to maintain all the objects and logics on GS in mapView.
/*
 * Key features:
 * Inherited from DJIMapView to focus on showing the waypointAnnoation and corresponding actions on waypoints.
 */

#import <Foundation/Foundation.h>
#import <MapKit/Mapkit.h>
#import "DJIAnnotation.h"
#import "DJIHomeAnnotation.h"
#import "DJIAircraftAnnotation.h"
#import "DJIMapView.h"

typedef enum
{
    GSMapViewType_One,
    GSMapViewType_One_Gohome_Edit,
    GSMapViewType_One_Waypoint_Edit,
    GSMapViewType_One_Eyepoint_Edit,
    GSMapViewType_One_Preview,
}
GSMapViewType;

@interface DJIGSMapView : DJIMapView
<MKMapViewDelegate,
UIGestureRecognizerDelegate,
UITextFieldDelegate
>
{
    // Need to be cleaned later
    GSMapViewType _mapViewType;
    CGContextRef _context;

    //Used to scale or zoom in, zoom out the map view
    UIPinchGestureRecognizer* _pinchRecognizer;
    //Handle the tap event to add the waypoints
    UITapGestureRecognizer* _tapGtureRecognizer;
    //Handle the drag event to move the waypoint to another postion
    UIPanGestureRecognizer* _panGesture;
    
}

// DJI: Do not need this type, but need spend time to clean it
@property(nonatomic, assign) GSMapViewType mapViewType;


- (CLLocationCoordinate2D)getAircraftCoordinate;


// Reorder the annoations' views on the mapView
- (void)sortAnnotations;

@end
