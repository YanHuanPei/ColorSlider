//
//  LightView.h
//  HSVColorPicker
//
//  Created by hope on 15/1/10.
//  Copyright (c) 2015年 Nicholas Hart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DossLightView : UIView

@property (nonatomic,copy) UIColor *minColor;
@property (nonatomic,copy) UIColor *maxColor;
@property (nonatomic) int degree;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) BOOL isBgMode;
@end
