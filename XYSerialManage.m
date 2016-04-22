//
//  XYSerialManage.m
//  googleBlock2.0
//
//  Created by RainPoll on 16/4/1.
//  Copyright © 2016年 RainPoll. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "XYSerialManage.h"
#import "SerialGATT.h"


@interface XYSerialManage ()<BTSmartSensorDelegate,CBPeripheralManagerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>

//@property (nonatomic,strong) CBPeripheralManager * centralManager;
//@property (nonatomic, copy)NSMutableArray *discoverPeripheral;
//@property (nonatomic, assign)BOOL autoConnect;
//@property (strong ,nonatomic) SerialGATT *serial;
@property (nonatomic, assign)BOOL autoConnect;
@property (strong ,nonatomic)NSTimer *scanTimer;
@property (nonatomic,copy) void(^changlePeripherals)(NSArray * peripherals);

@property (nonatomic,copy) void(^connectResponse)(bool isSuccessed,CBPeripheral *peripheral);
@property (nonatomic,copy) void(^misConnectCallback)(CBPeripheral *peripheral);
@property (nonatomic,copy) void(^findedPeripheralcallBack)(CBPeripheral *peripheral , NSNumber *RSSI);
@property (nonatomic,copy) void(^updteValue)(CBPeripheral *peripheral , NSData *data);

@property (nonatomic,copy) void(^autoConnectCallBack)(CBPeripheral *peripheral);


 
@end

@implementation XYSerialManage
{
    float autoConnectDistance;
    bool timeOutFlag;
}

//-(void)setBtnRediex:(CGFloat)
#pragma mark - serialDelegate

/*
 
 -(void)connect:(CBPeripheral *)peripheral response:(void(^)(bool isSuccessed))response;
 -(void)misConnect:(void(^)(CBPeripheral *peripheral))callback;
 -(void)finedPeripheral:(void(^)(CBPeripheral *peripheral , NSNumber *RSSI))callBack;
 -(void)disConnectPeripheral:(CBPeripheral *)peripheral ;
 
 -(void)writeData:(NSData *)data;
 
 -(void)peripheralValueChangle:(void(^)(CBPeripheral *peripheral , NSData *data))updateValue;
 
 */

-(void)connect:(CBPeripheral *)peripheral response:(void (^)(bool, CBPeripheral *))response
{
    self.connectResponse = response;
}

-(void)misConnect:(void (^)(CBPeripheral *))callback
{
    self.misConnectCallback = callback;
}
-(void)finedPeripheral:(void (^)(CBPeripheral *, NSNumber *))callBack
{
    self.findedPeripheralcallBack = callBack;
}

-(void)peripheralValueChangle:(void (^)(CBPeripheral *, NSData *))updateValue
{
    self.updteValue = updateValue;
}
-(void)disConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.serial disconnect:peripheral];
}

-(NSMutableArray *)discoverPeripheral
{
    if (!_discoverPeripheral) {
        _discoverPeripheral = [@[]mutableCopy];
 
    [self addObserver:self forKeyPath:@"discoverPeripheral" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return _discoverPeripheral;
}

-(instancetype)init
{
    if (self = [super init]) {
        [self serialSetUp];
    }
    
    return self;
}


-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
  //      self.blueToothStatus = YES;
        NSLog(@"蓝牙打开");
        break;
        
//        default: self.blueToothStatus = NO;
        break;
    }
}
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
    switch (peripheral.state) {
        //蓝牙开启且可用
        case CBPeripheralManagerStatePoweredOn:
        NSLog(@"蓝牙设备可用");
        break;
        default:
        break;
    }
}


-(void) peripheralFound:(CBPeripheral *)peripheral
{
        NSLog(@"array --->%@",peripheral);
    //   [self.discoverPeripheral addObject:peripheral];
    if (![self.discoverPeripheral containsObject:peripheral]) {
        
        [[self mutableArrayValueForKey:@"discoverPeripheral"] addObject:peripheral];
        
        }
}

-(void)peripheralFound:(CBPeripheral *)peripheral andRSSI:(NSNumber *)RSSI
{
    NSLog(@"peripheral-->%@  //// %d  autoConnect****%@",peripheral, RSSI.intValue,[NSString stringWithFormat:@"%i", self.autoConnect]);

    ! self.findedPeripheralcallBack ? : self.findedPeripheralcallBack(peripheral,RSSI);
    
    if (RSSI.intValue > autoConnectDistance && self.autoConnect) {
        //  self.serial.activePeripheral = peripheral;
        [self.serial.manager stopScan];
        [self.serial connect:peripheral];
        
        timeOutFlag = NO;
    
    }
    
}
- (void) periphereDidConnect:(CBPeripheral *)peripheral
{
    ! self.connectResponse ? :self.connectResponse(YES,peripheral);
    if (self.autoConnect && self.autoConnectCallBack) {
        self.autoConnectCallBack (peripheral);
    }
    [self unenableAutoScaning];
}


