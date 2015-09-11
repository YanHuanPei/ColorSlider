//
//  LightView.m
//  HSVColorPicker
//
//  Created by hope on 15/1/10.
//  Copyright (c) 2015年 Nicholas Hart. All rights reserved.
//

#import "DossLightView.h"
#import "UIColor+MCUIColorsUtils.h"
#define kLightBGName0     @"light_bg_light_circyle_0"
#define kLightBGName1     @"light_bg_light_circyle_1"
@interface DossLightView ()
@property (nonatomic) CGFloat angle;
@property (nonatomic,strong) UIImageView *ivBG;
@property (nonatomic) BOOL isLastLight;
-(void) updateBGImage;
@end

@implementation DossLightView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _angle = -90;
        _lineWidth = 6.0;
        
        _minColor = [UIColor colorWithHexRGB:0x7e308d];
        _maxColor = [UIColor colorWithHexRGB:0x9d9d9e];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _angle = -90;
        _lineWidth = 6.0;
        _minColor = [UIColor whiteColor];
        _maxColor = [UIColor colorWithHexRGB:0x9d9d9e];
    }
    return self;
}

-(void) setIsBgMode:(BOOL)isBgMode {
    _isBgMode = isBgMode;
    if (isBgMode) {
        self.ivBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kLightBGName0]];
        [self updateBGImage];
        [self addSubview:self.ivBG];
    }else {
        if (self.ivBG) {
            [self.ivBG removeFromSuperview];
            self.ivBG = nil;
        }
    }
}

-(void) updateBGImage {
    if (self.angle != -90 ) {
        if (!self.isLastLight) {
            [self.ivBG setImage:[UIImage imageNamed:kLightBGName1]];
            self.isLastLight = YES;
        }
    }else {
        if (self.isLastLight) {
            [self.ivBG setImage:[UIImage imageNamed:kLightBGName0]];
            self.isLastLight = NO;
        }
    }
}
-(void) setDegree:(int)degree {
    
    //_degree = degree;
    self.angle = degree-90;
    
    if (self.isBgMode) {
        [self updateBGImage];
    }else {
        [self setNeedsDisplay];
    }
    
}
//-(void) setLightValue:(CGFloat)lightValue {
//    if (lightValue < 0) {
//        _lightValue = 0;
//    }else if (lightValue > 1) {
//        _lightValue = 1.0;
//    }else {
//        _lightValue = lightValue;
//    }
//    self.angle = 360 *_lightValue-90;
//    [self setNeedsDisplay];
//}

-(void) drawRect:(CGRect)rect {
    if (self.isBgMode) {
        return;
    }
    CGRect r = CGRectInset(rect, 3.0, 3.0);
    CGRect oval2Rect = r;
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: oval2Rect];
    [self.maxColor setStroke];
    oval2Path.lineWidth = self.lineWidth;
    [oval2Path stroke];
    
    
    //// Oval Drawing
    CGRect ovalRect = r;
    UIBezierPath* ovalPath = UIBezierPath.bezierPath;
    [ovalPath addArcWithCenter: CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect)) radius: CGRectGetWidth(ovalRect) / 2 startAngle: -90 * M_PI/180 endAngle: _angle * M_PI/180 clockwise: YES];
    
    [self.minColor setStroke];
    ovalPath.lineWidth = self.lineWidth;
    [ovalPath stroke];
    
}
@end
