//
//  setMaskView.m
//  XYCoreBlueToothDemo
//
//  Created by RainPoll on 16/1/16.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef enum{
//    GragStateStart,
//    GragStateChange,
//    GragStateEnd
//    } SwiperCellGragState;


typedef NS_ENUM(NSInteger, SwiperCellGragState) {
    SwiperCellGragStatePossible,
    SwiperCellGragStateBegan,
    SwiperCellGragStateChanged,
    SwiperCellGragStateEnded,
    SwiperCellGragStateCancelled,
    SwiperCellGragStateFailed,
    SwiperCellGragStateRecognized = SwiperCellGragStateEnded
};

typedef NS_ENUM(NSInteger, SwiperCellGragDeration)
{
    SwiperCellGragDerationLeft,
    SwiperCellGragDerationRight
};



@interface XYSwiperCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *bkView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (assign,nonatomic,getter=isEnableSwiper) BOOL enableSwiper;

+(instancetype)loadSwiperCell;
+(void) registNibFormTableView:(UITableView *)tableView forCellReuseIdentifier:(NSString *)identifier;

-(void)cancelBtnCallback:(void (^)(XYSwiperCell *cell))callback;

-(void)XYSwiperCellGrag:(void (^)(CGPoint point))GragPoint;

-(void)XYSwiperCellGragState:(void (^)(XYSwiperCell *cell,SwiperCellGragState state))GragState;
-(void)XYSwiperCellEndGrag:(BOOL)animated;

//-(void)XYSwiperCellEndGrag:(BOOL)animated

@end
