//
//  DetailViewController.m
//  TimeMannagerCenterDemo
//
//  Created by MacOS on 2018/8/3.
//  Copyright © 2018年 MacOS. All rights reserved.
//

#import "DetailViewController.h"
#import "XLCircleProgress.h"

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_heght [UIScreen mainScreen].bounds.size.height

@interface DetailViewController ()<UITableViewDelegate,UITableViewDataSource,XLCircleProgressDelegate>

@property(nonatomic,strong) UITableView *myTableView;
@property(nonatomic,strong) XLCircleProgress *circle;

@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;//添加
@property(nonatomic,strong) NSTimer *countTtimer;
@property(nonatomic,assign) int timeCount;
//设置多少时间可以得到一个红包,可以从后台获取
@property(nonatomic,assign) float setReadingTimeWithOneRedPacket;//（1/60 = ）1分钟 - （1/120）2分钟
//记录tableViewContentOffsizeY
@property(nonatomic,strong) NSMutableArray *reconArray;
//记录持续5秒的偏移对比
@property(nonatomic,assign) int reconContentOffsizeYValueCount;
//
@property(nonatomic,assign) float finallProgressValue;

@end

@implementation DetailViewController



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    _countTtimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTime:) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    NSLog(@"viewWillDisappear");
    //关闭定时器
    [_countTtimer setFireDate:[NSDate distantFuture]];
    
    //记录_timeCount的计时次数
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[NSString stringWithFormat:@"%d",_timeCount] forKey:@"totalReadTimeRecond"];
    [userDefaults synchronize];
    
    NSLog(@"totalTimeRecond = %@",[NSString stringWithFormat:@"%lf",_circle.progress]);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"viewDidLoad");
    
    self.title = @"DetailVC";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_heght) style:UITableViewStylePlain];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.allowsSelection = YES;
    //[_myTableView setContentOffset:CGPointZero];
    [self.view addSubview:_myTableView];
    
    _reconContentOffsizeYValueCount = 1;

    [self addCircle];
    
    //子线程启动NSTimer计时功能
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        __weak __typeof__(self) weakSelf = self;
        
        weakSelf.countTtimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTime:) userInfo:nil repeats:YES];
        //防止循环引用
        [[NSRunLoop currentRunLoop] addTimer:weakSelf.countTtimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
    
}
-(void)countTime:(NSTimer *)timer{
    

        if (_circle.progress >=1) {
            _circle.progress = 1;
            //100%,关闭定时器
            [_countTtimer setFireDate:[NSDate distantFuture]];
        }else{
            
            //
            _timeCount ++;
            _setReadingTimeWithOneRedPacket = 60;
            float everySecond = 1/_setReadingTimeWithOneRedPacket;
            
            //_circle.progress = _timeCount * everySecond;// (1/60)0.01666667 (1/120)0.00833333
            
            [UIView animateWithDuration:0.5 animations:^{
                 __weak __typeof__(self) weakSelf = self;
                weakSelf.circle.progress = weakSelf.timeCount * everySecond;// (1/60)0.01666667 (1/120)0.00833333
            }];
            
            //float y = _myTableView.contentOffset.y;
            
            if (_reconContentOffsizeYValueCount == 6) {
                
                
                if ([_reconArray[0] isEqualToString:_reconArray[4]]) {
                    //关闭定时器
                    [_countTtimer setFireDate:[NSDate distantFuture]];
                    [_reconArray removeAllObjects];
                    _reconContentOffsizeYValueCount = 1;
                }
                
            }else{
                
                [self.reconArray addObject:[NSString stringWithFormat:@"%lf",_myTableView.contentOffset.y]];
                _reconContentOffsizeYValueCount ++;
            }
            
        }
    
//    NSLog(@"%lf,_timeCount = %d,_reconArray count = %lu,_reconContentOffsizeYValueCount = %d,%@,%f",_circle.progress,_timeCount,(unsigned long)_reconArray.count,_reconContentOffsizeYValueCount,_reconArray,_myTableView.contentOffset.y);
    
}

