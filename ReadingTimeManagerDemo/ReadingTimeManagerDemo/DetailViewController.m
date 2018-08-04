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

@property(nonatomic,assign) float timeCount;
//设置多少时间可以得到一个红包,可以从后台获取
@property(nonatomic,assign) float setReadingTimeWithOneRedPacket;//（1/60 = ）1分钟 - （1/120）2分钟
//记录tableViewContentOffsizeY
@property(nonatomic,strong) NSMutableArray *reconArray;

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation DetailViewController



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    _countTtimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTime:) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    NSLog(@"viewWillDisappear");
    
    //记录_timeCount的计时次数
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[NSString stringWithFormat:@"%f",_circle.progress] forKey:@"totalReadingTimeRecond"];
    [userDefaults synchronize];
    
    NSLog(@"totalReadingTimeRecond = %@",[NSString stringWithFormat:@"%lf",_circle.progress]);
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
    
   

    [self addCircle];
    
    __weak __typeof__(self) weakSelf = self;
    
    __block NSInteger count = 0;
    //创建队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    //创建定时器
    weakSelf.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //设置定时器时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0);
    uint64_t interval = (uint64_t)(0.05 * NSEC_PER_SEC);
    dispatch_source_set_timer(weakSelf.timer, start, interval, 0);
    //设置回调
    dispatch_source_set_event_handler(weakSelf.timer, ^{
        //重复执行的事件
        NSLog(@"-----%ld-----", count);
        
        count++;
        
        
        if (weakSelf.circle.progress >= 1) {
            weakSelf.circle.progress = 0;
        }else{
            
            weakSelf.circle.progress += 0.001;
        }
    
//        if (count == 5) {
//            //weakSelf.circle.progress += 0.1;
//            //停止定时器
//            dispatch_source_cancel(weakSelf.timer);
//            weakSelf.timer = nil;
//        }
    });
    //启动定时器

    dispatch_resume(weakSelf.timer);
    
    
    
//    __weak __typeof(self) weakself= self;
//    dispatch_async(dispatch_queue_create(0, 0), ^{
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//        });
//    });
}


-(void)addCircle
{

    _circle = [[XLCircleProgress alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    _circle.center = CGPointMake(screen_width - _circle.frame.size.width/2, screen_heght/2);
    _circle.delegate = self;
    
    NSLog(@"_circle = %@",_circle);
    
    //取出缓存的totalReadTimeRecond阅读时间
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults valueForKey:@"totalReadingTimeRecond"]) {
        _timeCount = [[userDefaults valueForKey:@"totalReadingTimeRecond"] floatValue];
        _circle.progress = _timeCount ;
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

        //计数归零
        _timeCount = 0;
        
    }
}
//----scrollView代理方法-------
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
   

}

//开始拽动滚动
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    

}
//滚动视图减速完成，滚动将停止时，调用该方法
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    
}
// 当滚动视图动画完成后，调用该方法，如果没有动画，那么该方法将不被调用
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    //NSLog(@"scrollViewDidEndScrollingAnimation");
    // 有效的动画方法为：
    //    - (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated 方法
    //    - (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated 方法

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
