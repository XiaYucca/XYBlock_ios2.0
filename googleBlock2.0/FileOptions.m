//
//  FileOptions.m
//  googleBlock2.0
//
//  Created by RainPoll on 16/3/29.
//  Copyright © 2016年 RainPoll. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "FileOptions.h"
#import "XYNetworkInterface.h"
#import "KVNProgress.h"

@interface FileOptions ()

@property (nonatomic ,strong)NetworkConnect* netTool;
@property (nonatomic,copy)NSString *file_hash;



@end
@implementation FileOptions
-(NetworkConnect *)netTool
{
    if (!_netTool) {
        _netTool = [[NetworkConnect alloc]init];
    }
    return _netTool;
}

-(void)setFiledata:(NSString *)filedata
{
    if (filedata.length) {
        
        NSString *filePath = [NSString stringWithFormat:@"%@%@",[self pathForDocument],@"/test_ino.ino"];
 
        
        [filedata writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        NSLog(@"\n\nfilePath---->%@",filePath);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self connectUploadFile:filePath downPath:[NSString stringWithFormat:@"%@%@",[self pathForDocument],@"/downFile.hex"]];
        });

    }
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
    __weak FileOptions* weakSelf = self;
    
    NSLog(@"开始上传");
    
    [self.netTool login:^(bool isSuccessed) {
        if (isSuccessed) {
            
            [weakSelf.netTool mutiPartUpload:uploadPath compliment:^(NSString *file_hash) {
                self.file_hash = file_hash;
                NSLog(@"file_hash:%@",file_hash);
                //HUD dissmiss
                [KVNProgress dismiss];
                
                if (self.file_hash.length) {
                    [weakSelf.netTool compile:file_hash compliment:^(bool isSuccessed) {
                        
                        if (isSuccessed) {
                           networkingStatus state  = [weakSelf.netTool downLoad:file_hash savePath:downPath];
                            NSLog(@"编译成功");
                         
                           
                            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"编译成功" message:@"是否烧录" preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction *action = [UIAlertAction actionWithTitle:@"不烧录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                
                            }];
                          UIAlertAction *actionBluth = [UIAlertAction actionWithTitle:@"烧录" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                
                            }];
                            [alertC addAction:action];
                            [alertC addAction:actionBluth];
    
                           [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertC animated:NO completion:nil];
                            
                            
                           
                            
                        }else{
                            [weakSelf.netTool downLoad:file_hash savePath:downPath];
                            NSLog(@"编译失败");
                            
                            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"编译失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                
                            }];
                            
                            [alertC addAction:action];
                            
                            
                            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertC animated:NO completion:nil];
                         
                        }
                        
                    }];
                    
                    
                }
                
            }];
            
        }
    }];
}





@end
