//
//  ExampleUIWebViewController.m
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import "ExampleUIWebViewController.h"
#import "WebViewJavascriptBridge.h"
#import "JSWebViewController.h"
#import "FileOptions.h"

#import "XYSwiperCell.h"
#import "KVNProgress.h"


#define animateViewWith 250

#define fileNameFromLocationDesk  @"fileList.plist"

#define CellField_tag 1000


//NSString *testConst;

const NSString *cellID = @"cell";

@interface ExampleUIWebViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate, MCSwipeTableViewCellDelegate>
@property WebViewJavascriptBridge* bridge;
@property (nonatomic,strong)UIView *animateView;
//@property (nonatomic,copy)NSMutableArray *fileNames;
@property (nonatomic,copy)NSMutableArray *openFileNames;
@property (nonatomic,assign,getter=isSaveState)BOOL saveState;
@property (nonatomic,copy)NSString *selectFileName;
@property (nonatomic,assign)BOOL saveBool;

@property (nonatomic,copy)NSString *recvData;
@property (nonatomic,copy)NSString *sendData;

@property (nonatomic,weak)UITableView *fileList;

@property (nonatomic,strong)JSWebViewController *jsWebView;
@property (nonatomic,weak)UIWebView *webView;
@property (nonatomic ,strong)FileOptions* fileopetions;



@end

@implementation ExampleUIWebViewController
{
    id clickedSender;
}

-(void)viewDidLoad
{
    self.selectFileName = @"project";
}
-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)loadJSWebView:(UIWebView *)webView
{
    JSWebViewController *jswbView = [[JSWebViewController alloc]init];
    
    jswbView.webView = webView;
    
    webView.delegate = jswbView;
    
    self.jsWebView = jswbView;
}
- (void)viewWillAppear:(BOOL)animated {
    [self buildWebJSBridge];
}

#pragma -mark lazy load

-(void)setSaveState:(BOOL)saveState
{
    if (_saveState != saveState) {
        _saveState = saveState;
        [self.fileList reloadData];
    }
}

-(NSMutableArray *)openFileNames
{
    if (!_openFileNames) {
        _openFileNames = [[self loadFileNameDateFormLocaDesk] mutableCopy];
        if (!_openFileNames) {
            _openFileNames = [@[]mutableCopy];
        }
        [self addObserver:self forKeyPath:@"openFileNames" options:NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld context:nil];
    }
    return _openFileNames;
}

-(UIView *)animateView{
    if (!_animateView) {
        [self LoadCustomView];
    }
    return _animateView;
}

-(FileOptions *)fileopetions
{
    if (!_fileopetions) {
        _fileopetions = [[FileOptions alloc]init];
    }
    return _fileopetions;
}


-(void)LoadCustomView
{
    UIView *animareView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH, 0,animateViewWith , SCREEN_HEIGHT)];
    
    
    [animareView setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, animareView.frame.size.width, animareView.frame.size.height-30)];
    
    self.fileList = tableView;
    
    UIButton *btn_save = [[UIButton alloc]initWithFrame:CGRectMake(30, animareView.frame.size.height-30, 70, 30)];
    [btn_save setTitle:@"确定" forState:UIControlStateNormal];
    
    [btn_save addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn_cansale = [[UIButton alloc]initWithFrame:CGRectMake(animareView.frame.size.width-30-50, animareView.frame.size.height-30, 70, 30)];
    
    [btn_cansale setTitle:@"取消" forState:UIControlStateNormal];
    [btn_cansale addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    btn_cansale.tag = 20;
    btn_save.tag = 10;
    
    [animareView addSubview:btn_save];
    [animareView addSubview:btn_cansale];
    
    
    
//   tableView.backgroundColor = [UIColor clearColor];
    
//   [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
//   [XYSwiperCell registNibFormTableView:tableView forCellReuseIdentifier:@"cell"];
//   [tableView registerClass:[XYSwiperCell class] forCellReuseIdentifier:@"cell"];
     [tableView registerNib:[UINib nibWithNibName:@"XYSwiperCell" bundle:nil] forCellReuseIdentifier:@"cell"];

    
    [animareView addSubview:tableView];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    
  
    
    tableView.backgroundColor = [UIColor clearColor];
    
    _animateView = animareView;
    
    [self.view addSubview:animareView];
    
    [self testTableView:tableView];
}



#pragma -mark build bridge
-(void)buildWebJSBridge
{
    
    if (_bridge) { return; }
    
    UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    
    [self.view addSubview:webView];
    self.webView = webView;
    
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
      
        NSLog(@"------------->testObjcCallback called: %@\n", data[@"fileCMD"]);
        
        NSString *cmd = data[@"fileCMD"];
        
        if ([cmd isEqualToString:@"saveFile"]) {
            
            NSString *xmldata = data[@"data"];
            self.recvData = xmldata;
            NSLog(@"xmlDataXXXXXXXXXXX>%@",xmldata);
            
            [self buildFileName];
            
            //    responseCallback(xmldata);
            
        }if ([cmd isEqualToString:@"openFile"]) {
            [self openFileName];
        }
        if([cmd isEqualToString:@"compileFile"])
        {
            NSString *data_temp = data[@"data"];
            
            [self compileFile:data_temp];
            
            [self setupBaseKVNProgressUI];
            
            [self show];
        }
        
    }];
    
    
    
    
    /*
     [_bridge registerHandler:@"testObjcCallback_save" handler:^(id data, WVJBResponseCallback responseCallback) {
     NSLog(@"+++++++++++>testObjcCallback called: %@\n", data[@"data"]);
     
     
     NSString *cmd = data[@"fileCMD"];
     if ([cmd isEqualToString:@"saveFile"]) {
     
     NSString *xmldata =data[@"data"];
     
     self.recvData = xmldata;
     
     //            [self saveProjectWithData:data[@"data"] fileName:self.selectFileName];
     NSLog(@"xmlDataXXXXXXXXXXX>%@",xmldata);
     
     //    responseCallback(xmldata);
     
     }if ([cmd isEqualToString:@"openFile"]) {
     [self openFileName];
     }
     
     
     [self buildFileName];
     
     
     //    [self saveProjectWithData:data[@"data"] fileName:data[@"fileName"]];
     
     // responseCallback(dataXml);
     }];*/
    
    
    [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
    
    //   [self renderButtons:webView];
    [self loadExamplePage:webView];
}

