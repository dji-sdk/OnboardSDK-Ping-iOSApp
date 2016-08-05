//
//  DJIMapView.m
//
//
//  Created by DJI on 15-4-10.
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "DJIMapView.h"

#import "DJIAnnotation.h"
#import "AppGlobal.h"
#import "DJIUserAnnotationView.h"
#import "MKMapView+DJI.h"
#import "DJICustomsMapView.h"

#define kDJIMapViewZoomInSpan (3000.0f)
#define kDJIMapViewUpdateFlightLimitZoneDistance (1000.0)
// 20 miles circle to demo the Ping's capability to accept the data.
#define kRemindingCircle (32000.0)
#define kCoordinateReginRadius (kRemindingCircle*2)

// Reminding circle colors
#define STROKECOLOR  [UIColor colorWithRed:71 green:143 blue:13 alpha:1.0]
#define FILLCOLOR  [UIColor colorWithRed:71 green:143 blue:13 alpha:0.2]
//#define FILLCOLOR    [UIColor blackColor]

@interface DJIMapView () <MKMapViewDelegate>

// A green circle centered current user location to suggest user auto fly in this circle
@property (nonatomic, strong) MKCircle *remindingCircle;

// Flag to make the map zoom in once getting user's location, just execute once.
@property (nonatomic) BOOL shouldZoomWhenFetchingUserLocation;

@end

@implementation DJIMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setupDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self setupDefaults];
    }
    return self;
}

#pragma mark - Public

-(void) updateAircraftLocation:(CLLocationCoordinate2D)coordinate withHeading:(CGFloat)heading
{
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        if (_gsAircraftAnnotation == nil) {
            _gsAircraftAnnotation =  [DJIAircraftAnnotation annotationWithCoordinate:coordinate heading:heading];
            [self.mapView addAnnotation:_gsAircraftAnnotation];
            [self zoomToCoordinate:coordinate];
        }
        else
        {
            [_gsAircraftAnnotation setCoordinate:coordinate];
            _gsAircraftAnnotation.currentAircraftYaw = heading;
            _gsAircraftAnnotation.currentCameraYaw = heading;
            [_gsAircraftAnnotation updateAttitudes];
            if (_updateType == DJIMapViewUpdateTypeAircraftInCenter){
                [self.mapView setCenterCoordinate:coordinate animated:YES];
            }
            
        }
    }
}


- (void)updateUserLocation:(CLLocationCoordinate2D)userCoordinate
{
    if (CLLocationCoordinate2DIsValid(userCoordinate)) {
        _mapView.showsUserLocation = NO;
        if (!_userAnnotation) {
            _userAnnotation = [DJIUserAnnotation annotationWithCoordinate:userCoordinate];
            [self.mapView addAnnotation:_userAnnotation];
        }
        
        [_userAnnotation setCoordinate:userCoordinate];
    }
    
}

- (void)updateUserLocationHeading:(CGFloat)heading
{
    DJIUserAnnotationView *annotationView = (DJIUserAnnotationView *)[_mapView viewForAnnotation:_userAnnotation];

    if (annotationView != nil) {
        [[annotationView userLocationView] directionViewRotateWithAngle:heading];
    }
    
}

- (void)updateMapAnnotationTransform
{
    NSMutableArray *annotations = [[_mapView annotations] mutableCopy];
    [annotations removeObject:_gsAircraftAnnotation];
    [annotations removeObject:_userAnnotation];
    
    if (_homeAnnotation) {
        MKAnnotationView *view = _homeAnnotation.annotationView;
        view.layer.transform = _transformForHeading;
    }
    
    for (DJIAnnotation *annotation in annotations) {
        MKAnnotationView *annotationView = [_mapView viewForAnnotation:annotation];
        [annotationView.layer setTransform:_transformForHeading];
    }
    
}

-(void)updateAircraftAnnotation:(CLLocationCoordinate2D)coordinate withYawDegree:(double)yawDegree andRollDegree:(double)rollDegree {

    [self updateAircraftLocation:coordinate withHeading:yawDegree];
    [_gsAircraftAnnotation setCurrentAircraftRoll:rollDegree];
}

-(void)updateHomeAnnotation:(CLLocationCoordinate2D)coordinate {
    // Update the current Home Position
    if (_homeAnnotation)
    {
        [_homeAnnotation setCoordinate:coordinate];
    }
    else
    {
        _homeAnnotation = [[DJIHomeAnnotation alloc]initWithCoordinate:coordinate];
        [self.mapView addAnnotation:_homeAnnotation];
    }
}

- (void)updateAircraftTransform
{
    if (_gsAircraftAnnotation) {
        MKAnnotationView *view = [_mapView viewForAnnotation:_gsAircraftAnnotation];
        
        [view.layer setTransform:_transformForHeading];
    }

}


- (void)updateRemindingCircle:(CGFloat)limitRadius
{
    self.limitRadius = limitRadius;
    self.enabledRemindingCircle = YES;
    [self updateRemindingCircle];
}

- (void)zoomToCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (fabs(coordinate.latitude) < 1e-15 && fabs(coordinate.longitude) < 1e-15) {
        return;
    }
    
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, kCoordinateReginRadius, kCoordinateReginRadius);
        [self.mapView setRegion:region animated:YES invalidCoordinateHandler:nil];
    }
    
    [self updateRemindingCircle:kRemindingCircle];
}

