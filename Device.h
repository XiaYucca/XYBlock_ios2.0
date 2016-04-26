//
//  Device.h
//  googleBlock2.0
//
//  Created by RainPoll on 16/4/7.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>


@interface Device : NSObject


CGSize getDevieceScreenSize();
NSString * getUUID();
NSString * getTimestamp();
NSString * getMD5String(NSString *orgString);
NSString * XYMD5String(NSString *inPutText);

@end
