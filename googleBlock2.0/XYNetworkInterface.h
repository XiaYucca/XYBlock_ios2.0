//
//  XYNetworkInterface.h
//  test
//
//  Created by RainPoll on 16/2/26.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYNetworkInterface : NSObject

-(NSString *)getUUID;
-(NSString *)getTimestamp;
//-(void)postInformtion:(NSString *)information :(NSData *)data;
-(NSString *)getMD5String:(NSString *)orgString;

-(NSString *)createToken:(NSString *)privateKey;

-(void)Information:(NSURL *)url;




#pragma mark - get post 方法
-(void)XYNetworkingGet:(NSString *)baseUrlstr parameters:(id)parameters
                   success:(void(^)( id  _Nullable responseObject))success
                    failue:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failue;

-(void)XYNetworkingPost:(NSString *)baseUrlstr parameters:(id)parameters
                    success:(void(^)( id  _Nullable responseObject))success
                     failue:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failue;

-(void)XYNetworkingUploadWithRequest:(NSString *)uploadUrlstr
                            fromFile:(NSURL *)fileURL
                            progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                   completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

@end

@interface NetworkConnect : NSObject

typedef enum{
    netStatusParametersError ,
    netStatusFileNotFound ,
    netStatusCompliFailued  ,
    netStatusUploadSuccesed ,
    netStatusLoginFailued
} networkingStatus;

-(networkingStatus)login;
-(networkingStatus)login:(void(^)(bool isSuccessed))compliment;
-(networkingStatus)upload;
-(networkingStatus)upload:(void(^)(NSString* file_hash))complilment;
-(networkingStatus)post;
-(void)mutiPartUpload:(NSString *)filePath compliment:(void(^)(NSString* file_hash))complilment;
-(networkingStatus)compile:(NSString *)file_hash compliment:(void(^)(bool isSuccessed))complliment;
-(networkingStatus)downLoad:(NSString *)file_hash savePath:(NSString *)filePath;

@end
