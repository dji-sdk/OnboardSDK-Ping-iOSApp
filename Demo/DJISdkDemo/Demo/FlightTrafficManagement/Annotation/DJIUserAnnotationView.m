//
//  DJIUserAnnotationView.m
//
//
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "DJIUserAnnotationView.h"

@implementation MKUserLocation (locationView)

- (void) setAnnotationView:(MKAnnotationView *)view {
    NSLog(@"This is a test");
}

@end


@implementation DJIUserAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (nil != self) {
    
        self.draggable = NO;
        self.userLocationView = [[DJIUserLocationView alloc] initWithDefaultNib];
        
        CGRect frame = self.frame;
        frame.size = self.userLocationView.frame.size;
        self.frame = frame;
        
        [self addSubview:self.userLocationView];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
