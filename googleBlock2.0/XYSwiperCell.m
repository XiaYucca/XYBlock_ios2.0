//
//  setMaskView.m
//  XYCoreBlueToothDemo
//
//  Created by RainPoll on 16/1/16.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#define overAnimation 0.5

#import "XYSwiperCell.h"

@interface XYSwiperCell ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic)  UIPanGestureRecognizer *gesture;
@property (weak, nonatomic) IBOutlet UIView *behandView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;

@property (copy,nonatomic)  void (^cansellCallBack)(XYSwiperCell *cell);
@property (copy,nonatomic)  void (^grag)(CGPoint point);
@property (copy,nonatomic)  void (^GragState)(XYSwiperCell *cell,SwiperCellGragState state);

//@property (nonatomic,weak)

@end


@implementation XYSwiperCell
{
    CGAffineTransform orginTransform;
    CGAffineTransform endTransform;
}


-(void)setEnableSwiper:(BOOL)enableSwiper
{
    if (_enableSwiper != enableSwiper) {
        _enableSwiper = enableSwiper;
    
    }
}

-(void)awakeFromNib {
    NSLog(@"开始加载  nib ++++++++++++\n");
    [self loadGesture];
}

+(void) registNibFormTableView:(UITableView *)tableView forCellReuseIdentifier:(NSString *)identifier
{
    [tableView registerNib:[UINib nibWithNibName:@"XYSwiperCell" bundle:nil] forCellReuseIdentifier:identifier];
 //   return [self loadSwiperCell];
}

+(instancetype)loadSwiperCell
{
    return [[[NSBundle mainBundle]loadNibNamed:@"XYSwiperCell" owner:nil options:nil]firstObject];
    
}
-(void)loadGesture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gesttureClick:)];
    self.gesture = pan;
    pan.delegate = self;
    
    [self.behandView addGestureRecognizer:pan];
    
    orginTransform = self.behandView.transform;
    endTransform = CGAffineTransformTranslate(orginTransform,-self.behandView.frame.size.width *overAnimation, 0);
    
    self.enableSwiper = YES;

}

- (IBAction)cancelBtnClick:(id)sender {
    
    NSLog(@"按下了删除按钮");
    __weak id weakself = self;
    !_cansellCallBack ?: _cansellCallBack(weakself);
      [self XYSwiperCellEndGrag:YES];
}

-(void)cancelBtnCallback:(void (^)(XYSwiperCell *cell))callback;
{
    self.cansellCallBack = callback;
    
  
   }
-(void)XYSwiperCellGrag:(void (^)(CGPoint))Grag
{
    self.grag = Grag;
}
-(void)XYSwiperCellGragState:(void (^)(XYSwiperCell *cell,SwiperCellGragState state))GragState
{
    self.GragState = GragState;
}

#pragma mark - pan click
-(void)gesttureClick:(UIPanGestureRecognizer *)pan
{
//    NSLog(@"pan ------> %@\n",pan);
    
    static BOOL opened = NO;
    
    CGPoint point = [pan translationInView:self.behandView];
  
   // if (point.x<0) {
        self.behandView.transform = CGAffineTransformMakeTranslation( point.x, 0);
   // }
  //  if (point.x) {
  //    self.behandView.transform = CGAffineTransformTranslate(endTransform,point.x, 0);
   // }
    
     self.cancelBtn.hidden = NO;
    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        
        if ( point.x<0) {
            
            [UIView animateWithDuration:0.25 animations:^{
                
                self.behandView.transform =   endTransform;
                
            } completion:^(BOOL finished) {
                
                
                opened = YES;
            }];
        }if (point.x>0)  {
            [UIView animateWithDuration:0.25 animations:^{
                self.cancelBtn.hidden = YES;
                self.behandView.transform = orginTransform;
                
            } completion:^(BOOL finished) {
                opened = NO;
                self.cancelBtn.hidden = YES;
                
            }];
        }
    }
    __weak id weakSelf = self;
    !self.GragState?:self.GragState(weakSelf,(SwiperCellGragState)pan.state);
    
    !self.grag?: self.grag(point);
    
    NSLog(@"point --- %@\n",NSStringFromCGPoint(point));
}
#pragma mark -gesture delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.isEnableSwiper) {
        if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
            UIPanGestureRecognizer *g = (UIPanGestureRecognizer *)gestureRecognizer;
            CGPoint point = [g velocityInView:self];
            if (fabsf((float)point.x) > fabsf((float)point.y)) {
                return YES;
            }
        }
        return NO;
    }else{
        return NO;
    }

}
-(void)XYSwiperCellEndGrag:(BOOL)animated
{
    if(animated)
    { [UIView animateWithDuration:0.25 animations:^{
        self.behandView.transform = orginTransform;
    }];
    }
    else
    {
        self.behandView.transform = orginTransform;
    }
    self.cancelBtn.hidden = YES;
}


-(void)animationWithPan:(CGPoint)deration
{
   
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)gestSelector:(id)sender {
    
    
}





@end