- (void)zoomToAircraft
{
    
    if (![self.mapView userLocation] && !_gsAircraftAnnotation && !_userAnnotation && !_homeAnnotation) {
        return;
    }
    CLLocationCoordinate2D aircraftCoordinate = [[self.mapView userLocation] coordinate];
    
    if (_gsAircraftAnnotation) {
        aircraftCoordinate = _gsAircraftAnnotation.coordinate;
    } else if (_userAnnotation) {
        aircraftCoordinate = _userAnnotation.coordinate;
    } else if (_homeAnnotation) {
        aircraftCoordinate = _homeAnnotation.coordinate;
    } else if (_mobileLocation) {
        aircraftCoordinate = [_mobileLocation coordinate];
        
    }
    
    if (fabs(aircraftCoordinate.latitude) < 1e-15 && fabs(aircraftCoordinate.longitude) < 1e-15) {
        return;
    }
   
    [self zoomToCoordinate:aircraftCoordinate];
}

- (void)zoomToHomePoint
{
    if (![self.mapView userLocation] && !_gsAircraftAnnotation && !_userAnnotation && !_homeAnnotation) {
        return;
    }
    
    CLLocationCoordinate2D homeCoordinate = [[self.mapView userLocation] coordinate];
    
    if (_homeAnnotation) {
        homeCoordinate = _homeAnnotation.coordinate;
    } else if (_userAnnotation) {
        homeCoordinate = _userAnnotation.coordinate;
    } else if (_gsAircraftAnnotation) {
        homeCoordinate = _gsAircraftAnnotation.coordinate;
    } else if (_mobileLocation) {
        homeCoordinate = [_mobileLocation coordinate];
        
    }
   
    if (fabs(homeCoordinate.latitude) < 1e-15 && fabs(homeCoordinate.longitude) < 1e-15) {
        return;
    }
    
    [self zoomToCoordinate:homeCoordinate];
}



#pragma mark - Private

/**
 *  Initial the mapview
 */
- (void)setupDefaults
{
    /**
     *  setup mapView. Use singleton to save the loaded map

     */
    self.mapView = [DJICustomsMapView sharedInstanceWith:self.bounds];
    self.mapView.showsUserLocation = YES;
    self.mapView.pitchEnabled = YES;
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    [self addSubview:self.mapView];
    
    self.transformForHeading = CATransform3DIdentity;

}


#pragma mark - MKMapViewDelegate


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    
    if (overlay == self.remindingCircle) {
        MKCircleRenderer *circleRender = [[MKCircleRenderer alloc] initWithCircle:self.remindingCircle];
        circleRender.strokeColor = STROKECOLOR;
        circleRender.lineWidth = 2.0f;
        circleRender.fillColor = FILLCOLOR;
        return circleRender;
    }
    
    return nil;
}


- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.shouldZoomWhenFetchingUserLocation) {
        self.shouldZoomWhenFetchingUserLocation = NO;
        [mapView setRegion:MKCoordinateRegionMake(userLocation.location.coordinate, MKCoordinateSpanMake(.01, .01)) animated:YES invalidCoordinateHandler:nil];
        
    }
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [(DJICustomsMapView *)mapView checkAndResetZoomScale];
    
}



#pragma mark -- Limit Circle

- (void)updateRemindingCircle
{
    if ((self.limitRadius < 1e-3 && self.remindingCircle) || !self.enabledRemindingCircle) {
        [self.mapView removeOverlay:self.remindingCircle];
        self.remindingCircle = nil;
        return;
    }
    
    CGFloat currentRadius = self.remindingCircle.radius;
    CLLocationCoordinate2D currentCoordinate = self.remindingCircle.coordinate;

    if (CLLocationCoordinate2DIsValid(self.mobileLocation.coordinate)) {
        CLLocationCoordinate2D coordinate = self.mobileLocation.coordinate;
        if (fabs(currentRadius - self.limitRadius) < 1e-3 && fabs(currentCoordinate.latitude - coordinate.latitude) < 1e-5 && fabs(currentCoordinate.longitude - coordinate.longitude) < 1e-5) {
            return;
        }
        
        [self.mapView removeOverlay:self.remindingCircle];
        
        self.remindingCircle = [MKCircle circleWithCenterCoordinate:coordinate radius:self.limitRadius];
        
        [_mapView addOverlay:self.remindingCircle];
    }
}

/**
 *  Remove the limit warning circle, actually this circle is not no flyzone, which 
 *  is just used to warning the GS user to keep flying in circle for safe.
 */
- (void)removeRemindingCircle
{
    if (self.remindingCircle) {
        [self.mapView removeOverlay:self.remindingCircle];
        
        self.remindingCircle = nil;
        
        return;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (void)setUserLocationValidate:(BOOL)validate
{
    if (!_userAnnotation) {
        return;
    }
    
    DJIUserAnnotationView *userLocationView = (DJIUserAnnotationView *)[_mapView viewForAnnotation:_userAnnotation];
    
    if (![userLocationView isKindOfClass:[DJIUserAnnotationView class]]) {
        return;
    }
    
    [[userLocationView userLocationView] setValidate:validate];
    
    
}


#pragma mark - annonation point line


- (void) cleanAnnotationView:(DJIAnnotation*) annotation {
    if (annotation != nil) {
        [_mapView removeAnnotation:annotation];
    }
}

- (void) cleanMapView {
    [self cleanAnnotationView:_userAnnotation];
    [self cleanAnnotationView:_homeAnnotation];
    [self cleanAnnotationView:_gsAircraftAnnotation];
}


@end
