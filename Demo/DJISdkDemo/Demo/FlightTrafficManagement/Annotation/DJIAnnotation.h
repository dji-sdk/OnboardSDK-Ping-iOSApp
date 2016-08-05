//
//  DJIAnnotation.h
//
//  Define all kinds of annotations used in DJIMapView.
//  1. Provide a common method to generate the view for the annotaion.
//  Created by DJI on 15-5-10.
//  Copyright (c) 2015 DJI All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


typedef enum
{
    GSAnnotationTypeAircraft,
    GSAnnotationTypeHome,
    GSAnnotationTypeWaypoint,
    GSAnnotationTypeWaypointCopy,
    GSAnnotationTypePreviewWaypoint,
    GSAnnotationTypeFlyingWaypoint,
    GsAnnotationTypeUser,    
    GSAnnotationCommon,
    GSAnnotationTypeEyepoint,
} GSAnnotationType;



@interface DJIAnnotation : NSObject <MKAnnotation>

@property(nonatomic, strong) NSString* text;

/**
 *  GPS Lat and log
 */
@property (nonatomic) CLLocationCoordinate2D coordinate;

/**
 *  Altitude
 */
@property (nonatomic) CGFloat height;

@property (nonatomic, assign) GSAnnotationType annotationType;

/**
 * The life of annotationView is still controled by the mkMapView
 * Although it will be generated in this class, but just keep a weak reference on it.
 */
@property (nonatomic, retain) MKAnnotationView *annotationView;


/*
 *  annotation view
 */
//  Annotation View's background view
@property(nonatomic, retain) UIView* annotationViewBg;
//  Annotation View's foreground view
@property(nonatomic, retain) UIImageView* annotationImageView;
//  Shadow View of Annotation
@property(nonatomic, retain) UIImageView* annotationShadowView;

/*
 * A weak refer to current mapView which is used to draw the corresponding view in the map,
 * such as calculate the annotation point posistion basing the mapView and coordinate value. 
 */
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

/*
 * show the distance lables as well as the line or not.
 */
@property (nonatomic, assign) BOOL isHideDistanceLabel;

/**
 * Factory method to generate the annotation object without type.
 */
+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 * Called as a result of dragging an annotation view.
 */
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate;


// Overidable methods
/**
 * Overidable method for the sub class to identify its type.
 */
- (GSAnnotationType) annotationType;

/**
 *  Creat the annotation view for this type of annotation.
 *  if nil is retuned, which means will use the system default annotation view. 
 *  This method is called viewForAnnotation method.
 */
- (id) createAnnotationViewFor:(MKMapView *) mapView;

- (id) createAnnotationViewFor:(MKMapView *)mapView withIdentity:(NSString *)identifier andTag:(NSInteger)tag;

/*
 * This method is called in the didAddAnnotationViews method to update the icon of the view.
 */
- (void) setImageForAnnotationView;

/*
 * Calculate the distance to the other annotation
 */
- (double)getDistanceToAnnotation:(DJIAnnotation *)dest_annotation;

@end
