//
//  DJIGSCompassButton.h
//
//
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "UIKit/UIButton.h"


typedef enum : NSUInteger {
    DJIGSCompassLock,
    DJIGSCompassDevice,
    DJIGSCompassAircraft,
} DJIGSCompassType;

@interface DJIGSCompassButton : UIButton

@property (nonatomic, assign) DJIGSCompassType compassType;

@end
