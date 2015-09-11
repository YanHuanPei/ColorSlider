//
//  DossHUeVIew.m
//  PointDemo
//
//  Created by Divoom on 15/9/10.
//  Copyright (c) 2015年 YHP. All rights reserved.
//

#import "DossHUeVIew.h"

#define kDefaultLineWidth  10.0


@implementation DossHUeVIew

typedef void (^voidBlock)(void);
typedef float (^floatfloatBlock)(float);
typedef UIColor * (^floatColorBlock)(float);


- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineWidth = kDefaultLineWidth;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lineWidth = kDefaultLineWidth;
    }
    return self;
}

-(void) setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}
-(CGPoint) pointForTrapezoidWithAngle:(float)a andRadius:(float)r  forCenter:(CGPoint)p{
    return CGPointMake(p.x + r*cos(a), p.y + r*sin(a));
}



-(void)drawGradientInContext:(CGContextRef)ctx  startingAngle:(float)a endingAngle:(float)b intRadius:(floatfloatBlock)intRadiusBlock outRadius:(floatfloatBlock)outRadiusBlock withGradientBlock:(floatColorBlock)colorBlock withSubdiv:(int)subdivCount withCenter:(CGPoint)center withScale:(float)scale
{
    float angleDelta = (b-a)/subdivCount;
    float fractionDelta = 1.0/subdivCount;
    
    CGPoint p0,p1,p2,p3, p4,p5;
    float currentAngle=a;
    p4=p0 = [self pointForTrapezoidWithAngle:currentAngle andRadius:intRadiusBlock(0) forCenter:center];
    p5=p3 = [self pointForTrapezoidWithAngle:currentAngle andRadius:outRadiusBlock(0) forCenter:center];
    // CGMutablePathRef innerEnveloppe=CGPathCreateMutable();
    //CGMutablePathRef outerEnveloppe=CGPathCreateMutable();
    
    //CGPathMoveToPoint(outerEnveloppe, 0, p3.x, p3.y);
    //CGPathMoveToPoint(innerEnveloppe, 0, p0.x, p0.y);
    CGContextSaveGState(ctx);
    
    CGContextSetLineWidth(ctx, 1);
    
    for (int i=0;i<subdivCount;i++)
    {
        float fraction = (float)i/subdivCount;
        currentAngle=a+fraction*(b-a);
        CGMutablePathRef trapezoid = CGPathCreateMutable();
        
        p1 = [self pointForTrapezoidWithAngle:currentAngle+angleDelta andRadius:intRadiusBlock(fraction+fractionDelta) forCenter:center];
        p2 = [self pointForTrapezoidWithAngle:currentAngle+angleDelta andRadius:outRadiusBlock(fraction+fractionDelta) forCenter:center];
        
        CGPathMoveToPoint(trapezoid, 0, p0.x, p0.y);
        CGPathAddLineToPoint(trapezoid, 0, p1.x, p1.y);
        CGPathAddLineToPoint(trapezoid, 0, p2.x, p2.y);
        CGPathAddLineToPoint(trapezoid, 0, p3.x, p3.y);
        CGPathCloseSubpath(trapezoid);
        
        CGPoint centerofTrapezoid = CGPointMake((p0.x+p1.x+p2.x+p3.x)/4, (p0.y+p1.y+p2.y+p3.y)/4);
        
        CGAffineTransform t = CGAffineTransformMakeTranslation(-centerofTrapezoid.x, -centerofTrapezoid.y);
        CGAffineTransform s = CGAffineTransformMakeScale(scale, scale);
        CGAffineTransform concat = CGAffineTransformConcat(t, CGAffineTransformConcat(s, CGAffineTransformInvert(t)));
        CGPathRef scaledPath = CGPathCreateCopyByTransformingPath(trapezoid, &concat);
        
        CGContextAddPath(ctx, scaledPath);
        CGContextSetFillColorWithColor(ctx,colorBlock(fraction).CGColor);
        CGContextSetStrokeColorWithColor(ctx, colorBlock(fraction).CGColor);
        CGContextSetMiterLimit(ctx, 0);
        
        CGContextDrawPath(ctx, kCGPathFillStroke);
        
        CGPathRelease(trapezoid);
        p0=p1;
        p3=p2;
        
        //CGPathAddLineToPoint(outerEnveloppe, 0, p3.x, p3.y);
        //CGPathAddLineToPoint(innerEnveloppe, 0, p0.x, p0.y);
    }
    //    CGContextSetLineWidth(ctx, 10);
    //    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    //    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    //    //CGContextAddPath(ctx, outerEnveloppe);
    //    CGContextAddPath(ctx, innerEnveloppe);
    //    CGContextMoveToPoint(ctx, p0.x, p0.y);
    //    CGContextAddLineToPoint(ctx, p3.x, p3.y);
    //    CGContextMoveToPoint(ctx, p4.x, p4.y);
    //    CGContextAddLineToPoint(ctx, p5.x, p5.y);
    //   CGContextStrokePath(ctx);
}

-(void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // CGContextClearRect(ctx, rect);
    
    // CGContextStrokePath(ctx);
    //    [[UIColor clearColor] set];
    //    UIRectFill(self.bounds);
    
    CGRect r = self.bounds;
    /*
     r=CGRectInset(r, 20, 20);
     
     if (r.size.width > r.size.height)   {
     r.size.width=r.size.height;
     }else {
     r.size.height=r.size.width;
     }*/
    
    
    
    float l_radius=r.size.width/2.0f-1.0;
    [self drawGradientInContext:ctx  startingAngle:2.0*M_PI endingAngle:0 intRadius:^float(float f) {
        //      return 0*f + radius/2*(1-f);
        //return 200+10*sin(M_PI*2*f*7);
        //       return 50+sqrtf(f)*200;
        return l_radius-self.lineWidth-1.0;
    } outRadius:^float(float f) {
        //         return radius *f + radius/2*(1-f);
        return l_radius;
        //        return 300+10*sin(M_PI*2*f*17);
    } withGradientBlock:^UIColor *(float f) {
        
        return [UIColor colorWithHue:f saturation:1 brightness:1 alpha:1];
        //                float sr=90, sg=54, sb=255;
        //                float er=218, eg=0, eb=255;
        //                return [UIColor colorWithRed:(f*sr+(1-f)*er)/255. green:(f*sg+(1-f)*eg)/255. blue:(f*sb+(1-f)*eb)/255. alpha:1];
        //
    } withSubdiv:256 withCenter:CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r)) withScale:1];
    
}


@end
