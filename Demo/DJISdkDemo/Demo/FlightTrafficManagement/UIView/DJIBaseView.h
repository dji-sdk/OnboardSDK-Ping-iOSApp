//
//  DJIBaseView.h
//
//  Copyright (c) 2015 DJI All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* DJIDeviceWillRotateNotificationName = @"DJIDeviceWillRotateNotificationName";


@interface DJIBaseView : UIView

@property (assign, nonatomic) BOOL isMovable;

- (id)initWithDefaultNib;
@end
