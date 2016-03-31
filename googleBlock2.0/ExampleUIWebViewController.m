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


#define animateViewWith 250

#define fileNameFromLocationDesk  @"fileList.plist"

#define CellField_tag 1000


//NSString *testConst;

const NSString *cellID = @"cell";

@interface ExampleUIWebViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate, MCSwipeTableViewCellDelegate>
@property WebViewJavascriptBridge* bridge;
@property (nonatomic,strong)UIView *animateView;
@property (nonatomic,copy)NSMutableArray *fileNames;
@property (nonatomic,copy)NSMutableArray *openFileNames;
@property (nonatomic,assign,getter=isSaveState)BOOL saveState;
@property (nonatomic,copy)NSString *selectFileName;
@property (nonatomic,assign)BOOL saveBool;

@property (nonatomic,copy)NSString *recvData;
@property (nonatomic,copy)NSString *sendData;

@property (nonatomic,weak)UITableView *fileList;

@property (nonatomic,strong)JSWebViewController *jsWebView;
@property (nonatomic,weak)UIWebView *webView;
@property (nonatomic ,strong)FileOptions* fileopetions ;



@end

@implementation ExampleUIWebViewController

-(void)viewDidLoad
{
    self.selectFileName = @"projectName";
}
-(void)viewDidAppear:(BOOL)animated
{
 //   [self loadJSWebView:self.webView];
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
    }
    return _openFileNames;
}

-(NSMutableArray *)fileNames
{
    if (!_fileNames) {
        _fileNames = [@[@"projectName"]mutableCopy];
    }
    return _fileNames;
}

-(UIView *)animateView{
    if (!_animateView) {
        [self LoadCustomView];
    }
    return _animateView;
}

-(void)LoadCustomView
{
    UIView *animareView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width, 0,animateViewWith , self.view.frame.size.height)];
    
    
    [animareView setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, animareView.frame.size.width, animareView.frame.size.height-30)];
    
    self.fileList = tableView;
    
    UIButton *btn_save = [[UIButton alloc]initWithFrame:CGRectMake(30, animareView.frame.size.height-30, 70, 30)];
    [btn_save setTitle:@"save" forState:UIControlStateNormal];
    
    [btn_save addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn_cansale = [[UIButton alloc]initWithFrame:CGRectMake(animareView.frame.size.width-30-50, animareView.frame.size.height-30, 70, 30)];
    
    [btn_cansale setTitle:@"cancel" forState:UIControlStateNormal];
    [btn_cansale addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    btn_cansale.tag = 20;
    btn_save.tag = 10;
    
    [animareView addSubview:btn_save];
    [animareView addSubview:btn_cansale];
    
    
    
//   tableView.backgroundColor = [UIColor clearColor];
    
//   [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
   // [XYSwiperCell registNibFormTableView:tableView forCellReuseIdentifier:@"cell"];
     //[tableView registerClass:[XYSwiperCell class] forCellReuseIdentifier:@"cell"];
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
    
    UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    
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
    self.fileopetions  = [[FileOptions alloc]init];
    
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
                [self saveProjectWithData:self.recvData fileName:self.selectFileName];
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
        return self.fileNames.count;
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
        field.text = self.fileNames[indexPath.row];
        field.enabled = YES;
    
    }else
    {
        field.text = self.openFileNames[indexPath.row];
        field.enabled = NO;
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
    
   return cell;
}
-(void)deleateCell:(id)sender
{
    XYSwiperCell *cell = sender;
    NSIndexPath *cellIndex = [self.fileList indexPathForCell:cell];
    [self.openFileNames removeObjectAtIndex:cellIndex.row];
    
    [self.fileList reloadData];
    
    NSLog(@"cell  ------ <<>\n%@\n index ---- %@",cell,cellIndex);
    
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
    }
}

#pragma mark - mcstableViewDelegate
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    
    NSIndexPath *cellIndex = [self.fileList indexPathForCell:cell];
    
    [self.openFileNames removeObjectAtIndex:cellIndex.row];
    
    [self.fileList reloadData];
    
    NSLog(@"cell  ------ <<>\n%@\n index ---- %@",cell,cellIndex);

}


#pragma -mark textfield delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.selectFileName = [textField.text copy];
    [self uploadFileNameData];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length) {
        
        if ([self.fileNames containsObject:textField.text]) {
            
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"项目名重复是否覆盖" preferredStyle:    UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [controller addAction:action];
            
            [self presentViewController:controller animated:YES completion:nil ];
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



-(void)saveProjectWithData:(NSString *)strData fileName:(NSString *)fileName
{
    NSString *path = [self pathForDocument];
    path = [NSString stringWithFormat:@"%@/%@",path,fileName];

    NSLog(@"savePath%@",path);
    [strData writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    if(![self.openFileNames containsObject:fileName])
    {
        
            [self.openFileNames addObject:fileName];
    }
    
    
    [self uploadFileNameData];
    
    
}
-(NSString *)openProjectWithFileName:(NSString *)fileName
{
    NSString *path = [self pathForDocument];
    path = [NSString stringWithFormat:@"%@/%@",path,fileName];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSString *str_temp = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    return str_temp;
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

@end