-(void)compileFile:(NSString *)data
{

    
    NSLog(@"uploaddata=++++++++++++++++%@",data);
    
    
    self.fileopetions.filedata = data;
}


#pragma -mark buttonTap
-(void)saveBtnClick:(UIButton *)sender
{
    if (sender.tag == 10) {
        //保存
        if (self.isSaveState) {
            
           // [self callHandler:nil data:@"save"];
            if (self.recvData) {
                [self addOpenFileNamesWithObject:self.selectFileName];
              
            }
            
        }else
        {
            NSString *strData = [self openProjectWithFileName:self.selectFileName];
            
            [self callHandler:nil data:strData];

        }
        self.saveBool = YES;
        
    }if (sender.tag == 20) {
        
        self.saveBool = NO;
    }
    
    [self dissmissWithAnimate:YES withDuration:0.5];

}
#pragma -mark UITableView delegate

-(void)testTableView:(UITableView *)tableView
{
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSaveState) {
        return  1 ;//self.fileNames.count;
    }
    return self.openFileNames.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    XYSwiperCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XYSwiperCell"];
    
    if (cell== nil) {
 
        cell = [XYSwiperCell loadSwiperCell];

        }
    
    UIColor *color = [[UIColor alloc]initWithRed:73/255.0 green:200/255.0 blue:250/255.0 alpha:0.4];//通过RGB来定义自己的颜色
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
    
    cell.selectedBackgroundView.backgroundColor = color;
    
    
    UITextField *field = cell.textField;
    field.delegate = self;

    field.textColor = [UIColor whiteColor];
    if (self.isSaveState) {
        field.placeholder = @"项目名称";
        field.enabled = YES;
        cell.enableSwiper = NO;
        
        cell.selected = NO;
    
    }else
    {
        field.text = self.openFileNames[indexPath.row];
        field.enabled = NO;
        cell.enableSwiper = YES;
    }

    __weak id weakself = self;
    
   [cell cancelBtnCallback:^(XYSwiperCell *cell) {
       [weakself deleateCell:cell];
   }];
    [cell XYSwiperCellGragState:^(XYSwiperCell *cell, SwiperCellGragState state) {
        
        if (state ==SwiperCellGragStateChanged) {
            
            [weakself deselectRowWith:cell animated:NO];
        }
        
    }];
    __weak XYSwiperCell* weakCell = cell;
    [cell XYSwiperCellGrag:^(CGPoint point) {
        if (point.x>0) {
            weakCell.bkView.backgroundColor = [UIColor clearColor];
        }
        else
        {
            weakCell.bkView.backgroundColor = [UIColor blueColor];
        }
    }];
    
   return cell;
}

#pragma mark - delegate cell

