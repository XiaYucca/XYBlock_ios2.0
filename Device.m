//
//  Device.m
//  googleBlock2.0
//
//  Created by RainPoll on 16/4/7.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import "Device.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>


@implementation Device

//-(CGSize) getScreenSize {
//        CGSize screenSize = [UIScreen mainScreen].bounds.size;
//    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) &&
//        UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
//        return CGSizeMake(screenSize.height, screenSize.width);
//    }
//    return screenSize;
//}
//

CGSize getDevieceScreenSize()
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) &&
        UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    return screenSize;

}



NSString * getUUID()
{
    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    //  NSString *identifierForAdvertising = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
    //  NSLog(@"UUID---:%@",identifierForVendor);
  //  [NSURL URLWithString:baseUrlString];
    return identifierForVendor;
}

NSString * getTimestamp()
{
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    
    NSLog(@"++++++++%ld""""""""\n", time(NULL));  // 这句也可以获得时间戳，跟上面一样，精确到秒
    NSLog(@"时间戳getTime:%@\n",timeString);
    
    return timeString;
}

NSString * getMD5String(NSString *orgString)
{
    NSString *result = XYMD5String(orgString);
    NSLog(@"\nMD5---->\n%@\n",result);
    return result;
}

NSString * XYMD5String(NSString *inPutText)
{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12],result[13],result[14], result[15]
             ] lowercaseString];
}

@end
