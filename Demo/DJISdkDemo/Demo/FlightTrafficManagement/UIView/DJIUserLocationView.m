//
//  DJIUserLocationView.m
//
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "DJIUserLocationView.h"
#import "AppGlobal.h"

@implementation DJIUserLocationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)directionViewRotateWithAngle:(float)angle
{
    double rads = RADIAN(angle);
    [self directionViewRotateWithRads:rads];
}

- (void)directionViewRotateWithRads:(float)rads
{
    self.directionView.layer.transform = CATransform3DIdentity;
    self.directionView.layer.transform = CATransform3DMakeRotation(rads, 0, 0, 1);
}


- (void)setValidate:(BOOL)validate
{
    if (validate) {
        self.locationImageView.image = [UIImage imageNamed:@"gs_user_annotation_Image"];
    } else {
        self.locationImageView.image = [UIImage imageNamed:@"gs_user_annotation_Image_invalidate"];
    }
}
@end
