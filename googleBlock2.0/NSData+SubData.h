//
//  NSData+SubData.h
//  googleBlock2.0
//
//  Created by RainPoll on 16/4/19.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SubData)


-(void)subDataWithLength:(NSInteger)Length findCallBack:(void(^)(NSData *findData, int index ,bool *stop))callBack;

@end
