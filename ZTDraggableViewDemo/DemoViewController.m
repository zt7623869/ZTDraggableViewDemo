//
//  DemoViewController.m
//  ZTDraggableViewDemo
//
//  Created by ZT on 16/4/6.
//  Copyright © 2016年 ZT. All rights reserved.
//

#import "DemoViewController.h"
#import "ZTDraggableView.h"
#import "FitHeader.h"

#define CARD_NUM 5
#define MIN_INFO_NUM 10
#define CARD_SCALE 0.95

@interface DemoViewController ()

@property(nonatomic)NSInteger page;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ZTDraggableView";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.allCards = [NSMutableArray array];
    self.sourceObject = [NSMutableArray array];
    self.page = 0;
    
    [self addControls];
    [self addCards];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requestSourceData:YES];
    });
    
}

#pragma mark - 添加控件
-(void)addControls{
    
    UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [reloadBtn setTitle:@"Reload" forState:UIControlStateNormal];
    reloadBtn.frame = CGRectMake(self.view.center.x-25, self.view.frame.size.height-60, 50, 30);
    [reloadBtn addTarget:self action:@selector(refreshAllCards) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reloadBtn];
}

#pragma mark - 刷新所有卡片
-(void)refreshAllCards{
    
    self.sourceObject=[@[] mutableCopy];
    self.page = 0;
    
    for (int i=0; i<_allCards.count ;i++) {
        
        ZTDraggableView *card=self.allCards[i];
        
        CGPoint finishPoint = CGPointMake(-CARD_WIDTH, 2*PAN_DISTANCE+card.frame.origin.y);
        
        [UIView animateKeyframesWithDuration:0.5 delay:0.06*i options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            
            card.center = finishPoint;
            card.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
            
        } completion:^(BOOL finished) {

            card.yesButton.transform=CGAffineTransformMakeScale(1, 1);
            card.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
            card.hidden=YES;
            card.center=CGPointMake([[UIScreen mainScreen]bounds].size.width+CARD_WIDTH, self.view.center.y);
            
            if (i==_allCards.count-1) {
                [self requestSourceData:YES];
            }
        }];
    }
}

#pragma mark - 请求数据
-(void)requestSourceData:(BOOL)needLoad{
    
    /*
     在此添加网络数据请求代码
     */

    NSMutableArray *objectArray = [@[] mutableCopy];
    for (int i = 1; i<=10; i++) {
        [objectArray addObject:@{@"num":[NSString stringWithFormat:@"%ld",self.page*10+i]}];
    }
    
    [self.sourceObject addObjectsFromArray:objectArray];
    self.page++;
    
    //如果只是补充数据则不需要重新load卡片，而若是刷新卡片组则需要重新load
    if (needLoad) {
       [self loadAllCards];
    }
 
}

#pragma mark - 重新加载卡片
-(void)loadAllCards{
    
    for (int i=0; i<self.allCards.count; i++) {
        ZTDraggableView *draggableView=self.allCards[i];
        
        if ([self.sourceObject firstObject]) {
            draggableView.userInfo=[self.sourceObject firstObject];
            [self.sourceObject removeObjectAtIndex:0];
            [draggableView layoutSubviews];
            draggableView.hidden=NO;
        }else{
            draggableView.hidden=YES;//如果没有数据则隐藏卡片
        }
    }
    
    for (int i=0; i<_allCards.count ;i++) {
        
        ZTDraggableView *draggableView=self.allCards[i];
        
        CGPoint finishPoint = CGPointMake(self.view.center.x, self.view.center.y);
        
        [UIView animateKeyframesWithDuration:0.5 delay:0.06*i options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            
            draggableView.center = finishPoint;
            draggableView.transform = CGAffineTransformMakeRotation(0);
            
            if (i>0&&i<CARD_NUM-1) {
                ZTDraggableView *preDraggableView=[_allCards objectAtIndex:i-1];
                draggableView.transform=CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i), pow(CARD_SCALE, i));
                CGRect frame=draggableView.frame;
                frame.origin.y=preDraggableView.frame.origin.y+(preDraggableView.frame.size.height-frame.size.height)+10*pow(0.7,i);
                draggableView.frame=frame;
                
            }else if (i==CARD_NUM-1) {
                ZTDraggableView *preDraggableView=[_allCards objectAtIndex:i-1];
                draggableView.transform=preDraggableView.transform;
                draggableView.frame=preDraggableView.frame;
            }
        } completion:^(BOOL finished) {

        }];
        
        draggableView.originalCenter=draggableView.center;
        draggableView.originalTransform=draggableView.transform;
        
        if (i==CARD_NUM-1) {
            self.lastCardCenter=draggableView.center;
            self.lastCardTransform=draggableView.transform;
        }
    }
}

