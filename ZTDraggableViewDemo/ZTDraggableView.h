//
//  ZTDraggableView.h
//  ZTDraggableViewDemo
//
//  Created by ZT on 16/4/6.
//  Copyright © 2016年 ZT. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ROTATION_ANGLE M_PI/8
#define CLICK_ANIMATION_TIME 0.5
#define RESET_ANIMATION_TIME 0.3

@protocol ZTDraggableViewDelegate <NSObject>
-(void)cardSwiped:(UIView *)card LorR:(BOOL)isRight;
-(void)moveCards:(CGFloat)distance;
-(void)moveBackCards;
-(void)adjustOtherCards;
@end

@interface ZTDraggableView : UIView

@property (weak) id <ZTDraggableViewDelegate> delegate;

@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic)CGPoint originalPoint;
@property (nonatomic)CGPoint originalCenter;
@property (nonatomic)CGAffineTransform originalTransform;
@property (nonatomic)BOOL canPan;

@property (nonatomic)NSDictionary *userInfo;

@property (nonatomic,strong)UIImageView *headerImageView;
@property (nonatomic,strong)UILabel *numLabel;
@property (nonatomic,strong)UIButton* yesButton;
@property (nonatomic,strong)UIButton* noButton;

-(void)leftClickAction;
-(void)rightClickAction;

@end


