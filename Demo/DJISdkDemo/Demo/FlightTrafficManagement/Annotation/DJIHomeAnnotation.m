//
//  DJIHomeAnnotation.m

//
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "DJIHomeAnnotation.h"
#import "AppGlobal.h"

@implementation DJIHomeAnnotation

- (id) createAnnotationViewFor:(MKMapView *)mapView {
    self.mapView = mapView;
    self.annotationView = [self createAnnotationViewFor:mapView withIdentity:@"GSAnnotationTypeHome" andTag:home_annotation_view_tag];
    return self.annotationView;
}

-(id) init {
    self = [super init];
    
    if (self) {
        self.annotationType = GSAnnotationTypeHome;
    }
    
    return self;
}

- (void) setImageForAnnotationView {
    if (!self.annotationViewBg)
    {
        self.annotationViewBg = [[UIView alloc]init];
        self.annotationViewBg.frame = CGRectMake(0, 0, 1, 1);
    }
    
    [self.annotationImageView removeFromSuperview];
    RELEASE_SAFELY(self.annotationImageView);
    self.annotationImageView = [[UIImageView alloc]init];
    self.annotationImageView.frame = CGRectMake(-14, -40, 27, 40);
    [self.annotationViewBg addSubview:self.annotationImageView];
    
    self.annotationImageView.image = [UIImage imageNamed:@"gs_home_annotation"];
    [self.annotationView addSubview:self.annotationViewBg];
}

@end
