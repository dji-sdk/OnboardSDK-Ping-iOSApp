//
//  DJIUserLocationView.h
//
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "DJIBaseView.h"

@interface DJIUserLocationView : DJIBaseView
@property (strong, nonatomic) IBOutlet DJIBaseView *view;

@property (weak, nonatomic) IBOutlet UIView *directionView;
@property (weak, nonatomic) IBOutlet UIImageView *directionImageView;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;

- (void)directionViewRotateWithRads:(float)rads;
- (void)directionViewRotateWithAngle:(float)angle;
- (void)setValidate:(BOOL)validate;
@end
