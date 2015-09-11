//
//  DossColorPicker.m
//  PointDemo
//
//  Created by Divoom on 15/9/10.
//  Copyright (c) 2015年 YHP. All rights reserved.
//

#import "DossColorPicker.h"
#import "DossHueView.h"

#import "DossLightView.h"
#import "EFCircularTrig.h"
#import "UIView+Utils.h"
#import "UIColor+MCUIColorsUtils.h"
#define kHueViewRadius     127.0f
#define kHueViewLineWidth  50.0f
#define kColorThumbRadius  138.0f
#define kLightViewRadius   70.0f
#define kLightViewLineWidth 3.0f

#define kSppLampMinValue    1.0f
#define kSppLampMaxValue    210.0f
#define kLightThumbImage     @"light_mask_light_2"
#define kColorThumbImage     @"light_mask_light"
#define kSwitchImage         @"light_switch_on"
#define kSwitchEdImage         @"light_switch"
@interface MarkerLayer : CALayer
@end

@implementation MarkerLayer
- (void)drawInContext:(CGContextRef)context
{
    float const thickness = 1.0f;
    //    CGContextSetLineWidth(context, thickness);
    //    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHexRGB:0xf2f2f2].CGColor);
    //    CGContextAddEllipseInRect(context, CGRectInset(self.bounds, thickness, thickness));
    //    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(context, CGRectInset(self.bounds, thickness, thickness));
    
}

@end


@interface DossColorPicker ()

@property (nonatomic,strong) DossHUeVIew *hueView;
@property (nonatomic,strong) UIImageView *lightThumb;
@property (nonatomic,strong) DossLightView *lightView;
@property (nonatomic,strong) UIView *viewHueMarker;
@property (nonatomic,strong) UIButton *btnSwitch;
@property (nonatomic) int lightAngleFromNorth;
@property (nonatomic) int colorAngleFromNorth;
@property (nonatomic) int lastLightAngleFromNorth;
@property (nonatomic) CGFloat radius;
@property (nonatomic) CGPoint viewCenter;
@property (nonatomic,strong) UILongPressGestureRecognizer  * hueGestureRecognizer;
@property (nonatomic,strong) UILongPressGestureRecognizer *saturationBrightnessGestureRecognizer;

-(void) configure;
-(CGRect) makeHueViewRect;
-(CGRect) makeColorThumbRect;
-(CGRect) makeLightThumbRect;
-(CGRect) makeLightViewRect;
-(CGRect) makeSwitchRect;
-(CGRect) hueMarkerRect;
//-(void) refershSwitch;
@end

@implementation DossColorPicker

-(void) awakeFromNib {
    [self configure];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configure];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}



-(void) configure {
    _radius = 150.0;
    self.viewCenter = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    self.hueView = [[DossHUeVIew alloc] initWithFrame:[self makeHueViewRect]];
    self.hueView.backgroundColor = [UIColor clearColor];
    self.hueView.lineWidth = kHueViewLineWidth;
    [self addSubview:self.hueView];
    
    
    self.viewHueMarker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16.0, 16.0)];
    self.viewHueMarker.backgroundColor = [UIColor whiteColor];
    self.viewHueMarker.layer.cornerRadius = self.viewHueMarker.width/2.0;
    [self addSubview:self.viewHueMarker];

    self.lightView = [[DossLightView alloc] initWithFrame:[self makeLightViewRect]];
    self.lightView.lineWidth = kLightViewLineWidth;
    self.lightView.backgroundColor = [UIColor clearColor];
    self.lightView.minColor = [UIColor whiteColor];
    self.lightView.maxColor  = [UIColor colorWithHexRGB:0x7f7f7f];
    self.lightView.isBgMode = YES;
    [self addSubview:self.lightView];
    
    
    self.lightThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kLightThumbImage]];
    self.lightThumb.userInteractionEnabled = YES;
    [self addSubview:self.lightThumb];

    self.btnSwitch = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnSwitch setImage:[UIImage imageNamed:kSwitchImage] forState:UIControlStateNormal];
    [self.btnSwitch setImage:[UIImage imageNamed:kSwitchEdImage] forState:UIControlStateSelected];
    [self.btnSwitch sizeToFit];
    [self.btnSwitch addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btnSwitch];
    
    self.hueGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragHue:)];
    self.hueGestureRecognizer.allowableMovement = FLT_MAX;
    self.hueGestureRecognizer.minimumPressDuration = 0.0f;
    self.hueGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.hueGestureRecognizer];
    
    self.saturationBrightnessGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragSaturationBrightness:)];
    self.saturationBrightnessGestureRecognizer.allowableMovement = FLT_MAX;
    self.saturationBrightnessGestureRecognizer.minimumPressDuration = 0.0;
    self.saturationBrightnessGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.saturationBrightnessGestureRecognizer];
    
}

