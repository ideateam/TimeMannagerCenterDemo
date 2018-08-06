//
//  CircleView.m
//  YKL
//
//  Created by Apple on 15/12/7.
//  Copyright © 2015年 Apple. All rights reserved.
//

#import "XLCircleProgress.h"
#import "XLCircle.h"

@implementation XLCircleProgress
{
    XLCircle* _circle;
    UILabel *_percentLabel;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}


-(void)initUI
{
    self.layer.cornerRadius = 10;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(2, 5);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 5;
    
    _backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
    _backImageView.center = self.center;
    _backImageView.clipsToBounds = YES;
    _backImageView.layer.cornerRadius = self.frame.size.width/2;
    _backImageView.userInteractionEnabled = YES;
    _backImageView.image = [UIImage imageNamed:@"redpackge"];
    [self addSubview:_backImageView];

    
    float lineWidth = 0.1*self.bounds.size.width;
    _percentLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _percentLabel.textColor = [UIColor whiteColor];
    _percentLabel.textAlignment = NSTextAlignmentCenter;
    _percentLabel.font = [UIFont boldSystemFontOfSize:10];
    _percentLabel.userInteractionEnabled = YES;
    _percentLabel.text = @"0%";
    [self addSubview:_percentLabel];
    
    _circle = [[XLCircle alloc] initWithFrame:self.bounds lineWidth:lineWidth];
    [self addSubview:_circle];
    
    _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    [_circle addGestureRecognizer:_gestureRecognizer];
}
-(void)imageTap:(UITapGestureRecognizer *)tapGestureRecognizer{
    
    NSLog(@"tap");
    
    [_delegate redPacketWasTap:tapGestureRecognizer];
    
    
}
#pragma mark -
#pragma mark Setter方法
-(void)setProgress:(float)progress
{
    _progress = progress;
    _circle.progress = progress;
    
    [self performSelectorOnMainThread:@selector(updatePercentLabel) withObject:nil waitUntilDone:YES];
    
//    if (_circle.progress >= 1) {
//        _backImageView.image = [UIImage imageNamed:@"redpackge"];
//    }
}
-(void)updatePercentLabel{
    _percentLabel.text = [NSString stringWithFormat:@"%.0f%%",_circle.progress*100];
    
    if (_circle.progress < 0.5) {
        _backImageView.alpha = 0.5;
    }else{
        _backImageView.alpha = _circle.progress/1;
    }
}
@end
