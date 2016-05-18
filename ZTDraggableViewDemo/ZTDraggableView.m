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
#define icon_LikeButton @"icon_smilyFace"
#define icon_UnLikeButton @"icon_cry"

#define BUTTON_WIDTH lengthFit(40)

@implementation ZTDraggableView
{
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

- (id)initWithFrame:(CGRect)frame {
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
        
        UIView * backgroundView = [self backgroundView];
        [self addSubview:backgroundView];
    }
    return self;
}

- (UIView *)backgroundView {
    UIView * backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    backgroundView.layer.cornerRadius = 4;
    backgroundView.clipsToBounds = YES;
    
    ///set buttons' position
    CGFloat buttonOriginY = self.frame.size.height - lengthFit(13) - BUTTON_WIDTH;
    CGFloat inserts = ceilf(lengthFit(47));
    self.noButton.frame = CGRectMake(inserts, buttonOriginY, BUTTON_WIDTH, BUTTON_WIDTH);
    self.yesButton.frame = CGRectMake(self.frame.size.width - inserts - BUTTON_WIDTH, buttonOriginY, BUTTON_WIDTH, BUTTON_WIDTH);
    
    [backgroundView addSubview:self.noButton];
    [backgroundView addSubview:self.yesButton];
    [backgroundView addSubview:self.headerImageView];
    [backgroundView addSubview:self.numLabel];
    
    /**
     Set /allowsEdgeAntialiasing/ value yes --
     this layer is allowed to antialias its edges
     */
    self.layer.allowsEdgeAntialiasing = YES;
    backgroundView.layer.allowsEdgeAntialiasing = YES;
    self.headerImageView.layer.allowsEdgeAntialiasing = YES;
    return backgroundView;
}

///function when user touch the image
-(void)tap:(UITapGestureRecognizer*)gesture {
    if (self.canPan == NO) {
        return;
    }
    NSLog(@"imageView had been touched");
}

-(void)layoutSubviews {
    self.numLabel.text = self.userInfo[@"num"];
}

