//
//  ZTDraggableView.m
//  ZTDraggableViewDemo
//
//  Created by ZT on 16/4/6.
//  Copyright © 2016年 ZT. All rights reserved.
//

#import "ZTDraggableView.h"
#import "DemoViewController.h"
#import "FitHeader.h"

#define ACTION_MARGIN_RIGHT lengthFit(150)
#define ACTION_MARGIN_LEFT lengthFit(150)
#define ACTION_VELOCITY 400
#define SCALE_STRENGTH 4
#define SCALE_MAX .93
#define ROTATION_MAX 1
#define ROTATION_STRENGTH lengthFit(414)

#define BUTTON_WIDTH lengthFit(40)

@implementation ZTDraggableView{
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 4;
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        [self addGestureRecognizer:self.panGestureRecognizer];
        
        UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgView.layer.cornerRadius=4;
        bgView.clipsToBounds=YES;
        [self addSubview:bgView];
        
        self.noButton = [[UIButton alloc]initWithFrame:CGRectMake(lengthFit(47), self.frame.size.height-lengthFit(13)-BUTTON_WIDTH, BUTTON_WIDTH, BUTTON_WIDTH)];
        [self.noButton setBackgroundImage:[UIImage imageNamed:@"哭脸"] forState:UIControlStateNormal];
        [self.noButton addTarget:self action:@selector(leftClickAction) forControlEvents:UIControlEventTouchUpInside];
        self.yesButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width-lengthFit(47)-BUTTON_WIDTH, self.frame.size.height-lengthFit(13)-BUTTON_WIDTH, BUTTON_WIDTH, BUTTON_WIDTH)];
        [self.yesButton setBackgroundImage:[UIImage imageNamed:@"笑脸"] forState:UIControlStateNormal];
        [self.yesButton addTarget:self action:@selector(rightClickAction) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:self.noButton];
        [bgView addSubview:self.yesButton];
        
        self.headerImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.width)];
        self.headerImageView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
        self.headerImageView.userInteractionEnabled=YES;
        [bgView addSubview:self.headerImageView];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [self.headerImageView addGestureRecognizer:tap];
        
        
        self.numLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, self.headerImageView.frame.size.height-lengthFit(20)-4, self.frame.size.width, lengthFit(20))];
        self.numLabel.font=[UIFont systemFontOfSize:15];
        self.numLabel.textAlignment=NSTextAlignmentCenter;
        [bgView addSubview:self.numLabel];
        
        self.layer.allowsEdgeAntialiasing=YES;
        bgView.layer.allowsEdgeAntialiasing=YES;
        self.headerImageView.layer.allowsEdgeAntialiasing=YES;
        
    }
    return self;
}

-(void)tap:(UITapGestureRecognizer*)sender{
    
    if (self.canPan==NO) {
        return;
    }

    NSLog(@"tap");
    
}

-(void)layoutSubviews{
    
    self.numLabel.text = self.userInfo[@"num"];
}

