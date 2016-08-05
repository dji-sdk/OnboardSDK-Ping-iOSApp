//
//  DJIBaseView.m
//
//  Copyright (c) 2014 DJI. All rights reserved.
//

#import "DJIBaseView.h"
#import "AppGlobal.h"
//#import "NSString"

@implementation DJIBaseView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib{
   
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    

        if (self) {
            NSString *nibNameOrNil = nil;
            if(IS_IPAD){
                nibNameOrNil = [NSString stringWithFormat:@"%@_iPad",NSStringFromClass([self class])];
            }else {
                nibNameOrNil = [NSString stringWithFormat:@"%@_iPhone6+",NSStringFromClass([self class])];
            } 
        
        if([[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@"nib"] == nil){
            nibNameOrNil = NSStringFromClass([self class]);
        }
        
        if ([[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@"nib"] == nil) {
            nibNameOrNil = [NSString stringWithFormat:@"%@_iPhone5",NSStringFromClass([self class])];
        }
        
        if ([[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@"nib"] == nil) {
            nibNameOrNil = [NSString stringWithFormat:@"%@_iPhone6",NSStringFromClass([self class])];
        }

        if ([[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@"nib"] == nil) {
            nibNameOrNil = [NSString stringWithFormat:@"%@_iPhone6+",NSStringFromClass([self class])];
        }
        
        if([[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@"nib"] !=nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibNameOrNil owner:self options:nil];
            UIView *view = (UIView *)[nib objectAtIndex:0];
            [self setBackgroundColor:[UIColor clearColor]];
            [self addSubview:view];
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        }
        else{
        }
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
    }
    return self;
}

- (id)initWithDefaultNib{
    NSString *nibNameOrNil = nil;
    if(IS_IPAD){
        nibNameOrNil = [NSString stringWithFormat:@"%@_iPad",NSStringFromClass([self class])];
    }else {
        nibNameOrNil = [NSString stringWithFormat:@"%@_iPhone6+",NSStringFromClass([self class])];
    } 
    
    if([[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@"nib"] == nil){
        nibNameOrNil = NSStringFromClass([self class]);
    }
    if ([[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@"nib"] == nil) {
        nibNameOrNil = [NSString stringWithFormat:@"%@_iPhone6",NSStringFromClass([self class])];
    }
    if ([[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@"nib"] == nil) {
        nibNameOrNil = [NSString stringWithFormat:@"%@_iPhone5",NSStringFromClass([self class])];
    }
    if([[NSBundle mainBundle] pathForResource:nibNameOrNil ofType:@"nib"] == nil){
        self = [self initWithFrame:CGRectZero];
    }
    else{
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibNameOrNil owner:self options:nil];
        self = [self initWithFrame:((UIView *)[nib objectAtIndex:0]).frame];
        if(self !=nil){
            [self addSubview:[nib objectAtIndex:0]];
        }
    }
    return self;
}


@end