#pragma mark - Dragging
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer {
    if (self.canPan == NO) {
        return;
    }
    xFromCenter = [gestureRecognizer translationInView:self].x;
    yFromCenter = [gestureRecognizer translationInView:self].y;
    
    switch (gestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan:{
            
        };
            ///transform while user dragging view
        case UIGestureRecognizerStateChanged:{
            self.transform = [self transformWhileDragging];
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
///the position while user dragging the view
- (CGAffineTransform)transformWhileDragging {
    CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
    
    CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
    
    CGFloat scale = MAX(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
    
    self.center = CGPointMake(self.originalCenter.x + xFromCenter, self.originalCenter.y + yFromCenter);
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
    
    return CGAffineTransformScale(transform, scale, scale);
}

#pragma mark - 滑动中事件
///change yes/no button's size when user dragging view to right/left
-(void)updateOverlay:(CGFloat)distance
{
    CGFloat scale = 1 + 0.5 * fabs(distance/PAN_DISTANCE);
    if (distance > 0) {
        self.yesButton.transform = CGAffineTransformMakeScale(scale, scale);
    } else {
        self.noButton.transform = CGAffineTransformMakeScale(scale, scale);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(moveCards:)]) {
        [self.delegate moveCards:distance];
    }
}

#pragma mark - 后续动作判断
///drag the view over it's container
- (void)followUpActionWithDistance:(CGFloat)distance andVelocity:(CGPoint)velocity
{
    if (xFromCenter > 0 && (distance > ACTION_MARGIN_RIGHT || velocity.x > ACTION_VELOCITY)) {
        [self setChangesToLeftOrRight:YES andVelocity:velocity];
    } else if (xFromCenter < 0 && (distance < - ACTION_MARGIN_LEFT || velocity.x < - ACTION_VELOCITY)) {
        [self setChangesToLeftOrRight:NO andVelocity:velocity];
    } else {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:RESET_ANIMATION_TIME
                         animations:^{
                             weakSelf.center = weakSelf.originalCenter;
                             weakSelf.transform = CGAffineTransformMakeRotation(0);
                             weakSelf.yesButton.transform = CGAffineTransformMakeScale(1, 1);
                             weakSelf.noButton.transform = CGAffineTransformMakeScale(1, 1);
                         }];
        if (self.delegate && [self.delegate respondsToSelector:@selector(moveCards:)]) {
            [self.delegate moveBackCards];
        }
    }
}
///after user drag the view to the left or right, change its status
- (void)setChangesToLeftOrRight:(BOOL)isRight andVelocity:(CGPoint)velocity {
    //横向移动距离
    CGFloat distanceX;
    if (isRight) {
        distanceX = [[UIScreen mainScreen]bounds].size.width + CARD_WIDTH + self.originalCenter.x;
    } else {
        distanceX = - CARD_WIDTH - self.originalCenter.x;
    }
    CGFloat distanceY = distanceX * yFromCenter / xFromCenter;//纵向移动距离
    CGPoint finishPoint = CGPointMake(self.originalCenter.x + distanceX, self.originalCenter.y + distanceY);//目标center点
    
    CGFloat vel = sqrtf(pow(velocity.x, 2) + pow(velocity.y, 2));//滑动手势横纵合速度
    CGFloat displace = sqrt(pow(distanceX - xFromCenter, 2) + pow(distanceY - yFromCenter, 2));//需要动画完成的剩下距离
    
    CGFloat duration = fabs(displace / vel);//动画时间
    
    if (duration > 0.6) {
        duration = 0.6;
    } else if (duration < 0.3) {
        duration = 0.3;
    }
    [self startTheAnimate:duration andDirection:isRight destination:finishPoint];
}
- (void)startTheAnimate:(CGFloat)duration andDirection:(BOOL)isRight destination:(CGPoint)destination {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration
                     animations:^{
                         UIButton * button = isRight ? weakSelf.yesButton : weakSelf.noButton;
                         button.transform = CGAffineTransformMakeScale(1.5, 1.5);
                         weakSelf.center = destination;
                         weakSelf.transform = CGAffineTransformMakeRotation(isRight ? ROTATION_ANGLE : - ROTATION_ANGLE);
                     }completion:^(BOOL complete){
                         UIButton * button = isRight ? self.yesButton : self.noButton;
                         button.transform = CGAffineTransformMakeScale(1, 1);
                         if (self.delegate && [self.delegate respondsToSelector:@selector(cardSwiped:LorR:)]) {
                             [self.delegate cardSwiped:self LorR:isRight];
                         }
                     }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(adjustOtherCards)]) {
        
        [self.delegate adjustOtherCards];
    }
}
#pragma mark - 点击右滑事件
-(void)rightClickAction:(UIButton *)sender
{
    [self userClickButtons:YES];
    
}
#pragma mark - 点击左滑事件
-(void)leftClickAction:(UIButton *)sender
{
    [self userClickButtons:NO];
}

- (void)userClickButtons:(BOOL)isSmilyButton {
    if (self.canPan == NO) {
        return;
    }
    CGPoint finishPoint;
    if (isSmilyButton) {
        finishPoint = CGPointMake([[UIScreen mainScreen]bounds].size.width + CARD_WIDTH * 2 / 3, 2 * PAN_DISTANCE + self.frame.origin.y);
    } else {
        finishPoint = CGPointMake(- CARD_WIDTH * 2 / 3, 2 * PAN_DISTANCE + self.frame.origin.y);
    }
    [self startTheAnimate:CLICK_ANIMATION_TIME andDirection:isSmilyButton destination:finishPoint];
}

///numLabel shows current index of headerImageView
- (UILabel *)numLabel {
    if (!_numLabel) {
        CGFloat numLabelHeight = ceilf(lengthFit(20));
        CGFloat numLabelOriginY = self.headerImageView.frame.size.height - numLabelHeight - 4;
        _numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, numLabelOriginY, self.frame.size.width, numLabelHeight)];
        _numLabel.font = [UIFont systemFontOfSize:15];
        _numLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _numLabel;
}
///set noButton
- (UIButton *)noButton {
    if (!_noButton) {
        _noButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_noButton setBackgroundImage:[UIImage imageNamed:icon_UnLikeButton]
                             forState:UIControlStateNormal];
        [_noButton addTarget:self
                      action:@selector(leftClickAction:)
            forControlEvents:UIControlEventTouchUpInside];
    }
    return _noButton;
}
///set yeButton
- (UIButton *)yesButton {
    if (!_yesButton) {
        _yesButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_yesButton setBackgroundImage:[UIImage imageNamed:icon_LikeButton]
                              forState:UIControlStateNormal];
        [_yesButton addTarget:self action:@selector(rightClickAction:)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _yesButton;
}
- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
        _headerImageView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
        _headerImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [_headerImageView addGestureRecognizer:tap];
    }
    return _headerImageView;
}

@end

