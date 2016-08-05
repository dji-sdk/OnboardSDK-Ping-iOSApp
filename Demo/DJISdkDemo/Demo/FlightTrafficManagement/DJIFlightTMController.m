//
//  DJIFlightTMController.m
//
//
//  Copyright (c) 2015 DJI All rights reserved.
//
#import "AppDelegate.h"
#import "DJIFlightTMController.h"

#import "DJIMapView.h"
#import "DJIAnnotation.h"
#import "MKMapView+DJI.h"
#import "DJIGSCompassButton.h"
#import <CoreLocation/CLLocation.h>
#import "ExternalDeviceManager.h"
#import "DJICustomsMapView.h"

#define kUserDefaultKeyAircraftLocation @"AircraftLocation"

CGFloat const DJIFlightTMControllerViewBottomHeight = 118;
CGFloat const kDJIAircraftLineDistanceFilter = 10.0f;

NSTimeInterval const kDJIUpdateTimeInterval = 0.5f;

NSUInteger const DJIMinGPSNumRequire = 8;

NSString const *DJIFlightTMControllerAirLineClearNotification = @"DJIFlightTMControllerAirLineClearNotification";
NSString const *DJIFlightTMControllerAirLineSettingKeyName = @"DJIFlightTMControllerAirLineSettingKeyName";
NSString const *DJIGSCompassTypeKey = @"DJIGSCompassTypeKey";


#define kStateButtonTakeOffState (0)
#define kStateButtonLandingState (1)
#define kStateButtonCancelTakeOffState (2)
#define kStateButtonCancelLandingState (3)

#define kAlertViewTagTakeOff (2001)
#define kAlertViewTagLanding (2002)
#define kAlertViewTagCancelTakeoff (2003)
#define kAlertViewTagCancelLanding (2004)
#define kAlertViewTagDynamicHomePoint (2005)

#define kAlertViewTagGoHome (1004)

#define kAlertViewTagAircraftHomePoint (2012)
#define kAlertViewTagRCHomePoint (2013)


#define kDJIMobileGPSValidateAccuracy (5) //

#define kDJIUploadFlightLimitZonesDistance (500)

#define kDJIFlightLimitSearchRadius (100000.0f)

#if DEBUG
#define DEBUG_FLIGHT_LIMIT (0)
#endif

#if DEBUG
#define SHOWMEMLOG  [[NSMemLog sharedInstance] logMemUsage]
#else
#define SHOWMEMLOG
#endif

/**
 *  Function type at left side of UI
 */
typedef NS_ENUM(NSUInteger, DJIGSFunctionType) {
    DJIGSFunctionTypeLocate,
    DJIGSFunctionTypeAddWaypoints,
    DJIGSFunctionTypeGoHome,
    DJIGSFunctionTypeLand,
    DJIGSFunctionTypeJoystack,
    DJIGSFunctionTypeMore,
};

@interface DJIFlightTMController () <CLLocationManagerDelegate, UIAlertViewDelegate>
{
    BOOL _animateChangeCameraFlag;
    CGAffineTransform _preViewTransform;
    
    NSMutableArray *_aircraftHistoryLine;
    
    DJIGSFunctionType _function_mode;
    
}


@property (weak, nonatomic) IBOutlet UIView *controlsViewTop;

@property (weak, nonatomic) IBOutlet DJIGSCompassButton *widgetCompassButton;


/**
 *  This button is not used yet  need to refine it later.
 */
@property (weak, nonatomic) UIButton *lastSelectedAddPointsButton;

@property (nonatomic) DJIGSFunctionType functionType;
//@property (nonatomic) DJIGSAddPointsType addPointsType;


/**
 *  Update the device direction
 */
@property (strong, nonatomic) CLLocationManager *locationManager;

/**
 *  Compass direction type
 */
@property (nonatomic, assign) DJIGSCompassType compassType;

@property (nonatomic, assign) DJIGSCompassType preCompassType;

/**
 *  Flag to show fly path or not
 */
@property (nonatomic, assign) BOOL markAirline;


