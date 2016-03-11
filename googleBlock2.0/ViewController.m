//
//  ViewController.m
//  googleBlock2.0
//
//  Created by RainPoll on 16/2/22.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import "ViewController.h"
#import "XYNetworkInterface.h"

@interface ViewController ()<UIWebViewDelegate>

@property (nonatomic ,strong)UIWebView *webView;
@property (nonatomic ,strong)NetworkConnect* netTool;
@property (nonatomic,copy)NSString *file_hash;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.webView = [self.view viewWithTag:100];
    self.webView.delegate = self;
    self.netTool = [[NetworkConnect alloc]init];
    
    

    //  NSString *filePath = [[NSBundle mainBundle]pathForResource:@"index" ofType:@"html"];
    
    NSString *contentPath = [NSBundle mainBundle].bundlePath;
    // NSLog(@"%@",contentPath);
    // NSLog(@"------>%@",[NSBundle allBundles]);
    
    //   NSDirectoryEnumerator *enumertor = [manager enumeratorAtPath:contentPath];
    
    NSString *newPath = [NSString stringWithFormat:@"%@/BlocklyDuino-gh-pages/blockly/apps/blocklyduino/index.html",contentPath];
    
    
    NSString *htmlString = [NSString stringWithContentsOfFile:newPath encoding:NSUTF8StringEncoding error:nil];
    
    //   NSArray *path =[manager contentsOfDirectoryAtPath:contentPath error:nil];
    
    
  //   NSLog(@"path ---%@\nhtmlString---%@",newPath,htmlString);
    
    [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:newPath]];
    
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


- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
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
 
    
//    return  (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  (CFStringRef)unicodeStr, nil, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    
        
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
    __weak ViewController* weakSelf = self;
    
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
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.netTool mutiPartUpload:uploadPath compliment:^(NSString *file_hash) {
//                self.file_hash = file_hash;
//                NSLog(@"file_hash:%@",file_hash);
//            }];
//    });
    
//    [self.netTool mutiPartUpload:uploadPath compliment:^(NSString *file_hash) {
//        self.file_hash = file_hash;
//        NSLog(@"file_hash:%@",file_hash);
//    }];
//    
//    [self.netTool compile:self.file_hash];
//    
//    [self.netTool downLoad:self.file_hash];
    
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
