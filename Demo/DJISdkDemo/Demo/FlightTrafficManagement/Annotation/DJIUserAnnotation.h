//
//  DJIUserAnnotation.h
//
//
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "DJIAnnotation.h"

@interface DJIUserAnnotation : DJIAnnotation

@property (nonatomic, assign) CGFloat heading;

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate heading:(CGFloat)heading;


@end
