//
//  DJIFlightTMController.h
//
//
//  Copyright (c) 2015 DJI All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "DJIGSCompassButton.h"
#import "DJIStateButton.h"
#import "DJIGSMapView.h"
#import "ExternalDeviceManager.h"
#import "DJIFlightTMRightView.h"

static NSString* DJIDeviceMC = @"MC";

@class DJIMapView;

@interface DJIFlightTMController:UIViewController<CLLocationManagerDelegate,DJIFlightControllerDelegate>{
    CLLocationManager* mLocationManager;
    DJIAircraft* _drone;
    DJIFlightController* _flightController;
}

@property (weak, nonatomic) IBOutlet DJIFlightTMRightView *controlsViewRight;
@property (assign, nonatomic) ParameterUnit unit;
@property (weak, nonatomic) IBOutlet DJIGSMapView *mapView;

@property (weak, nonatomic) IBOutlet DJIStateButton *takeOffButton;
@property (weak, nonatomic) IBOutlet DJIStateButton *goHomeButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegment;

- (id)initWithDefaultNib;
- (void)setCompassType:(DJIGSCompassType)compassType;


@end
