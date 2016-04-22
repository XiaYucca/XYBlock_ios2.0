//
//  DownImageViewController.m
//  googleBlock2.0
//
//  Created by RainPoll on 16/4/14.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import "DownImageViewController.h"
#import "NSString+FindString.h"
#import "XYSerialManage.h"

@interface DownImageViewController ()

@property (nonatomic, copy)NSMutableArray *arr;
@property (nonatomic, strong)XYSerialManage *manage;

@end

@implementation DownImageViewController

-(void)viewDidLoad
{
    NSString *contentPath = [NSBundle mainBundle].bundlePath;
    NSString *newPath = [NSString stringWithFormat:@"%@/BlocklyDuino-pages/blockly/blocks_compressed.js",contentPath];
    NSError *error;
    
    
    
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *sourceString = [NSString stringWithContentsOfFile:newPath encoding:NSUTF8StringEncoding error:&error];
    if(error)
    {
        NSLog(@"文件打开错误");
        
    }else
    {
        NSLog(@"文件打开成功");
    }
    
    self.manage = [[XYSerialManage alloc]init];
    
    [self.manage finedPeripheral:^(CBPeripheral *peripheral, NSNumber *RSSI) {
        NSLog(@"found peripheral %@ rssi is %@",peripheral.name,RSSI );
        
    }];
    __weak DownImageViewController *weakSelf = self;
//    
//    [self.manage blueToothAutoScaning:1 withTimeOut:20 autoConnectDistance:-50 didConnected:^(CBPeripheral *periapheral) {
//        NSLog(@"连接成功");
//       // [ weakSelf.manage sendData:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
//
//    }];
    UIButton *btn = [self.view viewWithTag:100];
    
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

-(void)btnClick:(id)sender
{
   
    
    [self.manage writeDataWithResponse:[@"test" dataUsingEncoding:NSUTF8StringEncoding] response:^(BOOL success) {
        NSLog(@"收到数据");
    }];
}


-(NSString *)findStringFromString:(NSString *)fromString PrefixString:(NSString *)preStr SuffixString:(NSString *)sufStr IntervalLength:(int)interval finedContentString:(void (^)(int index , NSString **instanteStr))callBack
{
    NSMutableString *fromStringM = [fromString mutableCopy];
  
    NSRange fixRange = NSMakeRange(0,fromStringM.length);
    
    int index = 0;
    
    while (fixRange.length)  {
        
        NSRange fileRange = NSMakeRange(0,fromStringM.length);
        
        fixRange = [fromStringM rangeOfString:preStr options:nil range:NSMakeRange(fixRange.location + 1, fileRange.length - fixRange.location - 1)];
        
        if (fixRange.length == 0) {
            break;
        }
    NSRange   tempRange = NSMakeRange(fixRange.location + 1, interval);
        
    NSRange tailRange = [fromStringM rangeOfString:sufStr options:nil range:tempRange];
    
        if (tailRange.length) {
            NSInteger sufOffset =  sufStr.length;
            if ([sufStr containsString:@"\""]) {
                sufOffset -= 1;
            }
            
           
            NSRange tempRange = NSMakeRange(fixRange.location + fixRange.length,tailRange.location - fixRange.location - fixRange.length + sufOffset);
            

               NSString *subString = [fromStringM substringWithRange:tempRange];
               NSString *instant = [subString copy];
            
               callBack(index ++, &instant);
            
            
               if (![instant isEqualToString:subString]) {
                
                NSLog(@"将%@替换为%@, 位置%@\n",subString,instant,NSStringFromRange(tempRange));

                [fromStringM deleteCharactersInRange:tempRange];
     
                [fromStringM insertString:instant atIndex:tempRange.location];
    
            }
        }
          
        
        
    };
    return [fromStringM copy];
}

-(void)downloadImage:(NSString *)imageUrlString
{
    NSURL *url = [NSURL URLWithString:imageUrlString];
    
    NSString *path = [NSString stringWithFormat:@"/Users/rainpoll/Desktop/背景图/%@",[imageUrlString lastPathComponent]];
    
    NSError *error;
    
    NSData *imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        NSLog(@"下载文件失败");
    }else
    {
        NSLog(@"下载文件成功");
        [imageData writeToFile:path atomically:YES];
    UIImage *image = [UIImage imageWithData:imageData];
        
    }
    
}



@end