@property (nonatomic, assign) MKCoordinateRegion preMapRegion;

@property (nonatomic, strong) MKMapCamera *preCamera;

@property (nonatomic, assign) CGFloat deviceHeading;

@property (nonatomic, strong) CLLocation *mobileLocation;

@property (nonatomic, strong) CLLocation *rcLocation;

@property (nonatomic, assign) BOOL firstShow; //flag to identify the first time update on user location

@property (nonatomic, assign) CGFloat limitRadius;

@property (nonatomic, retain) DJIFlightControllerCurrentState  *limitStateStruct;

//for debug flight limit
@property (nonatomic, assign) IBOutlet UIButton *addLimitCircle;
@property (nonatomic, assign) CLLocationCoordinate2D testCoordinate;

@property (nonatomic, assign) CLLocationCoordinate2D lastUpdateLimitSearchCoordinate;

@property (nonatomic, assign) CLLocationCoordinate2D lastAircraftCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D lastRemoteControllerCoordinate;

@end

@implementation DJIFlightTMController

- (id)initWithDefaultNib{
    NSString *nibNameOrNil = nil;
    if(IS_IPAD){
        nibNameOrNil = [NSString stringWithFormat:@"%@_iPad",NSStringFromClass([self class])];
    } else {
        NSString* className = @"DJIFlightTMController";//NSStringFromClass([self class]);
        nibNameOrNil = [NSString stringWithFormat:@"%@_iPhone6+", className];
    }
    
    
    if([[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@"nib"] == nil){
        nibNameOrNil = NSStringFromClass([self class]);
    }
    
    if ([[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@"nib"] == nil) {
        nibNameOrNil = [NSString stringWithFormat:@"%@_iPhone5",NSStringFromClass([self class])];
    }
    
    if ([[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@"nib"] == nil) {
        nibNameOrNil = [NSString stringWithFormat:@"%@_iPhone6",NSStringFromClass([self class])];
    }
    
    if ([[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@"nib"] == nil) {
        nibNameOrNil = [NSString stringWithFormat:@"%@_iPhone6+",NSStringFromClass([self class])];
    }
    
    self = [self initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)initialize
{
    NSValue *value = [[NSUserDefaults standardUserDefaults] objectForKey:(NSString *)DJIFlightTMControllerAirLineSettingKeyName];
    if (!value) {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:(NSString *)DJIFlightTMControllerAirLineSettingKeyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void) initialRightSideButtons {
    // Move this controller to top
    CGRect frame = self.controlsViewRight.frame;
    frame.origin.y = 10;
    frame.origin.x = self.view.frame.size.width - 30 - frame.size.width;
    [self.controlsViewRight setFrame:frame];
    
  
    
    [self.controlsViewRight.mapTypeSelectionButton addTarget:self action:@selector(showMapTypeSelection:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.controlsViewRight.locationSelectionButton addTarget:self action:@selector(showLocationSelection:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.controlsViewRight.standardMapTypeButton addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlsViewRight.satelliteMapTypeButton addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlsViewRight.hybirdMapTypeButton addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.controlsViewRight.homePositionButton addTarget:self action:@selector(selectHomePostion:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlsViewRight.aircraftPositionButton addTarget:self action:@selector(selectAircraftPosition:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.controlsViewRight.compassButton addTarget:self action:@selector(showCompass:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)initialLeftSideButtons {
    
    [_takeOffButton setStateIcons:@[@"fpv_leftbar_takeoff_icon", @"fpv_leftbar_landing_icon", @"fpv_leftbar_cancel_icon", @"fpv_leftbar_cancel_icon"]];
    [_goHomeButton setStateIcons:@[@"fpv_leftbar_gohome_icon", @"fpv_leftbar_cancel_icon"]];
}


- (void) initialMapView {
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    CGFloat diagonal = sqrtf(width * width + height * height);
    CGFloat marginHorizontal = (diagonal - width) / 2.f;
    CGFloat marginVertical = (diagonal - height) / 2.f;
    CGRect frame = CGRectMake(- marginHorizontal,  - marginVertical,  width + marginHorizontal * 2,  height + marginVertical * 2);
    self.mapView.bounds = CGRectMake(0,  0, frame.size.width, frame.size.height);
    self.mapView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    self.mapView.mapView.frame = self.mapView.bounds;
    
    [self.mapView setMapViewType:GSMapViewType_One];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.navigationController.navigationBar setHidden:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _lastAircraftCoordinate = kCLLocationCoordinate2DInvalid;
    _lastRemoteControllerCoordinate = kCLLocationCoordinate2DInvalid;
    
    [self initialGSFlyingDelegateOnStatus];
        
    [self initialRightSideButtons];
    [self initialLeftSideButtons];
    
    [self.widgetCompassButton addTarget:self action:@selector(showCompass:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupDefaults];
    
    
    [self initialExternalDeviceManager];
    [self initialMapView];
    
    
    [self hideGoHomeLine];
    [self showAircrafLastLocation];
    
    
    //#if DEBUG_FLIGHT_LIMIT
    [self.addLimitCircle setHidden:NO];
    //#endif
    
    //todo remove test source
#if __TEST_AIRCRAFT__
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(testAircraft:) userInfo:nil repeats:YES];
#endif

    [self observeNotifications];
    [_flightController setDelegate:self];
    
}

- (void) setupNotifications {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goHomeGroundStation) name:NotificationCenter_Command_OneClickGoHomeAction object:nil];
}

- (void) removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationCenter_Command_OneClickGoHomeAction object:nil];
}

- (void) initialGSFlyingDelegateOnStatus {
    
    _drone = (DJIAircraft*)[DJISDKManager product];
    _drone.flightController.delegate = self;
    _flightController = _drone.flightController;
    
}

- (void) initialExternalDeviceManager {
    [externalDeviceManager setMapViewClass:self.mapView];
}



- (void)observeNotifications
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillRotateNotification:) name:DJIDeviceWillRotateNotificationName object:nil];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    [self setupNotifications];
    
    [self performSelector:@selector(selectHomePostion:) withObject:nil afterDelay:1];
}




-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [_mapView cleanMapView];
    
    [self removeNotifications];
}




#pragma mark - UIViewControllerRotation
- (void)handleWillRotateNotification:(NSNotification *)notification
{
    self.mapView.transform = CGAffineTransformIdentity;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    // Dispose of any resources that can be recreated.
}


-(void) showAircrafLastLocation
{
    CGFloat heading = 0.0f;
    if (!CLLocationCoordinate2DIsValid(_lastAircraftCoordinate)) {
        NSString* aircraftLocation = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultKeyAircraftLocation];
        if (aircraftLocation) {
            NSArray *compoments = [aircraftLocation componentsSeparatedByString:@" "];
            if ([compoments count] >= 3) {
                double latitude = [compoments[0] doubleValue];
                double longitude = [compoments[1] doubleValue];
                heading = [compoments[2] doubleValue];
                CLLocationCoordinate2D phantomCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
                if (CLLocationCoordinate2DIsValid(phantomCoordinate)) {
                    _lastAircraftCoordinate = phantomCoordinate;
                }
            }
        }
    }
    
    if (CLLocationCoordinate2DIsValid(_lastAircraftCoordinate)) {
        _mapView.mapView.showsUserLocation = YES;
        [_mapView updateAircraftLocation:_lastAircraftCoordinate withHeading:heading];
    }
}


#pragma mark - Private

/**
 *  Set default value
 */
- (void)setupDefaults
{
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //        self.locationManager.headingFilter = 5;
        self.locationManager.delegate = self;
    }
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
    self.functionType = DJIGSFunctionTypeLocate;
    
    
    if (self.controlsViewRight.compassButton != nil) {
        [self.controlsViewRight.compassButton setSelected:NO];
    }
    DJIGSCompassType compassType = DJIGSCompassLock;
    
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:(NSString *)DJIGSCompassTypeKey];
    if (number) {
        compassType = [number intValue];
        if (compassType > DJIGSCompassDevice) {
            compassType = DJIGSCompassDevice;
        }
    }
    
    self.compassType = compassType;
    self.preCompassType = compassType;
    
}


- (IBAction)gsBackAction:(id)sender {
    [self.navigationController.navigationBar setHidden:NO];
    //[self backButtonAction:sender];
}

- (void)backButtonAction:(UIButton *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)updateUserLocation:(CLLocation *)location
{
    if (!location) {
        return;
    }
    
    CLLocationCoordinate2D userLocation = location.coordinate;
    if (CLLocationCoordinate2DIsValid(userLocation) && _mapView != nil) {
        [_mapView updateUserLocation:userLocation];
    }
    
    _lastRemoteControllerCoordinate = userLocation;
}


- (void)showGoHomeLine
{
    _mapView.homeLineColor = [UIColor colorWithRed:255 green:168 blue:0 alpha:1.0];
}

- (void)hideGoHomeLine
{
    _mapView.homeLineColor = [UIColor colorWithRed:167 green:255 blue:52 alpha:1];
}

/**
 *  Show map type selection view
 */
- (void)showMapTypeSelection:(UIButton *)sender
{
//    [Flurry logEvent:@"GroundStation_RightControlView_Button_ShowMapType"];
    
    BOOL hidden = !self.controlsViewRight.mapTypeSelectionView.hidden;
    [self.controlsViewRight.mapTypeSelectionView setHidden:hidden];
}

/**
 *  Show location selection view
 */
- (void)showLocationSelection:(UIButton *)sender
{
    BOOL hidden = !self.controlsViewRight.locationSelectionView.hidden;
    [self.controlsViewRight.locationSelectionView setHidden:hidden];
}


/**
 *  switch the compass type
 */
- (void)showCompass:(UIButton *)sender
{
    
    self.controlsViewRight.mapTypeSelectionView.hidden = YES;
    
    DJIGSCompassType nextCompassType = DJIGSCompassLock;
    
    if (_compassType == DJIGSCompassLock) {
        nextCompassType = DJIGSCompassDevice;
    }
    
    if (_compassType == DJIGSCompassDevice) {
        nextCompassType = DJIGSCompassLock;
    }
   
    [self setCompassType:nextCompassType];
}

- (void)setCompassType:(DJIGSCompassType)compassType
{
     [[NSUserDefaults standardUserDefaults] setObject:@(compassType) forKey:(NSString *)DJIGSCompassTypeKey];
    
    _preCompassType = _compassType;
    _compassType = compassType;
    
    DJIGSCompassButton *compassButton = (DJIGSCompassButton *)self.controlsViewRight.compassButton;
    
    compassButton.compassType = compassType;
    self.widgetCompassButton.compassType = compassType;
    
    
    [self updateCompassState];
}

- (void)updateCompassState
{
    
    DJIGSCompassType compassType = _compassType;
    
    if (compassType == DJIGSCompassDevice) {
        
        if ([CLLocationManager headingAvailable]) {
            if (_preCompassType != DJIGSCompassDevice) {
                _animateChangeCameraFlag = YES;
            }
            [self.locationManager startUpdatingHeading];
        } else {
            NSLog(@"Compass does not work");
        }
        

        
    } else if (compassType == DJIGSCompassLock){

        /**
         *  Retore the transform did in compassdevice status.
         */
        self.mapView.layer.transform = CATransform3DIdentity;
        self.mapView.transformForHeading = CATransform3DIdentity;
        self.controlsViewRight.compassButton.layer.transform = CATransform3DIdentity;
        self.widgetCompassButton.layer.transform = CATransform3DIdentity;
        [self.mapView updateMapAnnotationTransform];
        
        

    } else if (compassType == DJIGSCompassAircraft) {
        if (_preCompassType != DJIGSCompassAircraft) {
            _animateChangeCameraFlag = YES;
        }
        
        self.widgetCompassButton.layer.transform = CATransform3DIdentity;
        self.controlsViewRight.compassButton.layer.transform = CATransform3DIdentity;
    }
}


- (void)updateMapViewHeaddingWithAircraft:(CGFloat)heading
{
    [self changeMapRotateToHeading:heading];
}

/**
 *  Responding to the map type change event
 */
- (void)changeMapType:(UIButton *)sender
{
    if (sender == self.controlsViewRight.standardMapTypeButton) {
        self.mapView.mapView.mapType = MKMapTypeStandard;
    } else if (sender == self.controlsViewRight.satelliteMapTypeButton) {
        self.mapView.mapView.mapType = iOS9System ? MKMapTypeSatelliteFlyover:MKMapTypeSatellite;
        
    } else {
        self.mapView.mapView.mapType = iOS9System ? MKMapTypeHybridFlyover : MKMapTypeHybrid;
        
    }
    
    self.controlsViewRight.mapTypeSelectionView.hidden = YES;
}


- (void)changeMapRotateToHeading:(CGFloat)degree
{
    CATransform3D transform = CATransform3DMakeRotation(- degree * M_PI / 180, 0.0f, 0.0f, 1.0f);
    CATransform3D transformOpposite = CATransform3DMakeRotation(degree * M_PI / 180, 0.0f, 0.0f, 1.0f);
    self.mapView.layer.transform = transform;
    
    
    self.mapView.transformForHeading = transformOpposite;
    
    if (_compassType == DJIGSCompassAircraft) {
        self.controlsViewRight.compassButton.layer.transform = CATransform3DIdentity;
        self.widgetCompassButton.layer.transform = CATransform3DIdentity;
    } else {
        self.controlsViewRight.compassButton.layer.transform = transform;
        self.widgetCompassButton.layer.transform = transform;
    }
    
    [self.mapView updateMapAnnotationTransform];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    CLLocationDirection degree = 0;
    
    if (UIInterfaceOrientationLandscapeRight == [UIApplication sharedApplication].statusBarOrientation) {
        degree = newHeading.magneticHeading - 270;
    } else if (UIInterfaceOrientationLandscapeLeft == [UIApplication sharedApplication].statusBarOrientation) {
        degree = newHeading.magneticHeading - 90;
    }
    
    if (degree < 0) {
        degree = degree + 360;
    }
    
    if (degree > 360) {
        degree = degree - 360;
    }
    
    // Need adjust the heading of the map and its subviews in CompassDevice type
    if (self.compassType == DJIGSCompassDevice) {
        [self changeMapRotateToHeading:degree];
    }
    
    _deviceHeading = degree;
    
    [self.mapView updateUserLocationHeading:degree];
}


- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return NO;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([locations count] <= 0) {
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    
    _mapView.mobileLocation = location;
    
    //Zoom to user's current location when first time showing the map.
    if (self.firstShow && CLLocationCoordinate2DIsValid(location.coordinate) && !CLLocationCoordinate2DIsValid( _lastAircraftCoordinate)) {
        
        ((DJICustomsMapView*)_mapView.mapView).protectZoomLevel = YES;
        [_mapView zoomToCoordinate:location.coordinate];
        self.firstShow = NO;
    }
    
    if (location.horizontalAccuracy > kDJIMobileGPSValidateAccuracy) {
        self.mobileLocation = nil;
        if (!self.rcLocation) {
            [_mapView setUserLocationValidate:NO];
        }
        return;
    }
    
    if (!self.rcLocation || ([location.timestamp timeIntervalSinceReferenceDate] - [self.rcLocation.timestamp timeIntervalSinceReferenceDate] > 10)) {
        
        [self updateUserLocation:location];
        [_mapView setUserLocationValidate:YES];
    } else {
        [self updateUserLocation:location];
        [_mapView setUserLocationValidate:NO];
    }
    
    
    self.mobileLocation = location;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorLocationUnknown) {
        self.mobileLocation = nil;
        if (!self.rcLocation) {
            [_mapView setUserLocationValidate:NO];
        }
    }
}

