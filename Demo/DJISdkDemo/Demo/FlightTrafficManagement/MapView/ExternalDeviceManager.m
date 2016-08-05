//
//  ExternalDeviceManager.m
//  DJISdkDemo
//
//  Created by DJI on 9/3/15.
//  Copyright © 2015 DJI. All rights reserved.
//

#import "ExternalDeviceManager.h"
#import "ExternalICAOAnnotation.h"

#define THREATLABLEWIDTH 180
#define THREATLABLEHEIGHT 40
#define  THREATLABLEFONT  (IS_IPAD ? [UIFont fontWithName:@"Oswald-Bold" size:40] : [UIFont fontWithName:@"Oswald-Bold" size:30])

#define E7  10000000
#define E6  1000000
#define E3  1000
#define E2  100

@implementation TrafficThreatData

@end



@interface ExternalDeviceManager()

@property (nonatomic, retain) NSTimer* autoRefreshTimer;
@property (nonatomic, retain) UILabel* threatNumbLabel;

@end

@implementation ExternalDeviceManager

SINGLETON_GCD(ExternalDeviceManager);




- (id) init {
    self = [super init];
    if (self != nil) {
        // Do nothing so far.
    }
    
    return self;
}

-(void)handleData:(NSData*)data byPassFromFlightControl:(DJIFlightController*)mc{
    if (data != nil) {
        int size = sizeof(MessageToMobile);
        int number = (int) data.length/size;

        for (int i = 0; i < number; i++) {
            MessageToMobile message;
            memcpy(&message, [data bytes]+i*size, size);
            
            _threatData = [[TrafficThreatData alloc] init];
            // Quetion: How to convert the ICAO address to valid string?
            _threatData.ICAO = [NSString stringWithFormat:@"0x%X", message.icao];
            _threatData.latitude = message.lat/(float)E7;
            
            _threatData.longitude = message.lon/(float)E7;
            _threatData.altitude = [NSString stringWithFormat:@"%d m",(int)(message.alt/(float)E3)];
            _threatData.heading = message.heading/(float)E2;
            _threatData.hVelocity = [NSString stringWithFormat:@"%d m/s", (int)(message.velHoriz/(float)E3)];
            _threatData.vVelocity = [NSString stringWithFormat:@"%d m/s", (int)(message.velUp/(float)E3)];
            //_threatData.callsign = [strData subStringBetween:@"SQ:" and:nil];
            _threatData.callsign = @"";
            [self updateExternalDeviceLocation:_threatData];
            [self updateThreatNumbers];
        }
    }
}


/**
 * Refresh the UI element of the ICAO object based on its data
 * if its location is far away than current drone's position, it will not be shown 
 * on the screen.
 */
-(void) updateExternalDeviceLocation:(TrafficThreatData*)pData
{
    ExternalICAOAnnotation* externlICAOAnnotation = [self findExternalICAOannotationBy:pData.ICAO];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(pData.latitude,pData.longitude);
    
    if (CLLocationCoordinate2DIsValid(coordinate)) {

        if (externlICAOAnnotation == nil) {
            externlICAOAnnotation = [ExternalICAOAnnotation annotationWithCoordinate:coordinate heading:pData.heading];
            [self.mapViewClass.mapView addAnnotation:externlICAOAnnotation];
            externlICAOAnnotation.timeInterval = [NSDate timeIntervalSinceReferenceDate];
            externlICAOAnnotation.threatData = pData;
            [self addExternalICAOAnnotation:externlICAOAnnotation by:pData.ICAO];
        }
        else
        {
            //if (!self.isRegionChanging) {
            externlICAOAnnotation.timeInterval = [NSDate timeIntervalSinceReferenceDate];
            [externlICAOAnnotation setCoordinate:coordinate];
            externlICAOAnnotation.threatData = pData;
            [externlICAOAnnotation updateAltitude];
            [externlICAOAnnotation updateAttitudes];
        }
    }
}