-(void)deleateCell:(id)sender
{
    NSString *string = [NSString stringWithFormat:@"是否删除%@?",((XYSwiperCell*)sender).textField.text];
    
    [self deleteAlerView:string cell:sender];
  /*   UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:string preferredStyle:UIAlertControllerStyleAlert];
    
  
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        XYSwiperCell *cell = sender;
        NSIndexPath *cellIndex = [self.fileList indexPathForCell:cell];
       
     // [self.openFileNames removeObjectAtIndex:cellIndex.row];
        
        [self removeOpenFileNamesAtIndexes:cellIndex];
       
        
        
        [self.fileList reloadData];
        }];
    
    UIAlertAction *actionBluth = [UIAlertAction actionWithTitle:@"保留" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertC addAction:action];
    [alertC addAction:actionBluth];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertC animated:NO completion:nil];
  
  */
}

-(void)deleteAlerView:(NSString *)message cell:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    alert.tag = 1;
    [alert show];
    clickedSender = sender;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex %i",buttonIndex);
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            XYSwiperCell *cell = clickedSender;
            NSIndexPath *cellIndex = [self.fileList indexPathForCell:cell];
            
            [self removeOpenFileNamesAtObject:cell.textField.text];
            
            [self.fileList reloadData];
        }
    }
   
    
    if(alertView.tag == 3)
    {
        if (buttonIndex == 1) {
            
            NSString *appString =  @"http://alsRobot.cn";
          
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appString]];
        }
        NSLog(@"");
    }
}



-(void) deselectRowWith:(XYSwiperCell *)cell animated:(BOOL)animate
{
    NSIndexPath *cellIndex = [self.fileList indexPathForCell:cell];
    
    [self.fileList deselectRowAtIndexPath:cellIndex animated:animate];
}



-(void)viewWillDisappear:(BOOL)animated
{
    [self uploadFileNameData];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isSaveState) {
        
        XYSwiperCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        
        self.selectFileName = cell.textField.text;
        
        NSString *strData = [self openProjectWithFileName:self.selectFileName];
        
        [self callHandler:nil data:strData];
    }
    

}

#pragma mark - mcstableViewDelegate
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    
    NSIndexPath *cellIndex = [self.fileList indexPathForCell:cell];
    
    [self.openFileNames removeObjectAtIndex:cellIndex.row];
    
    [self.fileList reloadData];
}


#pragma -mark textfield delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.selectFileName = [textField.text copy];
    
  //  [self.openFileNames addObject:self.selectFileName];
    
    [self uploadFileNameData];
    
        NSLog(@"%s",__func__);
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length) {
        
        if ([self.openFileNames containsObject:textField.text]) {
            
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"项目名重复是否覆盖" preferredStyle:    UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *actionCansel = [UIAlertAction actionWithTitle:@"不覆盖" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [controller addAction:action];
            [controller addAction:actionCansel];
            
            [self presentViewController:controller animated:YES completion:nil];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [controller dismissViewControllerAnimated:YES completion:nil];
            });

            
            return NO;
        }else
        {
        self.selectFileName = [textField.text copy];
        [textField resignFirstResponder];
        [textField endEditing:YES];
        return YES;
        }
    }
    else
    {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"项目名不能为空" preferredStyle:    UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [controller addAction:action];
        
        [self presentViewController:controller animated:YES completion:nil ];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [controller dismissViewControllerAnimated:YES completion:nil];
        });
        return NO;
    }
  
    NSLog(@"%s",__func__);
 
}


-(UIView *)showWithAnimate:(BOOL)animated withDuration:(CGFloat)duration
{
    if (animated) {
        [UIView animateWithDuration:duration animations:^{
            self.animateView.transform = CGAffineTransformMakeTranslation(-animateViewWith, 0);
        }];
    }else
    {
         self.animateView.transform = CGAffineTransformMakeTranslation(-animateViewWith, 0);
    }
  
    
    return self.animateView;
}

-(UIView *)dissmissWithAnimate:(BOOL)animated  withDuration:(CGFloat)duration
{
    if (animated) {
        [UIView animateWithDuration:duration animations:^{
             self.animateView.transform = CGAffineTransformIdentity;
        }];
    }else
    {
        self.animateView.transform = CGAffineTransformIdentity;

    }
    
    return self.animateView;
}

#pragma -mark uiwebView send Data
-(void)btnCallHandler:(id)sender data:(id)data
{
    [self callHandler:nil data:data];
}

- (void)callHandler:(id)sender data:(id)data {
    id dat = @{ @"greetingFromObjC": data };
    [_bridge callHandler:@"testJavascriptHandler" data:dat responseCallback:^(id response) {
        NSLog(@"+++++++++++++++<<<<<<<<<<<<<<<<testJavascriptHandler responded: %@", response);
    }];
}


