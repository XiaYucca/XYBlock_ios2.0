//
//  NSString+FindString.h
//  googleBlock2.0
//
//  Created by RainPoll on 16/4/14.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FindString)

-(NSString *)findStringByPrefixString:(NSString *)preStr SuffixString:(NSString *)sufStr IntervalLength:(int)interval finedContentString:(void (^)(int index , NSString **instanteStr ,bool *stop))callBack;

@end