#pragma mark - waypoint execution actions

- (void) goHomeGroundStation {
    if (nil != _flightController ) {
        [_flightController goHomeWithCompletion:^(NSError * _Nullable error) {
           // [waypointManager updateGSStatusMessage:error];
            if (error != nil)
                ShowResult(@"ERROR: Go Home: %@", error.description);
        }];
    }
}

- (void) stopGoHome {
    if (nil != _flightController) {
        [_flightController cancelGoHomeWithCompletion:^(NSError * _Nullable error) {
           //   [waypointManager updateGSStatusMessage:error];
            if (error != nil){
                ShowResult(@"ERROR: Cancel Go Home: %@", error.description);
            }
            
        }];
    }
}

- (void) takeOff {
    if (nil != _flightController) {
        [_flightController takeoffWithCompletion:^(NSError * _Nullable error) {
            if (error != nil){
                ShowResult(@"ERROR: Take off: %@", error.description);
            }
            
        }];
    }
}
- (void) autoLanding {
    if (nil != _flightController) {
        [_flightController autoLandingWithCompletion:^(NSError * _Nullable error) {
           // [waypointManager updateGSStatusMessage:error];
            if (error != nil){
                ShowResult(@"ERROR: Auto Landing: %@", error.description);
            }
        } ];
    }
}

