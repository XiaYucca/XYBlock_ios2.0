//
//  XYSwiperCell.h
//  EditAndAllChooseCell
//
//  Created by RainPoll on 16/3/30.
//  Copyright © 2016年 ningBo Jiang. All rights reserved.
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

@interface XYSwiperCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *textField;

+(instancetype)loadSwiperCell;
+(void) registNibFormTableView:(UITableView *)tableView forCellReuseIdentifier:(NSString *)identifier;

-(void)cancelBtnCallback:(void (^)(XYSwiperCell *cell))callback;

-(void)XYSwiperCellGrag:(void (^)(CGPoint point))Grag;

-(void)XYSwiperCellGragState:(void (^)(XYSwiperCell *cell,SwiperCellGragState state))GragState;
-(void)XYSwiperCellEndGrag:(BOOL)animated;

@end
