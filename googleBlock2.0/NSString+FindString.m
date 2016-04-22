//
//  NSString+FindString.m
//  googleBlock2.0
//
//  Created by RainPoll on 16/4/14.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import "NSString+FindString.h"

@implementation NSString (FindString)



-(NSString *)findStringByPrefixString:(NSString *)preStr SuffixString:(NSString *)sufStr IntervalLength:(int)interval finedContentString:(void (^)(int index , NSString **instanteStr ,bool *stop))callBack
{
    NSMutableString *fromStringM = [self mutableCopy];
    
    NSRange fixRange = NSMakeRange(0,fromStringM.length);
    
    int index = 0;
    
    bool stop = NO;
    
    while (fixRange.length)  {
        
        NSRange fileRange = NSMakeRange(0,fromStringM.length);
        
        fixRange = [fromStringM rangeOfString:preStr options:nil range:NSMakeRange(fixRange.location + 1, fileRange.length - fixRange.location - 1)];
        
        if (fixRange.length == 0) {
            break;
        }
        NSRange   tempRange = NSMakeRange(fixRange.location + 1, interval);
        
        NSRange tailRange = [fromStringM rangeOfString:sufStr options:nil range:tempRange];
        
        if (tailRange.length) {
            NSInteger sufOffset =  sufStr.length;
            if ([sufStr containsString:@"\""]) {
                sufOffset -= 1;
            }
            
            
            NSRange tempRange = NSMakeRange(fixRange.location + fixRange.length,tailRange.location - fixRange.location - fixRange.length + sufOffset);
            
            
            NSString *subString = [fromStringM substringWithRange:tempRange];
            NSString *instant = [subString copy];
            
            callBack(index ++, &instant, &stop);
            
            if (stop) {
                return [fromStringM copy];
            }
            
            
            if (![instant isEqualToString:subString]) {
                
                NSLog(@"将%@替换为%@, 位置%@\n",subString,instant,NSStringFromRange(tempRange));
                
                [fromStringM deleteCharactersInRange:tempRange];
                [fromStringM insertString:instant atIndex:tempRange.location];
                
            }
        }
        
        
        
    };
    return [fromStringM copy];
}


@end