- (void) updateThreatNumbers {
    if (_threatNumbLabel == nil) {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        _threatNumbLabel = [[UILabel alloc] initWithFrame:CGRectMake(size.width - THREATLABLEWIDTH, size.height/4, THREATLABLEWIDTH, THREATLABLEHEIGHT)];
        [[[self.mapViewClass.mapView superview] superview] addSubview:_threatNumbLabel];
        _threatNumbLabel.font = THREATLABLEFONT;
        _threatNumbLabel.textColor = [UIColor greenColor];
        _threatNumbLabel.textAlignment = NSTextAlignmentLeft;
    }

    if (_ICAOAnnotations != nil) {
        _threatNumbLabel.text = [NSString stringWithFormat:@"ADS-B: %lu", (unsigned long)[_ICAOAnnotations count]];
    }else {
        _threatNumbLabel.text = [NSString stringWithFormat:@"ADS-B: 0"];
    }
}

- (ExternalICAOAnnotation *)findExternalICAOannotationBy:(NSString*)ICAOName{
    if (_ICAOAnnotations != nil && ICAOName != nil) {
        return [_ICAOAnnotations objectForKey:ICAOName];
    }
    
    return  nil;
}

- (NSString*) ICAOObjectNameFrom:(int8_t*)ICAO and:(int8_t*)callSign {
    NSString* icaoName = [NSString stringWithFormat:@"%hhX%hhX%hhX",(char)ICAO[0], (char)ICAO[1], (char)ICAO[2]];
    NSString* callSignName = [NSString stringWithUTF8String:(char*)callSign];
    
    return [NSString stringWithFormat:@"%@_%@", icaoName, callSignName];
}

- (void) addExternalICAOAnnotation:(ExternalICAOAnnotation*)annotation by:(NSString*)ICAO {
    if (_ICAOAnnotations == nil) {
        _ICAOAnnotations = [[NSMutableDictionary alloc] init];
    }
    
    if ([_ICAOAnnotations count] > 0 && _autoRefreshTimer == nil) {
        _autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(autoRefreshAnnotations) userInfo:nil repeats:YES];
    }
    
    if (annotation != nil && ICAO != nil) {
        annotation.annotationName = ICAO;
        [_ICAOAnnotations setObject:annotation forKey:ICAO];
    }
}


- (void) removeAnnotation:(ExternalICAOAnnotation*) annotation {
    if (_ICAOAnnotations != nil && annotation != nil) {
        [self.mapViewClass.mapView removeAnnotation:annotation];
        [_ICAOAnnotations removeObjectForKey:annotation.annotationName];
    }
    
    if (_ICAOAnnotations == nil || [_ICAOAnnotations count] == 0) {
        [_autoRefreshTimer invalidate];
        _autoRefreshTimer = nil;
    }
}

- (void) autoRefreshAnnotations {
    NSTimeInterval timeDuration = [NSDate timeIntervalSinceReferenceDate];
    for(NSString* annotationkey in [_ICAOAnnotations allKeys]) {
        ExternalICAOAnnotation* annotation = [_ICAOAnnotations objectForKey:annotationkey];
        double diff = timeDuration - annotation.timeInterval;

        if (fabs(diff) > 20) {
            [self removeAnnotation:annotation];
        }
    }
}

- (ExternalICAOAnnotation *)getTapGestureAnnotation:(UIGestureRecognizer *)gestureRecognizer
{
    
    NSArray* array = [_ICAOAnnotations allValues];
    double g_r = 1000;
    
    NSUInteger count = [array count];
    // The tap position of the view
    CGPoint tapInSuperviews = [gestureRecognizer locationInView:self.mapViewClass.mapView.superview];
    
    ExternalICAOAnnotation* selectedAnnotation = nil;
    for (int index = 0;index < count;index++)
    {
        ExternalICAOAnnotation* annotation = [array objectAtIndex:index];
        
        CGPoint currentIndexAnnotationPoint = [self.mapViewClass.mapView convertCoordinate:annotation.coordinate toPointToView:self.mapViewClass.mapView.superview];

        currentIndexAnnotationPoint = CGPointMake(currentIndexAnnotationPoint.x, currentIndexAnnotationPoint.y - 35);
        
        double a = fabs(currentIndexAnnotationPoint.x - tapInSuperviews.x);
        double b = fabs(currentIndexAnnotationPoint.y - tapInSuperviews.y);
        double r = sqrt(a * a + b * b);
        

        if (0 == index)
        {
            g_r = r;
            selectedAnnotation = annotation;
            continue;
        }
        
        if (r < g_r)
        {
            g_r = r;
            selectedAnnotation = annotation;
        }
    }
    
    if (g_r < 60)
    {
        return selectedAnnotation;
    }
    
    return nil;
}



@end