#pragma -mark load html
- (void)loadExamplePage:(UIWebView*)webView {
    
    NSString *contentPath = [NSBundle mainBundle].bundlePath;

    NSString *newPath = [NSString stringWithFormat:@"%@/BlocklyDuino-pages/blockly/apps/blocklyduino/index.html",contentPath];
    
    NSString *htmlString = [NSString stringWithContentsOfFile:newPath encoding:NSUTF8StringEncoding error:nil];
    
    NSURL *baseurl = [NSURL URLWithString:newPath];
    
    [webView loadHTMLString:htmlString baseURL:baseurl];
    
    }



#pragma -mark files option

-(NSString *)pathForDocument
{
    //1，获取家目录路径的函数：
    NSString *homeDir = NSHomeDirectory();
    //2，获取Documents目录路径的方法：
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    NSLog(@"document ------------->\n%@",docDir);
    return [NSHomeDirectory()stringByAppendingPathComponent:@"Documents"];
}





-(NSString *)openProjectWithFileName:(NSString *)fileName
{
    NSString *path = [self pathForDocument];
    path = [NSString stringWithFormat:@"%@/%@",path,fileName];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSString *str_temp = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    return str_temp;
}

#pragma mark - HUD Method
- (void)setupBaseKVNProgressUI
{
    // See the documentation of all appearance propoerties
    [KVNProgress appearance].statusColor = [UIColor darkGrayColor];
    [KVNProgress appearance].statusFont = [UIFont systemFontOfSize:17.0f];
    [KVNProgress appearance].circleStrokeForegroundColor = [UIColor darkGrayColor];
    [KVNProgress appearance].circleStrokeBackgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.3f];
    [KVNProgress appearance].circleFillBackgroundColor = [UIColor clearColor];
    [KVNProgress appearance].backgroundFillColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
    [KVNProgress appearance].backgroundTintColor = [UIColor whiteColor];
    [KVNProgress appearance].successColor = [UIColor darkGrayColor];
    [KVNProgress appearance].errorColor = [UIColor darkGrayColor];
    [KVNProgress appearance].circleSize = 75.0f;
    [KVNProgress appearance].lineWidth = 2.0f;
    
    
    
    
}
- (IBAction)show
{
 
    [KVNProgress show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     //  [KVNProgress showErrorWithParameters:@{KVNProgressViewParameterStatus:@"网络连接失败"}];
    });
    
  //  [KVNProgress updateProgress:0 animated:YES];
    
   // [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updatePro:) userInfo:self repeats:YES];
}
-(void)updatePro:(NSTimer *)timer
{
    static float pro ;
    
    
    [KVNProgress updateProgress:pro animated:YES];
     
    [KVNProgress updateStatus:[NSString stringWithFormat:@"%d %% ",(int)(pro * 100)]];

    if (pro < 1) {
        pro += 0.01;
    }else
    {
        pro = 0 ;
    }
    
    
}

-(void)buildFileName
{   self.saveState = YES;
    [self showWithAnimate:YES withDuration:0.5];
}
-(void)openFileName
{
    self.saveState = NO;
    [self showWithAnimate:YES withDuration:0.5];
}
-(void)uploadFileNameData
{
    NSString *path =  [NSString stringWithFormat:@"%@/fileList.plist",[self pathForDocument]];
    [self.openFileNames writeToFile:path atomically:NO];
}
-(NSArray *)loadFileNameDateFormLocaDesk
{
    NSString *path =  [NSString stringWithFormat:@"%@/fileList.plist",[self pathForDocument]];
    return [NSArray arrayWithContentsOfFile:path];
}

-(void)removeOpenFileNamesAtIndexes:(NSIndexPath *)indexes 
{
  [[self mutableArrayValueForKey:@"openFileNames"] removeObjectAtIndex:indexes.row];
}
-(void)removeOpenFileNamesAtObject:(NSString *)object
{
    [[self mutableArrayValueForKey:@"openFileNames"] removeObject:object];
}
-(void)addOpenFileNamesWithObject:(NSString *)object
{
    [[self mutableArrayValueForKey:@"openFileNames"] addObject:object];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSLog(@"%@",self.openFileNames);
    if ([keyPath isEqualToString:@"openFileNames"]) {
        NSLog(@"监听者开始工作了 删除了文件 %@ \n %@  \n %@contex\n fileOptions%@",object,change[@"old"],context,self.fileopetions);
        
        if(change[@"old"])
        {
            NSString *fileName  = [(NSArray *)change[@"old"]firstObject] ;
            
            [self.fileopetions deleteFiles:fileName WithCompliment:nil];
            
        }
        if (change[@"new"]) {
            NSLog(@" 开始添加 ");
  //          [self saveProjectWithData:self.recvData fileName:self.selectFileName];
            [self.fileopetions saveFilesWithData:self.recvData fileName:self.selectFileName WithCompliment:nil];
            
        }
        
        [self uploadFileNameData];
        
    }
    
 
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"openFileNames"];
}

@end
