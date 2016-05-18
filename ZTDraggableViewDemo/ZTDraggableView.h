//
//  ZTDraggableView.h
//  ZTDraggableViewDemo
//
//  Created by ZT on 16/4/6.
//  Copyright © 2016年 ZT. All rights reserved.
//

#import <UIKit/UIKit.h>
///the angle controls the animation angle after user click the button
#define ROTATION_ANGLE M_PI/8
#define CLICK_ANIMATION_TIME 0.5
#define RESET_ANIMATION_TIME 0.3

@protocol ZTDraggableViewDelegate <NSObject>
-(void)cardSwiped:(UIView *)card LorR:(BOOL)isRight;
-(void)moveCards:(CGFloat)distance;
///if transform the card not enough, move the card back to origin position
-(void)moveBackCards;
///if the above card been removed,
-(void)adjustOtherCards;
@end

@interface ZTDraggableView : UIView

@property (weak) id <ZTDraggableViewDelegate> delegate;


///set the cards can move, Default is NO;
@property (nonatomic)BOOL canPan;
///Basic Cards' information
@property (nonatomic)NSDictionary *userInfo;

@property (nonatomic,strong)UIImageView *headerImageView;
@property (nonatomic,strong)UILabel *numLabel;
@property (nonatomic,strong)UIButton* yesButton;
@property (nonatomic,strong)UIButton* noButton;
@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic)CGPoint originalPoint;
@property (nonatomic)CGPoint originalCenter;
@property (nonatomic)CGAffineTransform originalTransform;

//-(void)leftClickAction;
//-(void)rightClickAction;

@end


