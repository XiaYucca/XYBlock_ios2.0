
//
//  XYNetworkInterface.m
//  test
//
//  Created by RainPoll on 16/2/26.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#import "XYNetworkInterface.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
//#import "AFNetworking.h"
#import "AFURLSessionManager.h"
#import "AFHTTPSessionManager.h"
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"

//#import "AFHTTPRequestManager.h"


#define baseURL [NSURL URLWithString:baseUrlString]

//服务器密钥
const NSString *secriteKey = @"cf0bdfe00e9332d64bfbab9d760e309b0fb46d1a";
//const NSString *baseUrlString = @"http://arduinoapi.alsrobot.cn/";

const NSString *baseUrlString = @"http://arduinoapi.alsrobot.cn/";
const NSString *loginUrl =  @"http://arduinoapi.alsrobot.cn/ident/login";

const NSString *uploadUrl = @"http://arduinoapi.alsrobot.cn/upload/file";
const NSString *downloadUrl = @"http://arduinoapi.alsrobot.cn/handle/download";
const NSString *compileUrl = @"http://arduinoapi.alsrobot.cn/handle/compile";


const NSString *statusParametersError = @"-1";
const NSString *statusFileNotFound = @"-2";
const NSString *statusCompliFailued = @"-3";
const NSString *statusSuccesed = @"1";
const NSString *statusLoginFailued =@"-99";




static id sessionManager;
//服务器参数
@implementation XYNetworkInterface
{
    AFHTTPSessionManager *manager;
}

-(instancetype)init
{
    if (self = [super init]) {
        manager = [AFHTTPSessionManager manager];
    }
    return self;
}


-(NSString *)getUUID
{
    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
//  NSString *identifierForAdvertising = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
//  NSLog(@"UUID---:%@",identifierForVendor);
//  [NSURL URLWithString:baseUrlString];
    return identifierForVendor;
}

-(NSString *)getTimestamp
{
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    
  NSLog(@"++++++++%ld""""""""\n", time(NULL));  // 这句也可以获得时间戳，跟上面一样，精确到秒
  NSLog(@"时间戳getTime:%@\n",timeString);

    return timeString;
}

-(NSString *)getMD5String:(NSString *)orgString
{
    NSString *result = [self XYMD5String:orgString];
    NSLog(@"\nMD5---->\n%@\n",result);
    return result;
}

-(NSString *)XYMD5String:(NSString *)inPutText
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

-(NSString *)createToken:(NSString *)privateKey
{
    return [self getMD5String:[NSString stringWithFormat:@"%@%@%@",[self getUUID],[self getTimestamp],privateKey]];
}

#pragma mark- 网络数据层
//原生post
-(void)postInformtion:(NSString *)information :(NSData *)data
{
    // 1. URL
    NSURL *url = [NSURL URLWithString:@"http://localhost/login.php"];
    
    // 2. 请求(可以改的请求)
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // ? POST
    // 默认就是GET请求
    request.HTTPMethod = @"POST";
    // ? 数据体
    //    NSString *str = information;
    // 将字符串转换成数据
    request.HTTPBody =  data; //[str dataUsingEncoding:NSUTF8StringEncoding];
    
    // 3. 连接,异步
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError == nil) {
            // 网络请求结束之后执行!
            // 将Data转换成字符串
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            // num = 2
            NSLog(@"%@ %@", str, [NSThread currentThread]);
            
            // 更新界面
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                NSLog(@"post 上传成功");
                
            }];
        }
        else
        {
            NSLog(@"post error %@",connectionError);
        }
    }];
    
    // num = 1
    NSLog(@"come here %@", [NSThread currentThread]);
    
}

//下载数据
-(void)Information:(NSURL *)url
{
    NSLog(@"开始连接网络\n");
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"\ndownProgress%@\n",downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSLog(@"\ntargetPath:\n%@,\nrespose:\n%@\n",targetPath,response);
        return  [NSURL URLWithString:@"/Users/rainpoll/Desktop/AFNetWorking/test.png"];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"\nresponse%@,\nfilepath:\n%@\n",response,filePath);
    }];

    [downloadTask resume];
    
}

