//
//  NSData+SubData.m
//  googleBlock2.0
//
//  Created by RainPoll on 16/4/19.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import "NSData+SubData.h"

@implementation NSData (SubData)

-(void)subDataWithLength:(NSInteger)Length findCallBack:(void(^)(NSData *findData, int index ,bool *stop))callBack
{

    NSInteger orgLength = self.length;
    NSRange curRange = NSMakeRange(0, Length);
    
    int index = 0;
    bool stop = NO;
    
    while((orgLength - curRange.location ) > Length) {
        
        NSData *subData = [self subdataWithRange:curRange];
        
        curRange = NSMakeRange(curRange.location + curRange.length , curRange.length);
        
        callBack(subData ,index ++, &stop);
        
        if (stop) {
            return ;
        }
    }
    
    if((orgLength - curRange.location ) > 0)
    {
        curRange = NSMakeRange(curRange.location,orgLength - curRange.location);
        
        NSData *subData = [self subdataWithRange:curRange];
        
        callBack(subData,index ++, &stop);
    }
    
   
}



@end
