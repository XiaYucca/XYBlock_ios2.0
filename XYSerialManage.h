//
//  XYSerialManage.h
//  googleBlock2.0
//
//  Created by RainPoll on 16/4/1.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SerialGATT.h"



@interface XYSerialManage : NSObject

@property (nonatomic,strong) CBPeripheralManager * centralManager;
@property (nonatomic, copy)NSMutableArray *discoverPeripheral;
@property (nonatomic, assign)BOOL autoConnect;
@property (strong ,nonatomic) SerialGATT *serial;
@property (strong ,nonatomic)NSTimer *scanTimer;

-(void)blueToothScaning:(int)timerOut;
-(void)blueToothAutoScaning:(float)interval withTimeOut:(int)timeOut;

-(void)changleDiscoverPeripheral:(void(^)(NSArray *peripherals))discoverPeripherals;

-(void)sendData:(NSData *)data;


@end