#pragma mark - 拖动
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (self.canPan==NO) {
        return;
    }
    
    xFromCenter = [gestureRecognizer translationInView:self].x;
    yFromCenter = [gestureRecognizer translationInView:self].y;
    
    switch (gestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan:{
            
        };
            
        case UIGestureRecognizerStateChanged:{
            
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            CGFloat scale = MAX(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            self.center = CGPointMake(self.originalCenter.x + xFromCenter, self.originalCenter.y + yFromCenter);
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            self.transform = scaleTransform;
            [self updateOverlay:xFromCenter];
            
            break;
        };
        case UIGestureRecognizerStateEnded: {
 
            [self followUpActionWithDistance:xFromCenter andVelocity:[gestureRecognizer velocityInView:self.superview]];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

#pragma mark - 滑动中事件
-(void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        self.yesButton.transform=CGAffineTransformMakeScale(1+0.5*fabs(distance/PAN_DISTANCE), 1+0.5*fabs(distance/PAN_DISTANCE));
    } else {
        self.noButton.transform=CGAffineTransformMakeScale(1+0.5*fabs(distance/PAN_DISTANCE), 1+0.5*fabs(distance/PAN_DISTANCE));
    }

    [self.delegate moveCards:distance];
}

#pragma mark - 后续动作判断
- (void)followUpActionWithDistance:(CGFloat)distance andVelocity:(CGPoint)velocity
{
    if (xFromCenter > 0 && (distance > ACTION_MARGIN_RIGHT||velocity.x > ACTION_VELOCITY)) {
        [self rightAction:velocity];
    } else if (xFromCenter <0 && (distance < -ACTION_MARGIN_LEFT||velocity.x < -ACTION_VELOCITY)) {
        [self leftAction:velocity];
    } else {
        [UIView animateWithDuration:RESET_ANIMATION_TIME
                         animations:^{
                             self.center = self.originalCenter;
                             self.transform = CGAffineTransformMakeRotation(0);
                             self.yesButton.transform=CGAffineTransformMakeScale(1, 1);
                             self.noButton.transform=CGAffineTransformMakeScale(1, 1);

                         }];
        [self.delegate moveBackCards];
    }
}

#pragma mark - 右滑后续事件
-(void)rightAction:(CGPoint)velocity
{
    CGFloat distanceX=[[UIScreen mainScreen]bounds].size.width+CARD_WIDTH+self.originalCenter.x;//横向移动距离
    CGFloat distanceY=distanceX*yFromCenter/xFromCenter;//纵向移动距离
    CGPoint finishPoint = CGPointMake(self.originalCenter.x+distanceX, self.originalCenter.y+distanceY);//目标center点
    
    CGFloat vel=sqrtf(pow(velocity.x, 2)+pow(velocity.y, 2));//滑动手势横纵合速度
    CGFloat displace=sqrt(pow(distanceX-xFromCenter,2)+pow(distanceY-yFromCenter,2));//需要动画完成的剩下距离
    
    CGFloat duration=fabs(displace/vel);//动画时间
    
    if (duration>0.6) {
        duration=0.6;
    }else if(duration<0.3){
        duration=0.3;
    }
    
    [UIView animateWithDuration:duration
                     animations:^{

                         self.yesButton.transform=CGAffineTransformMakeScale(1.5, 1.5);
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
                     }completion:^(BOOL complete){

                         self.yesButton.transform=CGAffineTransformMakeScale(1, 1);
                         [self.delegate cardSwiped:self LorR:YES];
                     }];
    [self.delegate adjustOtherCards];
    
}

#pragma mark - 左滑后续事件
-(void)leftAction:(CGPoint)velocity
{
    CGFloat distanceX=-CARD_WIDTH-self.originalCenter.x;//横向移动距离
    CGFloat distanceY=distanceX*yFromCenter/xFromCenter;//纵向移动距离
    CGPoint finishPoint = CGPointMake(self.originalCenter.x+distanceX, self.originalCenter.y+distanceY);//目标center点
    
    CGFloat vel=sqrtf(pow(velocity.x, 2)+pow(velocity.y, 2));//滑动手势横纵合速度
    CGFloat displace=sqrt(pow(distanceX-xFromCenter,2)+pow(distanceY-yFromCenter,2));//需要动画完成的剩下距离
    
    CGFloat duration=fabs(displace/vel);//动画时间
    
    if (duration>0.6) {
        duration=0.6;
    }else if(duration<0.3){
        duration=0.3;
    }
    
    [UIView animateWithDuration:duration
                     animations:^{
  
                         self.noButton.transform=CGAffineTransformMakeScale(1.5, 1.5);
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
                     }completion:^(BOOL complete){

                         self.noButton.transform=CGAffineTransformMakeScale(1, 1);
                         [self.delegate cardSwiped:self LorR:NO];
                     }];
    [self.delegate adjustOtherCards];
    
}

#pragma mark - 点击右滑事件
-(void)rightClickAction
{
    if (self.canPan==NO) {
        return;
    }

    CGPoint finishPoint = CGPointMake([[UIScreen mainScreen]bounds].size.width+CARD_WIDTH*2/3, 2*PAN_DISTANCE+self.frame.origin.y);
    [UIView animateWithDuration:CLICK_ANIMATION_TIME
                     animations:^{
  
                         self.yesButton.transform=CGAffineTransformMakeScale(1.5, 1.5);
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
                     }completion:^(BOOL complete){

                         self.yesButton.transform=CGAffineTransformMakeScale(1, 1);
                         [self.delegate cardSwiped:self LorR:YES];
                     }];
    
    [self.delegate adjustOtherCards];
    
}

#pragma mark - 点击左滑事件
-(void)leftClickAction
{
    if (self.canPan==NO) {
        return;
    }

    CGPoint finishPoint = CGPointMake(-CARD_WIDTH*2/3, 2*PAN_DISTANCE+self.frame.origin.y);
    [UIView animateWithDuration:CLICK_ANIMATION_TIME
                     animations:^{
 
                         self.noButton.transform=CGAffineTransformMakeScale(1.5, 1.5);
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
                     }completion:^(BOOL complete){

                         self.noButton.transform=CGAffineTransformMakeScale(1, 1);
                         [self.delegate cardSwiped:self LorR:NO];
                     }];
    
    [self.delegate adjustOtherCards];
    
}

@end

