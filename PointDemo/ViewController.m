//
//  ViewController.m
//  PointDemo
//
//  Created by Divoom on 15/9/10.
//  Copyright (c) 2015年 YHP. All rights reserved.
//

#import "ViewController.h"
#import "DossColorPicker.h"
#import "UIView+Utils.h"
@interface ViewController ()
@property (nonatomic, strong) DossColorPicker *colorPicker;
@property (nonatomic,assign) CGFloat fLightStatus;
@property (nonatomic,strong) UIButton *btnSwitch;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.colorPicker = [[DossColorPicker alloc] initWithFrame:CGRectMake(50, 50, 280, 280)];
    //self.colorPicker.translatesAutoresizingMaskIntoConstraints = NO;
    self.colorPicker.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.colorPicker];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
