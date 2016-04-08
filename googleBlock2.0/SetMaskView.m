//
//  setMaskView.m
//  XYCoreBlueToothDemo
//
//  Created by RainPoll on 16/1/16.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import "SetMaskView.h"

//#define XYDefaultWith   [[UIScreen mainScreen] bounds].size.width
//#define XYDefaultHeight [[UIScreen mainScreen] bounds].size.height

#define defaulWith 0.7
#define defaulHeigh 0.7

#define setMaskViewWith(n)   SCREEN_WIDTH*(n)
#define setMaskViewHeigh(n)  SCREEN_HEIGHT*(n)

@interface SetMaskView ()<UITableViewDataSource ,UITableViewDelegate>

@property (nonatomic ,weak)UITableView *listTable;

@property (nonatomic ,weak)UIView *backView;
@property (nonatomic ,weak)UIButton *stateBtn;
@property (nonatomic ,weak)UIButton *setBtn;
@property (nonatomic ,weak)UIButton *seachBtn;
@property (nonatomic ,weak)UIButton *linkBtn;
@property (nonatomic ,weak)UIButton *easyLinkBtn;
@property (nonatomic ,weak)UIButton *backBtn;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progress;

@property (nonatomic ,copy)void (^complement)();

@property (nonatomic ,copy)void (^stateBtnTap)(BOOL *state);
@property (nonatomic ,copy)void (^seachBtnTap)();
@property (nonatomic ,copy)void (^linkBtnTap)();
@property (nonatomic ,copy)void (^easyLinkBtnTap)();
@property (nonatomic ,copy)void (^setBtnTap)();
@property (nonatomic ,copy)void (^backBtnTap)();
@property (nonatomic ,assign)BOOL state;

@property (nonatomic ,copy)void (^tableViewTap)(NSIndexPath *index,id itemInArray);

@end
@implementation SetMaskView

@synthesize  dataSource = _dataSource;

-(void)setDataSource:(NSArray *)dataSource
{
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        [self.listTable reloadData];
    }
}

-(NSArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [@[]copy];
    }
    return _dataSource;
}

+(instancetype)setMaskView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"SetMask" owner:self options:nil]firstObject];
}

