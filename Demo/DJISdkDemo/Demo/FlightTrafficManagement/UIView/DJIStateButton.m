//
//  DJIStateButton.m
//  Copyright (c) 2014 All rights reserved.
//

#import "DJIStateButton.h"

@implementation DJIStateButton


- (void)setStateIcons:(NSArray *)array{
    [self setStateIconName:array];
}

- (void)setCurrentState:(NSUInteger)currentState{
    if(_currentState != currentState){
        _currentState = currentState;
        [self setImage:[UIImage imageNamed:_stateIconName[_currentState]] forState:UIControlStateNormal];
    }
}

@end
