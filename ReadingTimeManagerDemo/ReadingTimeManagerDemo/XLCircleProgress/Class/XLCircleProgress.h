//
//  CircleView.h
//  YKL
//
//  Created by Apple on 15/12/7.
//  Copyright © 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XLCircleProgressDelegate<NSObject>

-(void)redPacketWasTap:(UITapGestureRecognizer *)tapGestureRecognizer;

@end

@interface XLCircleProgress : UIView
//红包图片
@property (strong,nonatomic) UIImageView *backImageView;
//百分比
@property (assign,nonatomic) float progress;
//红包100%的时候点击事件
@property (nonatomic, strong) UITapGestureRecognizer *gestureRecognizer;
//自由拖动手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;//添加
//传出UITapGestureRecognizer事件
@property (nonatomic, assign) id<XLCircleProgressDelegate>delegate;
@end
