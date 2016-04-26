//
//  FileOptions.h
//  googleBlock2.0
//
//  Created by RainPoll on 16/3/29.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileOptions : NSObject

@property (nonatomic,copy)NSString *filedata;

-(void)deleteFiles:(NSString *)fileName WithCompliment:(void (^)(bool successed))compliment;
-(void)saveFilesWithData:(NSString *)strData fileName:(NSString *)fileName WithCompliment:(void (^)(bool successed))compliment;

@end
