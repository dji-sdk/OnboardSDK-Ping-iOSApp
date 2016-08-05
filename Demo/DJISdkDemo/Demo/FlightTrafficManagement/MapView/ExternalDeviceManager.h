//
//  ExternalDeviceManager.h
//  DJISdkDemo
//
//  Created by dji on 9/3/15.
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJISDK.h>
#import "AppGlobal.h"
#import "DJIGSMapView.h"

#define externalDeviceManager  [ExternalDeviceManager sharedInstance]

@class ExternalICAOAnnotation;

#pragma pack(1)
/**
 * Refined to the struct from string data coming from Ping device.
 */
typedef struct
{
    uint32_t icao;                //ICAO address
    int32_t  lat;                 //Latitude, expressed as degrees * 1E7
    int32_t  lon;                 //Longitude, expressed as degrees * 1E7
    int32_t  alt;                 //Altitude(ASL) in millimeters (*1E6)
    uint32_t velHoriz;            //The horizontal velocity in millimeters/second
    int32_t  velUp;               //The vertical velocity in millimeters/second, positive is up
    uint32_t distanceToMe;        //in Meters
    uint16_t heading;             //Course over ground in degree's * 100
    uint8_t  age;                 //Time in 0.1s since last update from ping
} MessageToMobile;

#pragma pack()

@interface TrafficThreatData:NSObject
    @property (nonatomic, assign) int16_t packageIndex;
    @property (nonatomic, assign) int16_t threatNumber;
    @property (nonatomic, retain) NSString* ICAO;
    @property (nonatomic, assign) CGFloat  latitude;
    @property (nonatomic, assign) CGFloat  longitude;
    @property (nonatomic, assign) CGFloat  heading;
    @property (nonatomic, retain) NSString*  vVelocity;
    @property (nonatomic, retain) NSString*  hVelocity;
    @property (nonatomic, retain) NSString*  altitude;
    @property (nonatomic, retain) NSString*  callsign;
@end

@interface ExternalDeviceManager : NSObject

@property(nonatomic, assign) DJIGSMapView* mapViewClass;
@property(nonatomic, retain) TrafficThreatData* threatData;
@property (strong,nonatomic) NSMutableDictionary *ICAOAnnotations;

SINGLETON_GCD_DEF(ExternalDeviceManager);

-(void)handleData:(NSData*)data byPassFromFlightControl:(DJIFlightController*)mc;
- (ExternalICAOAnnotation*)getTapGestureAnnotation:(UIGestureRecognizer *)gestureRecognizer;

@end