- (void) cancelTakeOff {
    if (nil != _flightController) {
        [_flightController cancelTakeoffWithCompletion:^(NSError * _Nullable error) {
            //[waypointManager updateGSStatusMessage:error];
            if (error != nil){
                ShowResult(@"ERROR: Cancel TakeOff: %@", error.description);
            }
        }];
    }
}
- (void) cancelLanding {
    if (nil != _flightController) {
        [_flightController cancelAutoLandingWithCompletion:^(NSError * _Nullable error) {
            //[waypointManager updateGSStatusMessage:error];
            if (error != nil){
                ShowResult(@"ERROR: Cancel Auto Landing: %@", error.description);
            }
        }];
    }
}


#pragma mark - take off button handle

- (IBAction)takeoffButtonAction:(DJIStateButton *)sender{
    NSString *warning = nil;
    
    if(sender.currentState == kStateButtonTakeOffState){
        sender.currentState = kStateButtonLandingState;
        
        warning = NSLocalizedString(@"takeoff_control_TakeOff_warning", @"");
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"takeoff_control_takeoff_title", @"") message:warning delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"ok", @""), nil];
        

        alertView.tag = kAlertViewTagTakeOff;
        [alertView show];
    }
    else if(sender.currentState == kStateButtonLandingState){
        sender.currentState = kStateButtonTakeOffState;
        warning = NSLocalizedString(@"takeoff_control_Landing_warning", @"");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"takeoff_control_Landing_title", @"") message:warning delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"ok", @""), nil];
        
        alertView.tag = kAlertViewTagLanding;
        [alertView show];
    }
    else if(sender.currentState == kStateButtonCancelTakeOffState){
        warning = NSLocalizedString(@"takeoff_control_cancel_takeoff_warning", @"");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:warning message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"ok", @""), nil];
        alertView.tag = kAlertViewTagCancelTakeoff;
        alertView = nil;
    }
    else if(sender.currentState == kStateButtonCancelLandingState){
        warning = NSLocalizedString(@"takeoff_control_cancel_landing_warning", @"");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:warning message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"ok", @""), nil];
        alertView.tag = kAlertViewTagCancelLanding;
        alertView = nil;
    }
}

