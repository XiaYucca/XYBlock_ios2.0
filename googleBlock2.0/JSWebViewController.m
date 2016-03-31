//
//  ViewController.m
//  googleBlock2.0
//
//  Created by RainPoll on 16/2/22.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import "JSWebViewController.h"
#import "XYNetworkInterface.h"
#import "WebViewJavascriptBridge.h"
/**
 
    这个使用 webView原生的代理方法 
    注意这个和buridge的底层有冲突所以 注意
 **/


@interface JSWebViewController ()<UIWebViewDelegate>


@property (nonatomic ,strong)NetworkConnect* netTool;
@property (nonatomic,copy)NSString *file_hash;

@property (nonatomic ,strong)WebViewJavascriptBridge *bridge;

@end

@implementation JSWebViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    
 /*   UIButton *button= [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 60)];
    
    button.backgroundColor = [UIColor redColor];
    
    [button addTarget:self action:@selector(btnCallHandler:) forControlEvents:UIControlEventTouchUpInside
     ];
    
    [self.view addSubview:button];
 
    
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, button.frame.size.height, self.view.frame.size.width, self.view.frame.size.height- button.frame.size.height)];
    [self.view addSubview:self.webView];

*/
    
   
}

-(void)setWebView:(UIWebView *)webView
{
    if (_webView != webView ) {
        _webView = webView;
        _webView.delegate = self;
        self.netTool = [[NetworkConnect alloc]init];
        
        NSLog(@"%@",webView);
    }
}

-(void)loadBridge
{
    if (_bridge) { return; }
    
    [WebViewJavascriptBridge enableLogging];
    
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    
    [self.bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@\n", data);
        responseCallback(@"test oc registerHander_data");
    }];
    NSLog(@"------%@",_bridge);
//    [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready"}];
    
//    [self renderButtons:webView];
//    [self loadExamplePage:webView];
}
-(void)viewWillAppear:(BOOL)animated
{
  //  [self loadBridge];
  //  [_bridge send:]
}


- (IBAction)btnCallHandler:(id)sender {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    id dataXml=@"<xml xmlns=\"http://www.w3.org/1999/xhtml\"><block type=\"controls_if\" id=\"47\" inline=\"false\" x=\"63\" y=\"38\"><mutation else=\"1\"></mutation><value name=\"IF0\"><block type=\"grove_button\" id=\"41\"><field name=\"PIN\">3</field></block></value><statement name=\"DO0\"><block type=\"grove_rgb_led\" id=\"21\"><mutation items=\"2\" rgb0=\"#660000\" rgb1=\"#660000\"></mutation><field name=\"PIN\">1</field><field name=\"RGB0\">#660000</field><field name=\"RGB1\">#000099</field></block></statement><statement name=\"ELSE\"><block type=\"grove_rgb_led\" id=\"52\"><mutation items=\"2\" rgb0=\"#006600\" rgb1=\"#006600\"></mutation><field name=\"PIN\">1</field><field name=\"RGB0\">#006600</field><field name=\"RGB1\">#663366</field></block></statement></block></xml>";
    [self.bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"++++++++++testJavascriptHandler responded: %@", response);
    }];
}

#warning 删除了html中的 lcd分类  如果需要则添加到 html中的"奥松马达"之前的位置
/*
    <!-->
    <category name="奥松 LCD">
    <block type="grove_serial_lcd_print">
    <value name="TEXT">
    <block type="text">
    <field name="TEXT"></field>
    </block>
    </value>
    <value name="TEXT2">
    <block type="text">
    <field name="TEXT"></field>
    </block>
    </value>
    <value name="DELAY_TIME">
    <block type="math_number">
    <field name="NUM">1000</field>
    </block>
    </value>
    </block>
    <block type="grove_serial_lcd_power"></block>
    <block type="grove_serial_lcd_effect"></block>
    </category> <-->
  */


- (BOOL)webView_delete:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [[request URL] absoluteString];
    
    NSLog(@"\n unicode to utf\n%@",[self replaceUnicode:urlString]);
    

    
    urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"urlString=%@\n",urlString);
        NSArray *urlComps = [urlString componentsSeparatedByString:@"blockly/apps/blocklyduino/"];
    NSMutableString *result = [[urlComps objectAtIndex:1]mutableCopy];
    NSRange range = [result rangeOfString:@"index.html"];
    if (range.length) {
        [result deleteCharactersInRange:range];
    }
    result = [result stringByReplacingOccurrencesOfString:@".h>" withString:@".h>\n"];
   
    NSString *filePath = [NSString stringWithFormat:@"%@%@",[self pathForDocument],@"/test_ino.ino"];
   // [result appendFormat:@"\nvoid main()\n{\nsetup();\n while(1){\nloop();\n }\n}"];
    NSLog(@"\n\n %@",result);
    
    [result writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"\n\nfilePath---->%@",filePath);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
          [self connectUploadFile:filePath downPath:[NSString stringWithFormat:@"%@%@",[self pathForDocument],@"/downFile.hex"]];
    });
    
    // NSLog(@"%@",request);
    return  YES;
}

- (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *outputStrCode = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)unicodeStr,NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
    
    
    
    NSMutableString *outputStr = [NSMutableString stringWithString:outputStrCode];
    
    [outputStr replaceOccurrencesOfString:@"+"
     
                               withString:@" "
     
                                  options:NSLiteralSearch
     
                                    range:NSMakeRange(0, [outputStrCode length])];
    
    
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
       // return outputStr;
        
    
}

-(NSString *)pathForDocument
{
    //1，获取家目录路径的函数：
   NSString *homeDir = NSHomeDirectory();
    //2，获取Documents目录路径的方法：
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
   NSString *docDir = [paths objectAtIndex:0];
    return [NSHomeDirectory()stringByAppendingPathComponent:@"Documents"];
}

-(void)connectUploadFile:(NSString *)uploadPath downPath:(NSString *)downPath
{
  //  [self.netTool login];
    __weak JSWebViewController* weakSelf = self;
    
    [self.netTool login:^(bool isSuccessed) {
        if (isSuccessed) {
         
            [weakSelf.netTool mutiPartUpload:uploadPath compliment:^(NSString *file_hash) {
                self.file_hash = file_hash;
                NSLog(@"file_hash:%@",file_hash);
                
                if (self.file_hash.length) {
                    [weakSelf.netTool compile:file_hash compliment:^(bool isSuccessed) {
                        
                        if (isSuccessed) {
                            [weakSelf.netTool downLoad:file_hash savePath:downPath];
                        }
                        
                    }];

                    
                }
                
            }];

        }
    }];
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
