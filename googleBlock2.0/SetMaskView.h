//
//  setMaskView.h
//  XYCoreBlueToothDemo
//
//  Created by RainPoll on 16/1/16.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetMaskView : UIView

@property (nonatomic ,copy)NSArray *dataSource;

+(instancetype)setMaskView;


-(void)maskViewStatueCallBack:(void (^)(BOOL *state))callback;
-(void)maskViewSeachCallBack:(void (^)())callback;
-(void)maskViewLinkCallBack:(void(^)())callback;
-(void)maskViewEasyLinkCallBack:(void (^)())callback;
-(void)maskViewSetCallBack:(void(^)())callback;
-(void)maskViewBackBtnCallBack:(void (^)())callback;

-(void)maskViewTableViewDidSelectRowAtIndexPath:(void (^)(NSIndexPath *index,id itemInArray))tableViewCallBck;

-(void)maskViewShowWithComplement:(void (^)(BOOL *state))compliment;
-(void)maskViewHiddenCompliment:(void (^)())compliment;



@end
