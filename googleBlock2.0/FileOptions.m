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
#import "NSData+SubData.h"
#import "XYSerialManage.h"
#import "LeafProgressView.h"
#import "KVNProgress.h"


@interface FileOptions ()<UIAlertViewDelegate>

@property (nonatomic ,strong)NetworkConnect* netTool;
@property (nonatomic,copy)NSString *file_hash;
@property (nonatomic ,strong)SetMaskView *setMask;
@property (nonatomic ,strong)XYSerialManage *xySerialManage;
@property (nonatomic ,copy)NSArray *dataTemp;

@property (nonatomic ,strong)LeafProgressView *progressView;

@property (nonatomic,copy)NSArray *sendBuffArr;


@end
@implementation FileOptions
{
    NSMutableString *sendDat;
}

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
        
        NSMutableArray *arrM = [@[]mutableCopy];
        [dataTemp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         
            [arrM addObject: ((CBPeripheral *)obj).name];
           
        }];
        
        self.setMask.dataSource = arrM;
        
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


#pragma mark- file options
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


-(void)saveFilesWithData:(NSString *)strData fileName:(NSString *)fileName WithCompliment:(void (^)(bool successed))compliment

{
    NSString *path = [self pathForDocument];
    path = [NSString stringWithFormat:@"%@/%@",path,fileName];
    
    NSLog(@"savePath%@",path);
    
       NSError *err;
    [strData writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err];
    
    if (err) {
        NSLog(@"添加文件失败%@",err);
        !compliment?: compliment(NO);
    }
    else{
        !compliment?: compliment(YES);
        NSLog(@"添加文件成功");
        
    }

}

//-(void)loadSetView
//{
//    self.setMask = [SetMaskView setMaskView];
//    [_setMask maskViewShowWithComplement:nil];
//}
#warning no used
-(void)loadSetView
{
    __block NSString *perName;
    
    
    __weak  FileOptions *weakSelf = self;
    
    XYSerialManage *manager = weakSelf.xySerialManage;
 
    
    SetMaskView *setView = self.setMask;
  
    self.xySerialManage.discoverPeripheral = nil;
//  self.xySerialManage.stateImageView.image = [UIImage imageNamed:@"tishi1"];
    
//   [setView maskViewEasyLinkCallBack:^{
//        [manager blueToothAutoScaning:1.1 withTimeOut:10 autoConnectDistance:-];
//    }];
    
    [setView maskViewSeachCallBack:^{
        [manager blueToothScaning:10];
    }];
    
    [setView maskViewLinkCallBack:^{
        
        NSLog(@" discover  %@",manager.discoverPeripheral);
    
        [self.dataTemp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CBPeripheral *perObj = obj;
            if ([ perObj.name isEqualToString:perName]){
                [manager.serial connect:perObj];
                manager.serial.activePeripheral = perObj;
                *stop = YES;
            }
        }];
    }] ;
    
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
    [setView maskViewBackBtnCallBack:^{
//       // [weakSelf UIanimation:NO];
      //  sendDat = [@""mutableCopy];
       // [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(repeatSendData:) userInfo:nil repeats:YES];
        [weakSelf writeProgram];
    }];
    NSLog(@"setView%@",setView);

}

#pragma mark- blueTooth connect
-(void)autoConnctAndSend
{   __weak  FileOptions *weakSelf = self;

    
    [self.xySerialManage blueToothAutoScaning:1 withTimeOut:15 autoConnectDistance:-50 didConnected:^(CBPeripheral *peripheral) {
        NSLog(@"连接成功");
        // [ weakSelf.manage sendData:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [weakSelf writeProgram];
    } timeOutCallback:^{
        [KVNProgress showErrorWithStatus:@"没有连接到设备,请确保设备正常"];
    }];

}
//
-(void)loadleafView
{
    self.progressView = [[LeafProgressView alloc]initWithFrame:CGRectMake(30, (SCREEN_HEIGHT-35)*0.5, 400, 35)];
    self.progressView.center = CGPointMake(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.65);
   // [self.view addSubview:_progressView];
    [[UIApplication sharedApplication].keyWindow addSubview:_progressView];
    
    [_progressView startLoading];
}

-(void)writeProgram
{
    
    NSString *hexFilePath = [NSString stringWithFormat:@"%@%@",[self pathForDocument],@"/downFile.hex"];
    NSData *data = [NSData dataWithContentsOfFile:hexFilePath options:NSDataReadingMappedIfSafe error: nil];

    NSLog(@"%@ -------------data %@",hexFilePath,data);
    
    NSMutableArray *arr = [@[]mutableCopy];
    
    [data subDataWithLength:50 findCallBack:^(NSData *findData, int index, bool *stop) {
        [arr addObject:findData];
    }];
    NSLog(@"arr.count %lu",arr.count);
    self.sendBuffArr = [arr copy];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self sendDataMain:nil];
    });
   
    [KVNProgress show];
  //  [self loadleafView];
   
}
#pragma mark - autoSendData
-(void)sendDataBackground:(NSData *)data
{
    
    [self.xySerialManage writeDataWithResponse:data response:^(BOOL success) {
        NSLog(@"传输完成");
        [ self performSelectorOnMainThread:@selector(sendDataMain:) withObject:nil waitUntilDone:YES];
    }];
}

-(void)sendDataMain:(id)index
{
   
   
    static int index_arr = 0;
    
    float progressV =((float)index_arr)/((float)self.sendBuffArr.count);
    
    [self.progressView setProgress:progressV];
    
    
    
    [KVNProgress updateProgress:progressV animated:YES];
    [KVNProgress updateStatus:[NSString stringWithFormat:@"%d %%",(int)(progressV*100)]];
    
     NSLog(@"main loadSend data>>>>>>>>>>> %lf",progressV);
    
    if (index_arr  < self.sendBuffArr.count) {
        [self performSelectorInBackground:@selector(sendDataBackground:) withObject:[self.sendBuffArr objectAtIndex:index_arr ++]];
    }else
    {
        [self.xySerialManage disConnectPeripheral:self.xySerialManage.serial.activePeripheral];
        index_arr = 0;
  
        [KVNProgress showSuccessWithStatus:@"烧录完成"];
    }
}


-(void)seriaWriteData:(NSString *)dataStr
{
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [self.xySerialManage.serial write:self.xySerialManage.serial.activePeripheral data:data];
}




#pragma mark - alertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex %i",buttonIndex);
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
           
         //   [[UIApplication sharedApplication].keyWindow addSubview:self.setMask];
            
            [KVNProgress showWithStatus:@"请将手机靠近蓝牙接收器"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               
                [self autoConnctAndSend];
    
            });
        }
    }
}






@end
