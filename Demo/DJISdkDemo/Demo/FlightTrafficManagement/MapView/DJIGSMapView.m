//
//  DJIGSMapView.m
//  GroundStation
//  Based on the DJIMapView, this class will extend to support GroundStation MapView features, such as
//  Support waypointAnnotation and its views, and all the operations such as tap to add waypoint, and drag to move the waypoint.
//
//  Updated by DJI on 15-6-28.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "DJIGSMapView.h"
#import <QuartzCore/QuartzCore.h>
#import "ExternalDeviceManager.h"
#import "ExternalICAOAnnotation.h"

@implementation DJIGSMapView

#define    aircraft_selected_bg_text_font       [UIFont fontWithName:@"BebasNeue" size:14.0f]

- (id)init
{
    self = [super init];
    if (self)
    {
        if([self.mapView respondsToSelector:@selector(setRotateEnabled:)]){
            [self.mapView setRotateEnabled:NO];
        }
    }
    return self;
}

#pragma mark - Setter
- (void)setMapViewType:(GSMapViewType)mapViewType
{
    self.mapView.zoomEnabled = YES;
    //Zoom in or zoom out map view
    _pinchRecognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(onScale:)];
    [_pinchRecognizer setDelegate:self];
    
    NSArray* gestures = [self.mapView gestureRecognizers];
    for (UIGestureRecognizer* gesture in gestures) {
        [self.mapView removeGestureRecognizer:gesture];
    }
    
    [self.mapView addGestureRecognizer:_pinchRecognizer];
    
    
    _tapGtureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGture:)];
    _tapGtureRecognizer.numberOfTapsRequired = 1;
    _tapGtureRecognizer.delegate = self;
    [self.mapView addGestureRecognizer:_tapGtureRecognizer];
    
    _mapViewType = mapViewType;
}


#pragma mark - Gesture
- (void)onPanGesture:(UIPanGestureRecognizer *)panGesture
{
    // ToDo: no feature design for now.
}


- (CLLocationCoordinate2D)getAircraftCoordinate
{
    if (_gsAircraftAnnotation)
    {
        return _gsAircraftAnnotation.coordinate;
    }
    
    return kCLLocationCoordinate2DInvalid;
}


- (void)tapGture:(UITapGestureRecognizer *)tapGestureRecognizer
{

    // Just handle the single touch event here.
    if (tapGestureRecognizer.numberOfTouches > 1)
    {
        return;
    }
    
   
    if ([[externalDeviceManager ICAOAnnotations] count] > 0) {
        ExternalICAOAnnotation* selectedAnnotation = [externalDeviceManager getTapGestureAnnotation:tapGestureRecognizer];
        if (selectedAnnotation != nil) {
            [selectedAnnotation showDetailView];
            return;
        }
    }
    
    return;
}


- (void)onScale:(UIPinchGestureRecognizer *)pinchGesture
{
    
    if (pinchGesture.state == UIGestureRecognizerStateBegan)
    {
        
    }
    
}


#pragma mark - distance

#pragma  mark - annonation selected button click


- (void)sortAnnotations
{
    
    if (_gsAircraftAnnotation)
    {
        [_gsAircraftAnnotation.annotationView.superview bringSubviewToFront:_gsAircraftAnnotation.annotationView];

    }
    
}

#pragma mark - UIGestureRecognizerDelegate

// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    UIViewController *detailView = [[UIViewController alloc] init];
    detailView.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];

}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    
    for (MKAnnotationView* view in views)
    {
        
        if ([mapView viewForAnnotation:_userAnnotation] == view) {
            continue;
        }
                
        DJIAnnotation* annotation = (DJIAnnotation *)view.annotation;
        
        for (UIView* v in [view subviews])
        {
            [v removeFromSuperview];
        }
        
        if ([annotation isKindOfClass:[MKUserLocation class]])
        {
            continue;
            
        } else {
            annotation.annotationView = view;
        }
        
        if ([annotation respondsToSelector:@selector(setImageForAnnotationView)]){
            
            for (UIView * v in [view subviews]) {
                [v removeFromSuperview];
            }
            
           [annotation performSelector:@selector(setImageForAnnotationView)];
        }
        

     }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [super mapView:mapView regionDidChangeAnimated:animated];

    [self sortAnnotations];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)aAnnotation
{
    if ([aAnnotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKAnnotationView* annotation_view = nil;
    
    if ([aAnnotation isKindOfClass:[DJIAnnotation class]])
    {
        DJIAnnotation* annotation = (DJIAnnotation *)aAnnotation;
      if ([annotation respondsToSelector:@selector(createAnnotationViewFor:)])
        {
            annotation_view = [annotation performSelector:@selector(createAnnotationViewFor:) withObject:mapView];
        }
    }
    return annotation_view;
}

@end