-(void) layoutSubviews {
    float const resolution = MIN(self.bounds.size.width, self.bounds.size.height);
    
    self.radius = resolution / 2.0f;
    //self.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
    self.viewCenter = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    self.hueView.frame = [self makeHueViewRect];
    self.lightThumb.frame = [self makeLightThumbRect];
    self.lightView.frame = [self makeLightViewRect];
    self.btnSwitch.frame = [self makeSwitchRect];
    self.viewHueMarker.frame = [self hueMarkerRect];
}

#pragma mark - Properties
- (void)setSwitchState:(BOOL)switchState {
    if (_switchState !=switchState) {
        _switchState = switchState;
    }
    self.btnSwitch.selected = _switchState;
}

//- (void)setColor:(UIColor *)aColor {
//    if ([aColor getHue:&_colorHue saturation:NULL brightness:NULL alpha:NULL] == NO) {
//        self.colorHue = 0.0f;
//    }
// 
//    CGFloat radians = self.colorHue * 2.0f * M_PI;
//    CGPoint const position = CGPointMake(cos(radians) * kColorThumbRadius, -sin(radians) * (kColorThumbRadius));
//    
//    const CGPoint fromPoint = CGPointMake(0, 0);
//    
//    int degree = floor([EFCircularTrig angleRelativeToNorthFromPoint:fromPoint
//                                                             toPoint:position]);
//    NSLog(@"degree == %d",degree);
//    self.colorAngleFromNorth = degree;
//    self.viewHueMarker.frame = [self hueMarkerRect];
//
//
//}


- (void)setColorBrightness:(CGFloat)colorBrightness {
    
    if (colorBrightness >=0 && colorBrightness <= 1.0) {
        _colorBrightness = colorBrightness;
        int degree = floor(_colorBrightness * 360.0);
        NSLog(@"now:%d old:%d",degree,self.lightAngleFromNorth);
        self.lightAngleFromNorth = degree;
        self.lightView.degree = degree;
   
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        
        self.lightThumb.frame = [self makeLightThumbRect];
        [CATransaction commit];
        
        
        
    }
    

    
    
}
- (UIColor*)color
{
    return [UIColor colorWithHue:self.colorHue saturation:1.0   brightness:1.0 alpha:1.0];
}

- (CGRect)hueMarkerRect
{
    CGFloat const radians = self.colorHue * 2.0f * M_PI;
    CGPoint const position = CGPointMake(cos(radians) * (kHueViewRadius -2 - kHueViewLineWidth / 2.0f), -sin(radians) * (kHueViewRadius -2 - kHueViewLineWidth / 2.0f));
    //    CGFloat const width = kHueViewLineWidth*0.5;
    //    return CGRectMake(position.x - width / 2.0f + self.bounds.size.width / 2.0f, position.y - width / 2.0f+ self.bounds.size.height / 2.0f, width, width);
    
    CGFloat const width = self.viewHueMarker.width;
    return CGRectMake(position.x - width / 2.0f + self.bounds.size.width / 2.0f, position.y - width / 2.0f+ self.bounds.size.height / 2.0f, width, width);
}

