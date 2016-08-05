//
//  DJIFlightTMRightView.m

//
//  Created by DJI on 15-4-29.
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "DJIFlightTMRightView.h"
#import "AppGlobal.h"
#import "DJIMapView.h"

@implementation DJIFlightTMRightView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.topMenuView.frame, point) ||
        (self.mapTypeSelectionView.hidden == NO && CGRectContainsPoint(self.mapTypeSelectionView.frame, point)) ||
        (self.locationSelectionView.hidden == NO && CGRectContainsPoint(self.locationSelectionView.frame,point))) {
        return YES;
    } else {
        return NO;
    }
}

- (UIView *)viewInSuperviewForClass:(Class)aClass
{
    UIView *result = nil;
    for (UIView *view in self.superview.subviews) {
        if ([view isKindOfClass:aClass]) {
            result = view;
            break;
        }
    }
    return result;
}

@end
