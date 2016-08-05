//
//  DJIFlightTMRightView.h

//
//  Created by DJI on 15-4-29.
//  Copyright (c) 2015 DJI All rights reserved.
//

#import "DJIBaseView.h"

@interface DJIFlightTMRightView : DJIBaseView

@property (weak, nonatomic) IBOutlet UIView *topMenuView;
@property (weak, nonatomic) IBOutlet UIButton *mapTypeSelectionButton;

/**
 *  Subviews of the map type selection view
 */
@property (weak, nonatomic) IBOutlet UIView *mapTypeSelectionView;
@property (weak, nonatomic) IBOutlet UIView *locationSelectionView;
@property (weak, nonatomic) IBOutlet UIButton *standardMapTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *satelliteMapTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *hybirdMapTypeButton;



// Only iphone features
@property (weak, nonatomic) IBOutlet UIButton *locationSelectionButton;
@property (weak, nonatomic) IBOutlet UIButton *homePositionButton;
@property (weak, nonatomic) IBOutlet UIButton *aircraftPositionButton;

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
/**
 *  compass type button
 */
@property (weak, nonatomic) IBOutlet UIButton *compassButton;

@end
