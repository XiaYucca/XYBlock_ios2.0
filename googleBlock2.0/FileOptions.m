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
#import "SetMaskView.h"

#import "XYSerialManage.h"

@interface FileOptions ()<UIAlertViewDelegate>

@property (nonatomic ,strong)NetworkConnect* netTool;
@property (nonatomic,copy)NSString *file_hash;
@property (nonatomic ,strong)SetMaskView *setMask;
@property (nonatomic ,strong)XYSerialManage *xySerialManage;
@property (nonatomic ,copy)NSArray *dataTemp;


@end
@implementation FileOptions

-(NetworkConnect *)netTool
{
    if (!_netTool) {
        _netTool = [[NetworkConnect alloc]init];
    }
    return _netTool;
}
-(void)setDataTemp:(NSArray *)dataTemp
{
    if (_dataTemp != dataTemp) {
        _dataTemp = dataTemp;
        
        self.setMask.dataSource = dataTemp;
        
        NSLog(@"setMaskViewData--%@\n",dataTemp);
    }
}


-(XYSerialManage *)xySerialManage
{
    if (!_xySerialManage) {
        _xySerialManage = [[XYSerialManage alloc]init];
        
        [_xySerialManage changleDiscoverPeripheral:^(NSArray *peripherals) {
            NSLog(@"changle----peri %@",peripherals);
            self.dataTemp = peripherals;
        }];
    }
    return _xySerialManage;
    
}

-(SetMaskView *)setMask
{
    if (!_setMask) {
        _setMask = [SetMaskView setMaskView];
    }
    return _setMask;
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
              
                
                if (self.file_hash.length) {
                    [weakSelf.netTool compile:file_hash compliment:^(bool isSuccessed) {
                         [KVNProgress dismiss]; 
                        if (isSuccessed) {
                           networkingStatus state  = [weakSelf.netTool downLoad:file_hash savePath:downPath];
                            NSLog(@"编译成功");
                         
                          /*
                           UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"编译成功" message:@"是否烧录" preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction *action = [UIAlertAction actionWithTitle:@"烧录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                
                                 [weakSelf loadSetView];
                            }];
                          UIAlertAction *actionBluth = [UIAlertAction actionWithTitle:@"不烧录" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                              
                           
                                
                            }];
                            [alertC addAction:action];
                            [alertC addAction:actionBluth];
    
                           [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertC animated:NO completion:nil];
                         */
                            
                          UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"编译成功" message:@"是否烧录" delegate:self cancelButtonTitle:@"不烧录" otherButtonTitles:@"烧录", nil];
                            alert.tag = 1;
                            [alert show];
                          
                            
                            
                           
                            
                        }else{
                            /*  [weakSelf.netTool downLoad:file_hash savePath:downPath];
                            NSLog(@"编译失败");
                            
                            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"编译失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                
                            }];
                            
                            [alertC addAction:action];
                            
                            
                            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertC animated:NO completion:nil];
                            
                            */
                        
                          UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"编译失败" message:@"数据错误" delegate:self cancelButtonTitle:@"好的" otherButtonTitles: nil];
                            alert.tag = 2;
                            [alert show];
                             
                            
                        }
                        
                    }];
                    
                    
                }
                
            }];
            
        }
    }];
}

//-(void)loadSetView
//{
//    self.setMask = [SetMaskView setMaskView];
//    [_setMask maskViewShowWithComplement:nil];
//}

-(void)loadSetView
{
    __block NSString *perName;
    
    __weak  XYSerialManage *manager = self.xySerialManage;
    __weak  FileOptions *weakSelf = self;
    
    SetMaskView *setView = self.setMask;
  
    self.xySerialManage.discoverPeripheral = nil;
//  self.xySerialManage.stateImageView.image = [UIImage imageNamed:@"tishi1"];
    
    [setView maskViewEasyLinkCallBack:^{
        [manager blueToothAutoScaning:1.1 withTimeOut:10];
    }];
    
    [setView maskViewSeachCallBack:^{
        [manager blueToothScaning:10];
    }];
    
    [setView maskViewLinkCallBack:^{
        [self.xySerialManage.discoverPeripheral enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([((NSString *)perName) isEqualToString: ((CBPeripheral *)obj).name]) {
               
                NSLog(@"uuidS ----\n%@", ((CBPeripheral *)obj).services);
                
                if (((CBPeripheral *)obj).services) {
                    
                    [manager.serial connect:obj];
                     [weakSelf  writeProgram];
                }
                else{
                    UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"提示" message:@"类型不匹配" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
                    [aler show];
                }
            }
        }];
    }];
    
    [setView maskViewStatueCallBack:^(BOOL *state){
      //  *state = _blueToothStatus;   //设置界面的蓝牙状态
        [manager blueToothScaning:1]; //进去第一次 默认第一次进去就扫描一次
    }];
    
    
    [setView maskViewTableViewDidSelectRowAtIndexPath:^(NSIndexPath *index, id itemInArray) {
        
        perName = [((NSString *)itemInArray)copy];
        
    }];
    
    [setView maskViewShowWithComplement:^(BOOL *state){
       // *state = _blueToothStatus;
        
        [manager blueToothScaning:1];
//      [weakSelf UIanimation:YES];
    }];
//    [setView maskViewBackBtnCallBack:^{
//       // [weakSelf UIanimation:NO];
//    }];
    NSLog(@"setView%@",setView);

}


-(void)writeProgram
{
    NSError *error = [[NSError alloc]init];
    NSString *hexFilePath = [NSString stringWithFormat:@"%@%@",[self pathForDocument],@"/downFile.hex"];
    [self.xySerialManage sendData:[NSData dataWithContentsOfFile:hexFilePath options:NSDataReadingMappedIfSafe error: &error]];
    
    if (error) {
        NSLog(@"senddata ERROR!--------%@",error);
    }
}

-(void)deleteFiles:(NSString *)fileName WithCompliment:(void (^)(bool successed))compliment
{
    NSLog(@"开始删除文件");
 
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSString *MapLayerDataPath = [NSString stringWithFormat:@"%@/%@",[self pathForDocument],fileName];
    BOOL bRet = [fileMgr fileExistsAtPath:MapLayerDataPath];
    
    NSLog(@"filePath%@",MapLayerDataPath);
    if (bRet) {
        //
        NSError *err;
        [fileMgr removeItemAtPath:MapLayerDataPath error:&err];
        if (err) {
            NSLog(@"删除文件失败%@",err);
            !compliment?: compliment(NO);
        }
        else{
            !compliment?: compliment(YES);
            NSLog(@"删除文件成功");
        
        }
            
    }else
    {
        NSLog(@"文件不存在");
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex %i",buttonIndex);
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
           
         //   [[UIApplication sharedApplication].keyWindow addSubview:self.setMask];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               
                 [self loadSetView];
                 NSLog(@"测试 setView%@,", [self.setMask subviews] );
            });
        }
    }
}

-(void)dealloc
{
    NSLog(@"fileOptions delloc");
}




@end
