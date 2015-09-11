//
//  DossColorPicker.h
//  PointDemo
//
//  Created by Divoom on 15/9/10.
//  Copyright (c) 2015年 YHP. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    WheelClockWise,
    WheelCounterclockwise,
} WheelType;

@protocol DossColorPickerDelegate;
@interface DossColorPicker : UIView <UIGestureRecognizerDelegate>

@property (nonatomic) CGFloat colorHue;
@property (nonatomic) CGFloat colorBrightness;
@property (nonatomic) BOOL switchState;

@property (nonatomic,strong) UIColor *color;


@property (nonatomic) id<DossColorPickerDelegate> delegate;
@property (nonatomic) BOOL isLightTracking;


@end


@protocol DossColorPickerDelegate <NSObject>
- (void)colorPicker:(DossColorPicker*)colorPicker light:(CGFloat) light;
- (void)colorPicker:(DossColorPicker*)colorPicker changedColor:(UIColor*)color;
- (void)colorPicker:(DossColorPicker *)colorPicker button:(UIButton *)button;

- (void)colorPicker:(DossColorPicker*)colorPicker wheelType:(WheelType) wheel light:(CGFloat) light;
- (void)colorPicker:(DossColorPicker*)colorPicker wheelType:(WheelType) wheel light:(CGFloat) light isEnd:(BOOL) isEnd;

@end