-(void)XYNetworkingPost:(NSString *)baseUrlstr parameters:(id)parameters
success:(void(^)( id  _Nullable responseObject))success
failue:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failue
{
   
    // 初始化请求的manager对象
   //  manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSURLSessionDataTask *task = [manager POST:baseUrlstr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        !success?:success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failue? :failue(task,error);
    }];
    
    [task resume];
}

//封装的get请求方法:
-(void)XYNetworkingGet:(NSString *)baseUrlstr parameters:(id)parameters
                   success:(void(^)( id  _Nullable responseObject))success
                    failue:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failue
{
        // 初始化请求的manager对象
       // AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

     manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
     NSURLSessionDataTask*task = [manager GET:baseUrlstr parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
      //   NSLog(@"%@\n",downloadProgress);
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       //  NSLog(@"sessionData%@ \nsuccess -- %@\n",task,responseObject);
         
         !success ? : success(responseObject);
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failue? :failue(task,error);
     }];
    
    [task resume];
}

-(void)XYNetworkingUploadWithRequest:(NSString *)uploadUrlstr
                            fromFile:(NSURL *)fileURL
                            progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                   completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
 
    
//    NSURL *URL = [NSURL URLWithString:@"http://example.com/upload"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
 //   NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
      NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:uploadUrlstr]];
      
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:fileURL progress:^ (NSProgress *uploadProgress){
        !uploadProgressBlock ?: uploadProgressBlock(uploadProgress);
    }completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
          NSLog(@"Error: %@", error);
           // !uploadProgressBlock ?:uploadProgressBlock(response,);
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
        }
        !completionHandler ? :completionHandler(response,responseObject,error);
    }];
    [uploadTask resume];
    
    
    
    
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    
//    NSURL *URL = [NSURL URLWithString:@"http://example.com/upload"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    
//    NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
//    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"Success: %@ %@", response, responseObject);
//        }
//    }];
//    [uploadTask resume];
    
    
    
    
}


-(void)compileInformationWithDictionary:(NSDictionary *)dic
{
   // NSJSONSerialization
    
 //   /Users/rainpoll//Library/Application Support/Developer/Shared/Xcode/Plug-ins/
}
@end

@implementation NetworkConnect{
    
    XYNetworkInterface *netWork;
}

-(instancetype)init
{
    if (self = [super init]) {
        netWork  = [[XYNetworkInterface alloc]init];
    }
    return self;
}

-(networkingStatus)login:(void(^)(bool isSuccessed))compliment
{
    NSDictionary *parameters = @{
                                 @"token":[netWork createToken:secriteKey],
                                 @"device_id":[netWork getUUID],
                                 @"time":[netWork getTimestamp]
                                 };
    
    [netWork XYNetworkingGet:loginUrl parameters:parameters success:^(id  _Nullable responseObject) {
       
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        
        if (dict[@"status"]>0) {
            NSLog(@"登陆成功");
            !compliment?:compliment(YES);
        }
        NSLog(@"login ---%@",dict);
        
    } failue:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"login error%@",error);
        !compliment?:compliment(NO);
    }];
    return 1;
}
-(networkingStatus)upload:(void(^)(NSString* file_hash))complilment
{
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"Info.plist" ofType:nil];
    NSURL *fileUrl = [NSURL URLWithString:filePath];
    NSLog(@"bundle %@\n\n  filePath%@",[NSBundle mainBundle],fileUrl);
    
    
    [netWork XYNetworkingUploadWithRequest:uploadUrl fromFile:fileUrl progress:^(NSProgress *uploadProgress) {
        NSLog(@"%@",uploadProgress);
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"\n---jason ---\n%@",dict);
        !complilment? :complilment(nil);
    }];
    return 1;
}

-(void)mutiPartUpload:(NSString *)filePath compliment:(void(^)(NSString* file_hash))complilment{
    
NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:uploadUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    
//    NSString *filePathstr = [[[NSBundle mainBundle]bundlePath ]stringByAppendingString:@"/testBund/ardunio_test.c" ];
//    NSLog(@"\n filepath%@",filePathstr);
//    
    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
    
    [formData appendPartWithFileURL:filePathUrl name:@"file" fileName:@"file.ino" mimeType:@"file" error:nil];
} error:nil];
   // NSLog(@"formdata-----%@!\n",formData);

AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

NSURLSessionUploadTask *uploadTask;
uploadTask = [manager
              uploadTaskWithStreamedRequest:request
              progress:^(NSProgress * _Nonnull uploadProgress) {
                  // This is not called back on the main queue.
                  // You are responsible for dispatching to the main queue for UI updates
                  NSLog(@"upload Progress%@\n",uploadProgress);
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                    //Update the progress view
                    //  [progressView setProgress:uploadProgress.fractionCompleted];
                  });
              }
              completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                  if (error) {
                      NSLog(@"Error: %@", error);
                        !complilment ?:complilment(nil);
                  } else {
                      NSLog(@"upload--responseObject- :%@\n  ",responseObject);
                      NSDictionary *dict = responseObject;

                      NSInteger status = ((NSString*)dict[@"status"]).integerValue;
                      if (status>0) {
                          NSDictionary *dict_temp  = dict[@"obj"];
                          NSLog(@"\nupload---dict%@\n",dict_temp);
                          NSString* obj;
                          if (dict_temp) {
                              obj = dict_temp[@"file_hash"];
                          }
                          NSLog(@"上传文件成功");
                          !complilment ?:complilment(obj);
                      }
                      else
                      {    NSLog(@"文件错误");

                          !complilment ?:complilment(nil);
                      }
                    }
              }];

[uploadTask resume];
}

-(networkingStatus)post
{
      
    [self beforeUpload];
       NSString *filePath = [[[NSBundle mainBundle]bundlePath ]stringByAppendingString:@"/testBund/ardunio_test.c" ];
    NSLog(@"mainBund;%@\n filepath%@",[NSBundle mainBundle],filePath);
    [netWork XYNetworkingPost:uploadUrl parameters:[NSData dataWithContentsOfFile:filePath] success:^(id  _Nullable responseObject) {
        NSLog(@"success");
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"\n---jason ---\n%@",dict);
        
        [self behandUpload];
        
    } failue:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error");
    }];
    return 1;
}

-(void)behandUpload
{
    NSString *kServerAddress = @"";
    NSString *kUserDefaultsCookie = @"";
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString:kServerAddress]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefaultsCookie];
}
-(void)beforeUpload
{
    NSString *kServerAddress = @"";
    NSString *kUserDefaultsCookie = @"";
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCookie];
    if([cookiesdata length]) {
        　　NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        　　NSHTTPCookie *cookie;
        　　　　for (cookie in cookies) {
            　　　　[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            　　}  
    }
}

-(networkingStatus)compile:(NSString *)file_hash compliment:(void(^)(bool isSuccessed))complliment
{
    NSDictionary *parameters = [@{
                                 @"file":file_hash
                                 }copy];
    
    [netWork XYNetworkingGet:compileUrl parameters:parameters success:^(id  _Nullable responseObject) {
//        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"compile >>>>>>>>>>%@\n",dict[@"status"]);
        if ( [dict[@"status"]floatValue]>0) {
            NSLog(@"编译文件成功\n");
            !complliment?:complliment(YES);
        }else
        {
            !complliment?:complliment(NO);

        }
    } failue:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"ERROR%@",error);
          !complliment?:complliment(NO);
    }];
    return 1;

}

-(networkingStatus)downLoad:(NSString *)file_hash savePath:(NSString *)filePath
{
    __block int state = 0;

    NSDictionary *parameters = [@{
                                  @"file":file_hash
                                  }copy];
    
    [netWork XYNetworkingGet:downloadUrl parameters:parameters success:^(id  _Nullable responseObject) {
        //
        NSLog(@"down  responseObject%@",responseObject);
        
       NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        
       NSLog(@"down ---dict%@",dict);
       
        if (dict[@"status"]) {
            NSLog(@"文件下载成功");
            NSDictionary *strdata = dict[@"obj"];
            NSLog(@"file data ---%@",strdata[@"content"]);
            
            [strdata[@"content"] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            state = netStatusUploadSuccesed;
        }
        
        else
        {
            NSLog(@"下载文件出错");
            state = netStatusCompliFailued;
        }
    } failue:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"ERROR%@",error);
        
        state = netStatusCompliFailued;
    }];
    return state;
}




@end


