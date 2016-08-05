//
//  DJIAnnotation.h
//
//  Define all kinds of annotations used in DJIMapView.
//  1. Provide a common method to generate the view for the annotaion.
//  Created by DJI on 15-5-10.
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "DJIAnnotation.h"
#import "AppGlobal.h"

@interface DJIAnnotation ()

@end

@implementation DJIAnnotation


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.annotationType = GSAnnotationCommon;
    }
    return self;
}

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    DJIAnnotation *annotation = [[self alloc] init];
    annotation.coordinate = coordinate;
    return annotation;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [self init];
    self.coordinate = coordinate;
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        _coordinate = coordinate;
    }
}


- (GSAnnotationType) annotationType{

    return _annotationType;
}

-(void) setAnnotationView:(MKAnnotationView *)annotationView {
    _annotationView = annotationView;
}


- (id) createAnnotationViewFor:(MKMapView *) mapView{
    _mapView = mapView;
    _annotationView = nil;
    return _annotationView;
}

- (id) createAnnotationViewFor:(MKMapView *)mapView withIdentity:(NSString *)identifier andTag:(NSInteger)tag {

    _annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (nil == _annotationView)
    {
        _annotationView = [[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:identifier];
    }
    else {
        _annotationView.annotation = self;
    }
    
    _annotationView.tag = tag;
    _annotationView.draggable = NO;
    _annotationView.enabled = NO;
    
    return _annotationView;
}


#pragma mark - Calculation methods between annoations.
- (double)getDistanceToAnnotation:(DJIAnnotation *)dest_annotation
{
    BOOL is_zero_1 = IS_DOUBLE_EQUAL_TO(self.coordinate.latitude, 0);
    BOOL is_zero_2 = IS_DOUBLE_EQUAL_TO(self.coordinate.longitude, 0);
    
    BOOL is_zero_3 = IS_DOUBLE_EQUAL_TO(dest_annotation.coordinate.latitude, 0);
    BOOL is_zero_4 = IS_DOUBLE_EQUAL_TO(dest_annotation.coordinate.longitude, 0);
    
    if (!dest_annotation || (is_zero_1 && is_zero_2) || (is_zero_3 && is_zero_4))
    {
        return 0.0;
    }
    
    CLLocation* a_1 = [[CLLocation alloc]initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    CLLocation* a_2 = [[CLLocation alloc]initWithLatitude:dest_annotation.coordinate.latitude longitude:dest_annotation.coordinate.longitude];
    double d = [a_1 distanceFromLocation:a_2];
    RELEASE_SAFELY(a_1);
    RELEASE_SAFELY(a_2);
    return d;
}

#pragma mark - Setter

- (void)setAnnotationViewBg:(UIView *)annotationViewBg
{
    [_annotationViewBg removeFromSuperview];
    RELEASE_SAFELY(_annotationViewBg);
    _annotationViewBg = annotationViewBg ;
}


- (void) setImageForAnnotationView {
    // Abstact method do nothing here.
}
@end