-(CGRect) makeSwitchRect {
    return CGRectMake(self.radius-self.btnSwitch.width/2.0, self.viewCenter.y-self.btnSwitch.height/2.0, self.btnSwitch.width, self.btnSwitch.height);
}
-(CGRect) makeHueViewRect {
    
    return CGRectMake(self.radius-kHueViewRadius,self.radius-kHueViewRadius , kHueViewRadius*2.0, kHueViewRadius*2.0);
}
-(CGRect) makeColorThumbRect{
    return CGRectMake(self.radius-kColorThumbRadius,self.radius-kColorThumbRadius , kColorThumbRadius*2.0, kColorThumbRadius*2.0);
}
-(CGRect) makeLightThumbRect {
    
    UIImage*   const backgroundImage = [UIImage imageNamed:kLightThumbImage];
    
    CGFloat const nativeWidth = CGImageGetWidth(backgroundImage.CGImage)/backgroundImage.scale;
    CGFloat const nativeHeight = CGImageGetHeight(backgroundImage.CGImage)/backgroundImage.scale;
    
    
    CGPoint handleCenter = [self pointOnCircleAtAngleFromNorth:self.lightAngleFromNorth];
    
    return CGRectMake(handleCenter.x-nativeWidth/2.0,handleCenter.y-nativeHeight/2.0, nativeWidth, nativeHeight);
    
    
    
    
}
-(CGRect) makeLightViewRect {
    return CGRectMake(self.radius-kLightViewRadius,self.radius-kLightViewRadius , kLightViewRadius*2, kLightViewRadius*2);
}

-(CGPoint)pointOnCircleAtAngleFromNorth:(int)angleFromNorth
{
    CGPoint offset = [EFCircularTrig  pointOnRadius:kLightViewRadius-8.0 atAngleFromNorth:angleFromNorth];
    return CGPointMake(self.viewCenter.x + offset.x, self.viewCenter.y + offset.y);
}


#pragma mark - Touch handling

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( gestureRecognizer == self.hueGestureRecognizer )
    {
        // Check if the touch started inside the circle.
        CGPoint const position = [gestureRecognizer locationInView:self];
        CGFloat const distanceSquared = (self.viewCenter.x - position.x) * (self.viewCenter.x - position.x) + (self.viewCenter.y - position.y) * (self.viewCenter.y - position.y);
        //return ( (self.radius - (kHueViewRadius-kHueViewLineWidth)) * (self.radius - (kHueViewRadius-kHueViewLineWidth)) < distanceSquared ) && ( distanceSquared <= self.radius * self.radius );

        CGFloat const maxdistanceSquared = (self.radius) * (self.radius);
        CGFloat const mindistanceSquared = (kHueViewRadius - kHueViewLineWidth) * (kHueViewRadius - kHueViewLineWidth);
        //NSLog(@"%f-%f-%f",distanceSquared, mindistanceSquared, maxdistanceSquared);
        return ( mindistanceSquared < distanceSquared ) && ( distanceSquared <= maxdistanceSquared);
        
    }
    else if ( gestureRecognizer == self.saturationBrightnessGestureRecognizer )
    {
        CGPoint const position = [gestureRecognizer locationInView:self];
        CGFloat const distanceSquared = (self.viewCenter.x - position.x) * (self.viewCenter.x - position.x) + (self.viewCenter.y - position.y) * (self.viewCenter.y - position.y);
        
        CGFloat const maxdistanceSquared = (kHueViewRadius - kHueViewLineWidth) * (kHueViewRadius - kHueViewLineWidth);
        CGFloat const mindistanceSquared = (kLightViewRadius - 30.0) * (kLightViewRadius - 30.0);
        //NSLog(@"%f-%f-%f",distanceSquared, mindistanceSquared, maxdistanceSquared);
        return ( mindistanceSquared < distanceSquared ) && ( distanceSquared <= maxdistanceSquared);
    }
    return YES;
}

