//
//  AppDelegate.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

extern void ShowResult(NSString *format, ...);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