-(void)setUpUI
{
    self.stateBtn = [self viewWithTag:10];
    self.seachBtn  = [self viewWithTag:20];
    self.linkBtn   = [self viewWithTag:30];
    self.easyLinkBtn = [self viewWithTag:40];
    self.listTable = [self viewWithTag:50];
    self.setBtn = [self viewWithTag:60];
    self.backBtn = [self viewWithTag:70];

    self.listTable.delegate = self;
    self.listTable.dataSource = self;
    
    [self.easyLinkBtn addTarget:self action:@selector(btnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.linkBtn addTarget:self action:@selector(btnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.setBtn addTarget:self action:@selector(btnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.seachBtn addTarget:self action:@selector(btnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.stateBtn addTarget:self action:@selector(btnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn addTarget:self action:@selector(btnTap:) forControlEvents:UIControlEventTouchUpInside];
    
    
     self.bounds = CGRectMake(0, 0, setMaskViewWith(defaulWith), setMaskViewHeigh(defaulHeigh));
     self.center = CGPointMake(SCREEN_WIDTH *0.5, SCREEN_HEIGHT * 0.5);
     self.progress.hidden = YES;
     self.transform = CGAffineTransformMakeScale(1, 0.01);
    
    //    NSLog(@"frame%@", NSStringFromCGRect(self.frame));
}

-(void)btnTap:(UIButton *)sender
{

    switch (sender.tag) {
        case 10:
            NSLog(@"蓝牙已经关闭按钮");
            _state = sender.isSelected;
            !self.stateBtnTap ?: self.stateBtnTap(&_state);
    
            sender.selected = _state;
            break;
        case 20:
             NSLog(@"搜寻主机按钮");
             self.progress.hidden = NO;
            [self.progress startAnimating];
       !self.seachBtnTap ?: self.seachBtnTap();
            [self stopProgerss];
            break;
        case 30:
            NSLog(@"连接按钮");
            !self.linkBtnTap ?: self.linkBtnTap();
            break;
        case 40:
            NSLog(@"一键按钮");
            !self.easyLinkBtnTap ?: self.easyLinkBtnTap();
            break;
        case 60:
            NSLog(@"设置按钮");
            !self.setBtnTap ?: self.setBtnTap();
            break;
        case 70:
            NSLog(@"返回按钮");
           
            [self maskViewHiddenCompliment:^{
            }];
            !self.backBtnTap ?: self.backBtnTap();
            
            break;
        default:
            
            break;
            
    }
}

-(void)stopProgerss
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.progress.hidden = YES;
        [self.progress stopAnimating];
    });
}


#pragma mark - maskView callBack (block method)

-(void)maskViewStatueCallBack:(void (^)(BOOL *state))callback
{
    self.stateBtnTap = callback;
}

-(void)maskViewSeachCallBack:(void (^)())callback
{
    self.seachBtnTap  = callback;
}

-(void)maskViewLinkCallBack:(void(^)())callback
{
    self.linkBtnTap = callback;
}

-(void)maskViewEasyLinkCallBack:(void (^)())callback
{
    self.easyLinkBtnTap = callback;
}

-(void)maskViewBackBtnCallBack:(void (^)())callback
{
    self.backBtnTap = callback;
}




-(void)maskViewSetCallBack:(void(^)())callback
{
    self.setBtnTap = callback;
}

-(void)maskViewTableViewDidSelectRowAtIndexPath:(void (^)(NSIndexPath *index,id itemInArray))tableViewCallBck
{
    self.tableViewTap = tableViewCallBck;
}

-(void)maskViewShowWithComplement:(void (^)(BOOL *state))compliment
{
    UIView *back = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    [back addSubview:self];
    
    back.transform = CGAffineTransformMakeScale(1, 0.01);
    
    back.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    [[UIApplication sharedApplication].keyWindow addSubview:back];
    
    self.backView = back;
    
    [UIView animateWithDuration:0.1 animations:^{
        self.backView.transform = CGAffineTransformIdentity;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        !compliment ?:compliment(&_state);
         self.stateBtn.selected = _state;
    }];
    // self.complement = compliment;
}

-(void)maskViewHiddenCompliment:(void (^)())compliment
{
     [UIView animateWithDuration:0.1 animations:^{
                    self.transform = CGAffineTransformMakeScale(1, 0.01);
                     self.backView.transform = CGAffineTransformMakeScale(1, 0.01);
                } completion:^(BOOL finished) {
                    [self.backView removeFromSuperview];
                    [self removeFromSuperview];
                    !compliment ?:compliment();
                }];
    
}

/*  这是代码穿件View的时候调用的方法
-(instancetype)initWithFrame:(CGRect)frame
{
  NSLog(@"initframe%@", NSStringFromCGRect(self.frame));
    return [super initWithFrame:frame];
}

 //这个是从xib加载得时候开始调用的方法
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"frame%@", NSStringFromCGRect(self.frame));
    return [super initWithCoder:aDecoder];
}
*/

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
   
    [self setUpUI];
    NSLog(@"frame%@", NSStringFromCGRect(self.frame));
    
   return [super initWithCoder:aDecoder];
}

//这个是当访问xib的view的时候 或者调用addsubviews方法的时候 开始调用 调用多次
-(void)layoutSubviews
{ // NSLog(@"%s",__func__);
}

//这个是加载xib完成 的时候
-(void)awakeFromNib
{NSLog(@"%s",__func__);
    [self setUpUI];
  //    NSLog(@"awake%@", NSStringFromCGRect(self.frame));
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"%s",__func__);
}



#pragma mark - tableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"setCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId
                ];
        
     //   cell.textLabel.text = [NSString stringWithFormat:@"%li",indexPath.row];
        
        cell.textLabel.text = self.dataSource[indexPath.row];
        
     }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    !self.tableViewTap ?: self.tableViewTap(indexPath,self.dataSource[indexPath.row]);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)dealloc
{
    NSLog(@"setView delloc");
}

@end
