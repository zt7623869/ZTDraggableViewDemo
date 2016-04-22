//
//  DemoViewController.h
//  ZTDraggableViewDemo
//
//  Created by ZT on 16/4/6.
//  Copyright © 2016年 ZT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZTDraggableView.h"

#define PAN_DISTANCE 120
#define CARD_WIDTH lengthFit(333)
#define CARD_HEIGHT lengthFit(400)

@interface DemoViewController : UIViewController <ZTDraggableViewDelegate>

@property (retain,nonatomic)NSMutableArray* allCards;
@property (nonatomic) CGPoint lastCardCenter;
@property (nonatomic) CGAffineTransform lastCardTransform;

@property (nonatomic,strong)NSMutableArray *sourceObject;

@end
