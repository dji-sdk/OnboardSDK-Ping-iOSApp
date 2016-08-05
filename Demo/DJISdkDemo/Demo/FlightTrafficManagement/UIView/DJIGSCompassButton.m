//
//  DJIGSCompassButton.m
//
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "DJIGSCompassButton.h"

@implementation DJIGSCompassButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    [self setCompassType:DJIGSCompassLock];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setCompassType:(DJIGSCompassType)compassType
{
    _compassType = compassType;
    if (compassType == DJIGSCompassLock) {
        [self setBackgroundImage:[UIImage imageNamed:@"gs_compass_indicator"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"gs_compass_lock"] forState:UIControlStateNormal];
    } else if (compassType == DJIGSCompassDevice) {
        [self setBackgroundImage:[UIImage imageNamed:@"gs_compass_button"] forState:UIControlStateNormal];
        [self setImage:nil forState:UIControlStateNormal];
    } else if (compassType == DJIGSCompassAircraft) {
        [self setBackgroundImage:[UIImage imageNamed:@"gs_compass_air_craft"] forState:UIControlStateNormal];
        [self setImage:nil forState:UIControlStateNormal];
    }
}

@end