- (void)handleDragHue:(UIGestureRecognizer *)gestureRecognizer
{
    if ( (gestureRecognizer.state == UIGestureRecognizerStateBegan) || (gestureRecognizer.state == UIGestureRecognizerStateChanged) )
    {
        CGPoint const position = [gestureRecognizer locationInView:self];
        
        int degree = floor([EFCircularTrig angleRelativeToNorthFromPoint:self.viewCenter
                                                                 toPoint:position]);
        
        self.colorAngleFromNorth = degree;
        //self.colorThumb.degress = self.colorAngleFromNorth;
        
        
        CGFloat const distanceSquared = (self.viewCenter.x - position.x) * (self.viewCenter.x - position.x) + (self.viewCenter.y - position.y) * (self.viewCenter.y - position.y);
        if ( distanceSquared < 1.0e-3f )
        {
            return;
        }
        
        CGFloat  radians = atan2(self.viewCenter.y - position.y, position.x - self.viewCenter.x);
        CGFloat colorHue = radians / (2.0f * M_PI);
        if ( colorHue < 0.0f )
        {
            colorHue += 1.0f;
        }
        
        self.colorHue = colorHue;
        
        
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        //self.layerHueMarker.frame = [self hueMarkerRect];
        self.viewHueMarker.frame = [self hueMarkerRect];
        [CATransaction commit];
        
         NSLog(@"colorHue=====%f",colorHue);
        if ( [self.delegate respondsToSelector:@selector(colorPicker:changedColor:)] )
        {
            [self.delegate colorPicker:self changedColor:self.color];
        }
    }
}

- (void)handleDragSaturationBrightness:(UIGestureRecognizer *)gestureRecognizer
{
    if ((gestureRecognizer.state == UIGestureRecognizerStateBegan)) {
        
        CGPoint const position = [gestureRecognizer locationInView:self];
        
        self.lastLightAngleFromNorth = floor([EFCircularTrig angleRelativeToNorthFromPoint:self.viewCenter
                                                                                   toPoint:position]);
        self.isLightTracking = YES;
        
        
    }else if (gestureRecognizer.state == UIGestureRecognizerStateChanged || gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint const position = [gestureRecognizer locationInView:self];
        
        int degree = floor([EFCircularTrig angleRelativeToNorthFromPoint:self.viewCenter
                                                                 toPoint:position]);
        
        float preDegrees = self.lastLightAngleFromNorth;
        float curDegrees = degree;
        float offset;
        float offset1;
        float offset2;
        
        if (preDegrees > curDegrees) {
            offset = preDegrees - curDegrees;
        } else {
            offset = curDegrees - preDegrees;
        }
        offset1 = 360.0f - offset;
        offset2 = offset1;
        if (offset1 > offset) {
            offset2 = offset;
        }
        
        
        float newProgress = (kSppLampMaxValue-kSppLampMinValue) * (offset2 / 360.0f);
        if (newProgress >= 1) {
            BOOL isEnd = NO;
            if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
                isEnd = YES;
            }
            
            if (offset > 180) {
                if (curDegrees < 180) {
                    [self.delegate colorPicker:self wheelType:WheelClockWise light:newProgress isEnd:isEnd];
                } else {
                    [self.delegate colorPicker:self wheelType:WheelCounterclockwise light:newProgress isEnd:isEnd];
                }
            } else if (preDegrees < curDegrees) {
                [self.delegate colorPicker:self wheelType:WheelClockWise light:newProgress isEnd:isEnd];
            } else {
                [self.delegate colorPicker:self wheelType:WheelCounterclockwise light:newProgress isEnd:isEnd];
            }
            
//            setProgressAndUpdata(Math.round(curProgress), false);
//            self.lastAngle = curDegrees;
            self.lastLightAngleFromNorth = curDegrees;
            self.lightThumb.frame = [self makeLightThumbRect];

            NSLog(@"curDegrees%f",curDegrees);
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            self.isLightTracking = NO;
        }
    }
    
    /*
     
     if ( (gestureRecognizer.state == UIGestureRecognizerStateBegan) || (gestureRecognizer.state == UIGestureRecognizerStateChanged) )
     {
     CGPoint const position = [gestureRecognizer locationInView:self];
     
     int degree = floor([EFCircularTrig angleRelativeToNorthFromPoint:self.viewCenter
     toPoint:position]);
     
     
     self.lightAngleFromNorth = degree;
     self.lightView.degree = degree;
     
     
     
     self.colorBrightness = degree /360.0f;
     
     
     [CATransaction begin];
     [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
     // self.ivLightnessPoint.frame = [self lightPointRect];
     
     self.lightThumb.frame = [self makeLightThumbRect];
     [CATransaction commit];
     
     
     if ( [self.delegate respondsToSelector:@selector(colorPicker:light:)] )
     {
     [self.delegate colorPicker:self light:self.colorBrightness];
     }
     }
     */
    
}


- (void)buttonAction:(id)sender
{
    
}

@end