- (void)updateTakeoffButtonStateWithFlying:(BOOL)isFlying withMode:(DJIFlightControllerFlightMode)mode{
    if(mode == DJIFlightControllerFlightModeAutoTakeOff){
        [_takeOffButton setCurrentState:kStateButtonCancelTakeOffState];
    }
    else if(mode == DJIFlightControllerFlightModeAutoLanding){
        [_takeOffButton setCurrentState:kStateButtonCancelLandingState];
    }
    else{
        if(isFlying){
            [_takeOffButton setCurrentState:kStateButtonLandingState];
        }
        else{
            [_takeOffButton setCurrentState:kStateButtonTakeOffState];
        }
    }
}



#pragma mark - gohome handle

- (IBAction)gohomeButtonAction:(DJIStateButton *)sender{
    NSString *warning = nil;
    if(sender.currentState == 0){
        warning = NSLocalizedString(@"gohome_control_warning", @"");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:warning message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"ok", @""), nil];


        //[alertView.slideTips setText:NSLocalizedString(@"gohome_control_slide_tips", @"")];
        alertView.delegate = self;
        alertView.tag = kAlertViewTagGoHome;
        [alertView show];
        alertView = nil;
    }
    else{
        warning = NSLocalizedString(@"gohome_control_cancel_warning", @"");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:warning message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"ok", @""), nil];
        alertView.tag = kAlertViewTagGoHome;
        alertView.delegate = self;
        [alertView show];
        alertView = nil;
    }
}

