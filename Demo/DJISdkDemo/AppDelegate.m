//
//  AppDelegate.m
//  DJISdkDemo
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "AppDelegate.h"
#import "DJIRootViewController.h"
#import <DJISDK/DJISDK.h>

void ShowResult(NSString *format, ...)
{
    va_list argumentList;
    va_start(argumentList, format);
    
    NSString* message = [[NSString alloc] initWithFormat:format arguments:argumentList];
    va_end(argumentList);
    NSString * newMessage = [message hasSuffix:@":(null)"] ? [message stringByReplacingOccurrencesOfString:@":(null)" withString:@" successful!"] : message;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alertViewController = [UIAlertController alertControllerWithTitle:nil message:newMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertViewController addAction:okAction];
        UINavigationController* navController = (UINavigationController*)[[UIApplication sharedApplication] keyWindow].rootViewController;
        [navController presentViewController:alertViewController animated:YES completion:nil];
    });
}

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController* rootViewController = [[UINavigationController alloc] initWithRootViewController:[[DJIRootViewController alloc] initWithNibName:@"DJIRootViewController" bundle:nil]];
    [rootViewController.navigationBar setBackgroundColor:[UIColor blackColor]];
    [rootViewController setToolbarHidden:YES];
    
    self.window.rootViewController = rootViewController;
    
    // Override point for customization after application launch.
    [self customizeAppearance];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) customizeAppearance
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(double)(0x2a)/255 green:(double)(0x3b)/255 blue:(double)(0x55)/255 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)applicationWillTerminate:(UIApplication *)application{
    [DJISDKManager stopConnectionToProduct];
}

@end