- (void) peripheralMissConnect:(CBPeripheral *)peripheral
{
    ! self.misConnectCallback ? : self.misConnectCallback(peripheral);
    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"蓝牙断开连接" preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIPreviewActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    
//    [[alert.view superview]bringSubviewToFront:alert.view];
//    
//    [alert addAction:action];
//    
//   [[[UIApplication sharedApplication]keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
       //
}

-(void)serialGATTCharValueUpdated:(NSString *)UUID value:(NSData *)data
{
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到的数据有%@",str );
    
    !self.updteValue? : self.updteValue(self.serial.activePeripheral,data);
}


#pragma mark - 蓝牙
-(void)blueToothConnect
{
    if (self.serial.activePeripheral) {
        [self.serial disconnect:self.serial.activePeripheral];
    }
    
    //  self.serial.activePeripheral = controller.peripheral;
    NSLog(@"%@",self.serial.activePeripheral);
    
    [self.serial connect:self.serial.activePeripheral];
}


// scan peripher onece time
-(void)blueToothScaning:(float)timerOut
{
    
    [self.serial.manager stopScan];
    if ([self.serial activePeripheral]) {
        if (self.serial.activePeripheral.state == CBPeripheralStateConnected) {
            [self.serial.manager cancelPeripheralConnection:self.serial.activePeripheral];
            self.serial.activePeripheral = nil;
        }
    }
    if ([self.serial peripherals]) {
        self.serial.peripherals = nil;
    }
    printf("now we are searching device...\n");
    
    //  [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    
    // [self.serial findBLKSoftPeripherals:5];
    [self.serial findBLKSoftPeripherals:timerOut];
}


-(void)blueToothAutoScaning:(float)interval withTimeOut:(float)timeOut autoConnectDistance:(CGFloat)distance didConnected:(void (^)(CBPeripheral *peripheral))callBack timeOutCallback:(void (^)())timeOutCallback
{
    
    self.autoConnect = YES;
    timeOutFlag = YES;
    
    autoConnectDistance = distance;
    
    self.autoConnectCallBack = callBack;
    
   
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self unenableAutoScaning];
        
        if (timeOutFlag)
        {
        !timeOutCallback ? : timeOutCallback();
            NSLog(@"连接蓝牙超时");
        }
        
    });
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval+0.2 target:self selector:@selector(autoscaning:) userInfo:[NSNumber numberWithInt:interval] repeats:YES];
    
    self.scanTimer = timer;
}

-(void)autoscaning:(NSTimer *)timer
{
    int timerOut =  [((NSNumber *)timer.userInfo)intValue];
    [self blueToothScaning:timerOut];
}
-(void)unenableAutoScaning
{
    self.autoConnect = NO;
    [self.serial.manager stopScan];
    [self.scanTimer invalidate];
    self.scanTimer = nil;
    
}
-(void)sendStr:(NSString *)str
{
    [self.serial write:self.serial.activePeripheral data:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)serialSetUp
{
    SerialGATT *serial = [[SerialGATT alloc]init];
    self.centralManager = [[CBPeripheralManager alloc]init];
    [serial setup];
    serial.delegate = self;
    self.serial = serial;
}

-(void)writeData:(NSData *)data
{
    [self.serial write:self.serial.activePeripheral data:data];
}
-(void)writeDataWithResponse:(NSData *)data response:(void (^)(BOOL))response
{
    [self.serial writeWithResponse:self.serial.activePeripheral data:data response:response];
}


-(void)changleDiscoverPeripheral:(void(^)(NSArray *peripherals))discoverPeripherals
{
    self.changlePeripherals = discoverPeripherals;
}

#pragma mark - obser method

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    __weak XYSerialManage *weakSelf = self;
    if ([keyPath isEqualToString:@"discoverPeripheral"]) {
        
        CBPeripheral *per = [change[@"new"]lastObject];
        
        if (per.name) {
            
            NSMutableArray *perM = [@[]mutableCopy];
            [self.discoverPeripheral enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CBPeripheral *pers = obj;
                ! pers.name ?:[perM addObject:pers];
            }];
          //  weakSelf.setMask.dataSource = [perM copy];
            !self.changlePeripherals? : self.changlePeripherals([perM copy]);
        }
        //       else
        //        {
        //            NSMutableArray *perM = [@[]mutableCopy];
        //            [self.discoverPeripheral enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //                CBPeripheral *per = obj;
        //                ! per.name ?:[perM addObject:per.name];
        //            }];
        //            weakSelf.setMaskView.dataSource = [perM copy];
        //        }
        //
    }
}

#pragma mark - override delloc
-(void)dealloc{
    
    [self removeObserver:self forKeyPath:@"discoverPeripheral"];
    
}




@end