#pragma mark - 首次添加卡片
-(void)addCards{
    for (int i = 0; i<CARD_NUM; i++) {
        
        ZTDraggableView *draggableView = [[ZTDraggableView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width+CARD_WIDTH, self.view.center.y-CARD_HEIGHT/2, CARD_WIDTH, CARD_HEIGHT)];
        
        if (i>0&&i<CARD_NUM-1) {
            draggableView.transform=CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i), pow(CARD_SCALE, i));
        }else if(i==CARD_NUM-1){
            draggableView.transform=CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i-1), pow(CARD_SCALE, i-1));
        }
        draggableView.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
        draggableView.delegate = self;
        
        [_allCards addObject:draggableView];
        if (i==0) {
            draggableView.canPan=YES;
        }else{
            draggableView.canPan=NO;
        }
    }
    
    for (int i=(int)CARD_NUM-1; i>=0; i--){
        [self.view addSubview:_allCards[i]];
    }
}

#pragma mark - 滑动后续操作
-(void)cardSwiped:(ZTDraggableView *)card LorR:(BOOL)isRight{
    
    if (isRight) {
        [self like:card.userInfo];
    }else{
        [self unlike:card.userInfo];
        
    }
    
    [_allCards removeObject:card];
    card.transform = self.lastCardTransform;
    card.center = self.lastCardCenter;
    card.canPan=NO;
    [self.view insertSubview:card belowSubview:[_allCards lastObject]];
    [_allCards addObject:card];
    
    if ([self.sourceObject firstObject]!=nil) {
        card.userInfo=[self.sourceObject firstObject];
        [self.sourceObject removeObjectAtIndex:0];
        [card layoutSubviews];
        if (self.sourceObject.count<MIN_INFO_NUM) {
            [self requestSourceData:NO];
        }
    }else{
        card.hidden=YES;//如果没有数据则隐藏卡片
    }
    
    for (int i = 0; i<CARD_NUM; i++) {
        ZTDraggableView*draggableView=[_allCards objectAtIndex:i];
        draggableView.originalCenter=draggableView.center;
        draggableView.originalTransform=draggableView.transform;
        if (i==0) {
            draggableView.canPan=YES;
        }
    }
//        NSLog(@"%d",_sourceObject.count);
}

#pragma mark - 滑动中更改其他卡片位置
-(void)moveCards:(CGFloat)distance{
    
    if (fabs(distance)<=PAN_DISTANCE) {
        for (int i = 1; i<CARD_NUM-1; i++) {
            ZTDraggableView *draggableView=_allCards[i];
            ZTDraggableView *preDraggableView=[_allCards objectAtIndex:i-1];
            
            draggableView.transform=CGAffineTransformScale(draggableView.originalTransform, 1+(1/CARD_SCALE-1)*fabs(distance/PAN_DISTANCE)*0.6, 1+(1/CARD_SCALE-1)*fabs(distance/PAN_DISTANCE)*0.6);//0.6为缩减因数，使放大速度始终小于卡片移动速度
            
            CGPoint center=draggableView.center;
            center.y=draggableView.originalCenter.y-(draggableView.originalCenter.y-preDraggableView.originalCenter.y)*fabs(distance/PAN_DISTANCE)*0.6;//此处的0.6同上
            draggableView.center=center;
        }
    }
}

#pragma mark - 滑动终止后复原其他卡片
-(void)moveBackCards{
    for (int i = 1; i<CARD_NUM-1; i++) {
        ZTDraggableView *draggableView=_allCards[i];
        [UIView animateWithDuration:RESET_ANIMATION_TIME
                         animations:^{
                             draggableView.transform=draggableView.originalTransform;
                             draggableView.center=draggableView.originalCenter;
                         }];
    }
}

#pragma mark - 滑动后调整其他卡片位置
-(void)adjustOtherCards{
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         for (int i = 1; i<CARD_NUM-1; i++) {
                             ZTDraggableView *draggableView=_allCards[i];
                             ZTDraggableView *preDraggableView=[_allCards objectAtIndex:i-1];
                             draggableView.transform=preDraggableView.originalTransform;
                             draggableView.center=preDraggableView.originalCenter;
                         }
                     }completion:^(BOOL complete){
                         
                     }];
    
}

#pragma mark - 喜欢
-(void)like:(NSDictionary*)userInfo{
    
    /*
     在此添加“喜欢”的后续操作
     */
    
    NSLog(@"like:%@",userInfo[@"num"]);
}

#pragma mark - 不喜欢
-(void)unlike:(NSDictionary*)userInfo{
    
    /*
     在此添加“不喜欢”的后续操作
     */
    
    NSLog(@"unlike:%@",userInfo[@"num"]);
}


@end
