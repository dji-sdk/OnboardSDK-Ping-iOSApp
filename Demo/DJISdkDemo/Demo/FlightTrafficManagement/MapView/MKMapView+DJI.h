//
//  MKMapView+DJI.h
//
//
//  Created by DJI on 15-4-30.
//  Copyright (c) 2015 DJI All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (DJI)

/**
 *  校验式设置地图区域，可避免不合法的经纬度造成的崩溃
 *
 *  @param region   需要设置的原始区域
 *  @param animated 标识是否进行动画
 *  @param handler  经纬度不合法时，进行的特定操作，不需要时，可直接传nil
 */
- (void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated invalidCoordinateHandler:(void (^)(void))handler;

/**
 *  调整地图缩放级别以适应显示所有的标注视图
 *
 *  @param animated 标识是否进行动画
 */
- (void)zoomToFitAnnotationsAnimated:(BOOL)animated;

/**
 *  调整地图缩放级别以适应显示所有的标注视图
 *
 *  @param animated 标识是否进行动画
 *  @param insets   内部边距
 */
- (void)zoomToFitAnnotationsAnimated:(BOOL)animated edgePadding:(UIEdgeInsets)insets;


- (double)determineAltitudeForCoordinateRegion:(MKCoordinateRegion)coordinateRegion  andWithViewport:(CGSize)viewport;

@end