- (void)updateGohomeButtonStatues:(BOOL)isGoingHome{
    if(isGoingHome){
        [_goHomeButton setCurrentState:1];
    }
    else{
        [_goHomeButton setCurrentState:0];
    }
}


#pragma mark - iphone functions

- (void)selectHomePostion:(UIButton *)send {
    [self.mapView zoomToHomePoint];
    self.controlsViewRight.locationSelectionView.hidden = YES;
}

- (void)selectAircraftPosition:(UIButton *)send {
    [self.mapView zoomToAircraft];
    self.controlsViewRight.locationSelectionView.hidden = YES;
}


#pragma mark - DJIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView!= nil && buttonIndex > 0 ){
        if(alertView.tag == kAlertViewTagGoHome){
            if(self.goHomeButton.currentState == 0){
                 [self goHomeGroundStation];
            }else{
                 [self stopGoHome];
            }
        } else if(alertView.tag == kAlertViewTagTakeOff){
             [self takeOff];
        }
        else if(alertView.tag == kAlertViewTagLanding){
             [self autoLanding];
        }
        else if(alertView.tag == kAlertViewTagCancelTakeoff){
             [self cancelTakeOff];
        }
        else if(alertView.tag == kAlertViewTagCancelLanding){
             [self cancelLanding];
        }
        
    }
}


