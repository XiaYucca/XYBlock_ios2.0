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

@end
