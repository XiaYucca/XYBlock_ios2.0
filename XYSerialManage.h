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

//#define  autoConnectDistance -50

@interface XYSerialManage : NSObject

@property (nonatomic,strong) CBPeripheralManager * centralManager;
@property (nonatomic, copy)NSMutableArray *discoverPeripheral;
@property (strong ,nonatomic) SerialGATT *serial;

/**
 *  蓝牙扫描一次
 *
 *  @param timerOut 超时时间 如果超时了停止扫描
 */
-(void)blueToothScaning:(float)timerOut;

/**
 *  蓝牙自动扫描 自动连接
 *
 *  @param interval 每次扫描时间
 *  @param timeOut  总超时 时间
 *  @param distance 自动连接的距离(信号强度 1米以内 信号强度和距离成正比)
 */
-(void)blueToothAutoScaning:(float)interval withTimeOut:(float)timeOut autoConnectDistance:(CGFloat)distance didConnected:(void (^)(CBPeripheral *peripheral))callBack timeOutCallback:(void (^)())timeOutCallback;

/**
 *  查找设备
 *
 *  @param callBack 查找到设备回调 peripheral :查找到的设备 RSSI:信号强度
 */
-(void)finedPeripheral:(void(^)(CBPeripheral *peripheral , NSNumber *RSSI))callBack;

/**
 *  连接设备
 *
 *  @param peripheral 连接的设备
 *  @param response   连接完成回调
 */

-(void)connect:(CBPeripheral *)peripheral response:(void(^)(bool isSuccessed , CBPeripheral *peripheral))response;

/**
 *  发现所有设备
 *
 *  @param discoverPeripherals 一旦发现新设备会更新列表
 */
-(void)changleDiscoverPeripheral:(void(^)(NSArray *peripherals))discoverPeripherals;

/**
 * 断开连接
 *
 *
 */
-(void)disConnectPeripheral:(CBPeripheral *)peripheral ;

/*
 * 失去连接
 * @param callback 失去连接的回调函数
 */
-(void)misConnect:(void(^)(CBPeripheral *peripheral))callback;


/*
 * 蓝牙写数据
 * @param 发送的数据
 */
-(void)writeData:(NSData *)data;
/*
 *  蓝牙接受 数据发送状态的回调
 *  @param updateValue 接收到数据的回调
 */
-(void)writeDataWithResponse:(NSData *)data response:(void(^)(BOOL success))response;

/*
 * 查找设备时 改变设备
 * @param 改变时的回调 返回所用设备列表
 */
-(void)peripheralValueChangle:(void(^)(CBPeripheral *peripheral , NSData *data))updateValue;

//-(void)sendData:(NSData *)data;


@end
