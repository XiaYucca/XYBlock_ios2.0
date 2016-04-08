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
//@property (strong ,nonatomic)NSTimer *scanTimer;
@property (nonatomic,copy) void(^changlePeripherals)(NSArray * peripherals);

@end

@implementation XYSerialManage

//-(void)setBtnRediex:(CGFloat)
#pragma mark - serialDelegate

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
    //    NSLog(@"array --->%@",peripheral);
    //   [self.discoverPeripheral addObject:peripheral];
    if (![self.discoverPeripheral containsObject:peripheral]) {
        
        [[self mutableArrayValueForKey:@"discoverPeripheral"] addObject:peripheral];
    }
}

-(void)peripheralFound:(CBPeripheral *)peripheral andRSSI:(NSNumber *)RSSI
{
    NSLog(@"peripheral-->%@  //// %d  autoConnect****%@",peripheral, RSSI.intValue,[NSString stringWithFormat:@"%i", self.autoConnect]);
    
    if (RSSI.intValue > -50 && self.autoConnect) {
        //  self.serial.activePeripheral = peripheral;
        [self unenableAutoScaning];
        [self.serial.manager stopScan];
        [self.serial connect:peripheral];
    }
    
}
- (void) periphereDidConnect:(CBPeripheral *)peripheral
{
    
  //  self.stateImageView.image = [UIImage imageNamed:@"tishi2"];
    
}
- (void) peripheralMissConnect:(CBPeripheral *)peripheral
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"蓝牙断开连接" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIPreviewActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [[alert.view superview]bringSubviewToFront:alert.view];
    
    [alert addAction:action];
    
   [[[UIApplication sharedApplication]keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
       // 
}

-(void)serialGATTCharValueUpdated:(NSString *)UUID value:(NSData *)data
{
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到的数据有%@",str );
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
-(void)blueToothScaning:(int)timerOut
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


-(void)blueToothAutoScaning:(float)interval withTimeOut:(int)timeOut
{
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(autoscaning:) userInfo:[NSNumber numberWithInt:interval] repeats:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self unenableAutoScaning];
        
    });
    self.scanTimer = timer;
    self.autoConnect = YES;
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

-(void)sendData:(NSData *)data
{
    [self.serial write:self.serial.activePeripheral data:data];
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
                CBPeripheral *per = obj;
                ! per.name ?:[perM addObject:per.name];
            }];
          //  weakSelf.setMask.dataSource = [perM copy];
            !self.discoverPeripheral? : self.changlePeripherals([perM copy]);
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
