//
//  AppGlobal.h
//
//
//  Copyright (c) 2013 DJI. All rights reserved.
//

#ifndef DJEye_AppGlobal_h
#define DJEye_AppGlobal_h

typedef enum{
    UNIT_IMPERIAL = 0,
    UNIT_METRIC = 1,
}ParameterUnit;

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define weakSelf(__TARGET__) __weak typeof(self) __TARGET__=self
#define weakReturn(__TARGET__) if(__TARGET__==nil)return;


#if __SHOW_BUILD_VERSION__
    #define DJIAPPVersion  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#else
    #define DJIAPPVersion  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#endif

#define     NotificationCenter_Command_OneClickGoHomeAction  @"NotificationCenter_Command_OneClickGoHomeAction"


#define DEGREE(x) ((x)*180.0/M_PI)
#define RADIAN(x) ((x)*M_PI/180.0)
#define BRITISH(x) ((x)*3.2808398950131)


#define SINGLETON_GCD_DEF(classname)    \
+ (classname *)sharedInstance;

/*!
 * @function Singleton GCD Macro
 */
#ifndef SINGLETON_GCD
#define SINGLETON_GCD(classname)                            \
\
+ (classname *)sharedInstance {                          \
\
static dispatch_once_t pred;                            \
static classname * sharedInstance = nil;             \
dispatch_once( &pred, ^{                                \
sharedInstance = [[self alloc] init];            \
});                                                     \
return sharedInstance;                               \
}
#endif

#ifndef SINGLETON_CONTROLLER_GCD
#define SINGLETON_CONTROLLER_GCD(classname, initialMethod)                            \
\
static classname * shareInstance = nil;             \
+ (classname *)sharedInstance {                          \
\
static dispatch_once_t pred;                            \
dispatch_once( &pred, ^{                                \
shareInstance = [[self alloc] init##initialMethod];            \
});                                                     \
return shareInstance;                               \
}
#endif

// function
#define IS_DOUBLE_EQUAL_TO(a, b) (fabs((a) - (b)) < 1E-6)

// Safe releases

#define INVALID_GPS(x)  (x > -0.0000001 && x < 0.0000001)

#if __has_feature(objc_arc)
#define RELEASE_SAFELY(__POINTER) { __POINTER = nil; }
#define INVALIDATE_TIMER(__TIMER) { if( __TIMER !=nil){[__TIMER invalidate], __TIMER = nil;} }
// Release a CoreFoundation object safely.
#define RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { /*CFBrageRelease(__REF);*/ __REF = nil; } }
#else
#define RELEASE_SAFELY(__POINTER) { [__POINTER release], __POINTER = nil; }
#define INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate],[__TIMER release], __TIMER = nil; }
// Release a CoreFoundation object safely.
#define RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }
#endif
// is new main controller

#define DeviceSystemVersion ([[[UIDevice currentDevice] systemVersion] floatValue])
#define iOS9System (DeviceSystemVersion >= 9.0)
#define iOS8System (DeviceSystemVersion >= 8.0)

// annotation view aircraft
#define     aircraft_annotation_view_tag            90001
#define     aircraft_status_annotation_view_tag     90002
#define     aircraft_selected_annotation_view_tag   90003
// annotation view home
#define     home_annotation_view_tag                90004
#define     home_selected_annotation_view_tag       90005

#endif

