//
//  DJIStateButton.h
//
//  Copyright (c) 2015 DJI All rights reserved.
//

#import <UIKit/UIButton.h>

@interface DJIStateButton : UIButton

@property (strong, nonatomic) NSArray *stateIconName;

@property (assign, nonatomic) NSUInteger currentState;

/**
 *  设置不同状态下的icon
 *
 *  @param array icon的名称
 */
- (void)setStateIcons:(NSArray *)array;

@end
