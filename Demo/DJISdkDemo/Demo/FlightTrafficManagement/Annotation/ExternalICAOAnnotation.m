//
//  ExternalICAOAnnotation.m
//  DJISdkDemo
//
//  Created by dji on 9/3/15.
//  Copyright © 2015 DJI. All rights reserved.
//

#import "ExternalICAOAnnotation.h"
#import "AppGlobal.h"

#define externICAO_annotation_view_tag    1000001
#define fontColor [UIColor greenColor]
#define duration  5
#define  distance_label_font    (IS_IPAD ? [UIFont fontWithName:@"Oswald" size:12.0f] : [UIFont fontWithName:@"Oswald" size:8.0f])


@implementation ExternalICAOAnnotation


- (id) createAnnotationViewFor:(MKMapView *)mapView {
    self.mapView = mapView;
    self.annotationView = [self createAnnotationViewFor:mapView withIdentity:@"ExternalAnnotationTypeAircraft" andTag:externICAO_annotation_view_tag];

    return self.annotationView;
}

/*
 * Add the Drone icon as well as the camera icon,
 */
- (void)setImageForAnnotationView{
    
    // Remove camera view
    if (self.cameraViewBg)
    {
        [self.cameraImageView removeFromSuperview];
         self.cameraImageView = nil;
        [self.cameraViewBg removeFromSuperview];
        self.cameraViewBg = nil;
    }
    
    // Add Drone view
    if (!self.annotationViewBg)
    {
        self.annotationViewBg = [[UIView alloc]init];
        self.annotationViewBg.frame = CGRectMake(0, 0, 1, 1);
    }
    
    if (self.altitude == nil) {
        self.altitude = [[UILabel alloc] initWithFrame:CGRectMake(-25, -30, 75, 30)];
        self.altitude.textColor = fontColor;
        self.altitude.textAlignment = NSTextAlignmentCenter;
        self.altitude.backgroundColor = [UIColor clearColor];
        self.altitude.font = [UIFont fontWithName:@"Oswald" size:14.0f];
        [self.annotationViewBg addSubview:self.altitude];
    }
    
    [self.annotationImageView removeFromSuperview];
    RELEASE_SAFELY(self.annotationImageView);
    self.annotationImageView = [[UIImageView alloc]init];
    //self.annotationImageView.frame = CGRectMake(-75, -75, 150, 150);
    [self.annotationViewBg addSubview:self.annotationImageView];
    UIImage* image = [UIImage imageNamed:@"threat_icon"];
    
    self.annotationImageView.frame = CGRectMake(0, 0, image.size.height, image.size.width);
    self.annotationImageView.image = image;
    
    [self.annotationView addSubview:self.annotationViewBg];
    
    [self updateAltitude];
    [self updateAttitudes];
    
}

- (void) initialDetailView {
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"annotation_detail"]];
    _detailView = [[UIView alloc] initWithFrame:CGRectMake(-58, -50, imageView.bounds.size.width, imageView.bounds.size.height)];
    [_detailView addSubview:imageView];
    
    if (self.detailIcaoName == nil) {
        self.detailIcaoName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
        self.detailIcaoName.textColor = fontColor;
        self.detailIcaoName.font = distance_label_font;
        self.detailIcaoName.textAlignment = NSTextAlignmentCenter;
        [_detailView addSubview:self.detailIcaoName];
    }
    
    if (self.detailAltitude == nil) {
        self.detailAltitude = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 70, 20)];
        self.detailAltitude.textColor = fontColor;
        self.detailAltitude.font = distance_label_font;
        self.detailAltitude.textAlignment = NSTextAlignmentCenter;
        [_detailView addSubview:self.detailAltitude];
    }
    
    if (self.detailVelocity == nil) {
        self.detailVelocity = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, 70, 20)];
        self.detailVelocity.textColor = fontColor;
        self.detailVelocity.font = distance_label_font;
        self.detailVelocity.textAlignment = NSTextAlignmentCenter;
        [_detailView addSubview:self.detailVelocity];
    }

    
    if (self.detailHeading == nil) {
        self.detailHeading = [[UILabel alloc] initWithFrame:CGRectMake(80, 22, 70, 20)];
        self.detailHeading.textColor = fontColor;
        self.detailHeading.font = distance_label_font;
        self.detailHeading.textAlignment = NSTextAlignmentCenter;
        [_detailView addSubview:self.detailHeading];
    }
    
    [self.annotationView addSubview:_detailView];
    [self updateAltitude];
}

- (void) showDetailView {
    NSLog(@"Show Detail View");
    if (_detailView == nil){
        [self initialDetailView];
        return;
    }
    
    if ([_detailView isHidden]) {
        [_detailView setHidden:NO];
    }else {
        [_detailView setHidden:YES];
    }
}

- (void) updateAltitude{
    
    self.altitude.text = [NSString stringWithFormat:@"%@", [self.threatData.altitude stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" 0"]]];
   // self.VVelocity.text = [NSString stringWithFormat:@"Velocity: %@ Heading:%lf",self.threatData.Velocity, self.threatData.Heading];
    
    if (_detailView != nil) {
        self.detailIcaoName.text = [NSString stringWithFormat:@" ICAO: %@", _threatData.ICAO];
        self.detailAltitude.text = [NSString stringWithFormat:@"ALT: %@",self.altitude.text];
        self.detailHeading.text = [NSString stringWithFormat:@"HEAD: %.01f", _threatData.heading];
        self.detailVelocity.text = [NSString stringWithFormat:@"HS:%@, VS:%@",_threatData.hVelocity, _threatData.vVelocity];
    }
}

- (void) updateAttitudes {
    [self.annotationImageView setTransform:CGAffineTransformMakeRotation(self.threatData.heading * M_PI/180)];
}

@end