-(void)addCircle
{

    _circle = [[XLCircleProgress alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    _circle.center = CGPointMake(screen_width - _circle.frame.size.width/2, screen_heght/2);
    _circle.delegate = self;
    
    NSLog(@"_circle = %@",_circle);
    
    //取出缓存的totalReadTimeRecond阅读时间
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults valueForKey:@"totalReadTimeRecond"]) {
        _timeCount = [[userDefaults valueForKey:@"totalReadTimeRecond"] intValue];
        _circle.progress = _timeCount * 0.01666667;
    }else{
        _circle.progress = 0;
        _timeCount = 0;
    }

    [self.view addSubview:_circle];
    
    //添加拖动手势
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragViewMoved:)];
     [_circle addGestureRecognizer:self.panGestureRecognizer];
    
}

//tableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"product show  here %ld",(long)indexPath.row];
    cell.detailTextLabel.text = @"nothing serious";
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 50;
}

- (void)dragViewMoved:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:self.view];
        
        //_circle.center = CGPointMake(_circle.center.x + translation.x, _circle.center.y + translation.y);
        NSLog(@"translation.x = %f ,translation.y= %f",translation.x,translation.y);
        
        CGPoint newCenter = CGPointMake(panGestureRecognizer.view.center.x+ translation.x,
                                        panGestureRecognizer.view.center.y + translation.y);
        //    限制屏幕范围：
        newCenter.y = MAX(panGestureRecognizer.view.frame.size.height/2 + 64, newCenter.y);
        newCenter.y = MIN(self.view.frame.size.height - panGestureRecognizer.view.frame.size.height/2, newCenter.y);
        newCenter.x = MAX(panGestureRecognizer.view.frame.size.width/2, newCenter.x);
        newCenter.x = MIN(screen_width - panGestureRecognizer.view.frame.size.width/2,newCenter.x);
        panGestureRecognizer.view.center = newCenter;
       
        //关键，不设为零会不断递增，视图会突然不见
        [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
    }
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint translation = [panGestureRecognizer translationInView:self.view];
        
        if (panGestureRecognizer.view.center.x >= screen_width/2) {
            
           panGestureRecognizer.view.center = CGPointMake(screen_width - panGestureRecognizer.view.frame.size.width/2,
                        panGestureRecognizer.view.center.y + translation.y);
            
             [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
        }else{
            
            panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.frame.size.width/2,
                                                           panGestureRecognizer.view.center.y + translation.y);
            [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
        }
        
        
    }
}
-(void)redPacketWasTap:(UITapGestureRecognizer *)tapGestureRecognizer{
    
    NSLog(@"redPacketWasTap delegate");
    
    if (_circle.progress == 1) {
        
        NSLog(@"红包100%%的时候被点击了");
        _circle.progress = 0;
        //开启定时器
        [_countTtimer setFireDate:[NSDate distantPast]];
        //计数归零
        _timeCount = 0;
    }
}
//----scrollView代理方法-------
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //_isScrolling = YES;
    //_tableViewContentOffsizeY = scrollView.contentOffset.y;
}

//开始拽动滚动
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    //开启定时器
    [_countTtimer setFireDate:[NSDate distantPast]];
}
//滚动视图减速完成，滚动将停止时，调用该方法
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    //延迟关闭定时器5秒钟
    [self performSelector:@selector(delayFor5Second) withObject:nil afterDelay:5];
}
// 当滚动视图动画完成后，调用该方法，如果没有动画，那么该方法将不被调用
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    //NSLog(@"scrollViewDidEndScrollingAnimation");
    // 有效的动画方法为：
    //    - (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated 方法
    //    - (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated 方法
    
}
-(void)delayFor5Second{
    
    //关闭定时器
    [_countTtimer setFireDate:[NSDate distantFuture]];
}
-(NSMutableArray *)reconArray{
    
    if (!_reconArray) {
        _reconArray = [[NSMutableArray alloc] init];
    }
    return _reconArray;
}
-(void)dealloc{
    [_countTtimer invalidate];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