#pragma mark -- Flight Limit Zone


- (void) updateAircraftCurrentLocation:(CLLocationCoordinate2D)coordinate withAttiYaw:(double)yaw andPitch:(double)pitch{
    
    [_mapView updateAircraftAnnotation:coordinate withYawDegree:yaw andRollDegree:pitch];
    // Record the latest drone's position and sync it real time.
    _lastAircraftCoordinate = coordinate;
    NSString* coordString = [NSString stringWithFormat:@"%0.6f,%0.6f,%f", _lastAircraftCoordinate.latitude, _lastAircraftCoordinate.longitude, yaw];
    [[NSUserDefaults standardUserDefaults] setObject:coordString forKey:kUserDefaultKeyAircraftLocation];
    [[NSUserDefaults standardUserDefaults] synchronize];

}


#pragma mark - DJIFlightControllerDelegate

- (void)flightController:(DJIFlightController *_Nonnull)fc didUpdateSystemState:(DJIFlightControllerCurrentState *_Nonnull)state{
    // Update the drone's possition
    [self updateAircraftCurrentLocation:state.aircraftLocation withAttiYaw:state.attitude.yaw andPitch:state.attitude.pitch];
    
    
    // Update the home location of the drone.
    [_mapView updateHomeAnnotation:state.homeLocation];
    
    
    // Update the current take off and home button status basing on real drone's status.
    [self updateTakeoffButtonStateWithFlying:state.isFlying withMode:state.flightMode];
    [self updateGohomeButtonStatues:(state.flightMode == DJIFlightControllerFlightModeGoHome )];
}

/**
 *  Callback function that updates the data received from an external device (e.g. the onboard device).
 *  It is only supported for the Matrice 100.
 *
 *  @param fc    Instance of the flight controller for which the data will be updated.
 *  @param data  Data received from an external device. The size of the data will not be larger
 *  than 100 bytes.
 */
- (void)flightController:(DJIFlightController *_Nonnull)fc didReceiveDataFromExternalDevice:(NSData *_Nonnull)data{
    [[ExternalDeviceManager sharedInstance] handleData:data byPassFromFlightControl:fc];
}

@end