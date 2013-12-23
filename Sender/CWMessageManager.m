//
//  CWMessageManager.m
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMessageManager.h"
#import "AppDelegate.h"
#import "CWMessageCell.h"

@interface CWMessageManager ()
{
    BOOL useLocalServer;
    NSIndexPath * selectedIndexPath;
    UITableView * messageTable;
}
@end


@implementation CWMessageManager

- (id)init
{
    self = [super init];
    if (self) {
        useLocalServer = NO;
    }
    return self;
}

+(instancetype) sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [[super alloc] init];
    });
    return shared;
}


- (NSString *)baseEndPoint
{
    if (useLocalServer) {
        return @"http://192.168.0.10:1337";
    }
    
    
    NSInteger serverEnv = 0;
    //[[[NSUserDefaults standardUserDefaults] valueForKey:@"ServerEnvironment"]integerValue];
    if (serverEnv) {
        // development
        return @"http://chatwala-dev.azurewebsites.net";
    }else{
        // production
        return @"http://chatwala-prod.azurewebsites.net";
    }
}
#warning Need to update these names to better describe roles

- (NSString *)registerEndPoint
{
    return [[self baseEndPoint]stringByAppendingPathComponent:@"register"];
}


- (NSString *)messagesEndPoint
{
    return [[self baseEndPoint]stringByAppendingPathComponent:@"messages"];
}

- (NSString *)getUserMessagesEndPoint
{
    return [[self baseEndPoint]stringByAppendingString:@"/users/%@/messages"];
}

- (NSString *)getMessageEndPoint
{
    return [[self baseEndPoint]stringByAppendingString:@"/messages/%@"];
}


- (void)downloadMessageWithID:(NSString *)messageID progress:(void (^)(CGFloat progress))progressBlock completion:(void (^)(BOOL success, NSURL *url))completionBlock
{
    // check if file exists locally
    NSString * localPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[messageID stringByAppendingString:@".zip"]];
    if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        // don't download
        NSURL * localURL =[NSURL fileURLWithPath:localPath];
        if (completionBlock) {
            completionBlock(YES,localURL);
        }
    }else{
        
        // do download
        NSString * messagePath =[NSString stringWithFormat:[self getMessageEndPoint],messageID];
        NSLog(@"downloading file at: %@",messagePath);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURL *URL = [NSURL URLWithString:messagePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSProgress * progress;
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
        {
                                                                          
            NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
            return [documentsDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
            
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if(error)
            {
                NSLog(@"error %@", error);
                if (completionBlock) {
                    completionBlock(NO,filePath);//if we need to pass error/response adjust function callback
                }
            }
            else
            {
                NSLog(@"File downloaded to: %@", filePath);
                if (completionBlock) {
                    completionBlock(YES,filePath);
                }
            }
        }];
        
        [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
        [downloadTask resume];
    }
}


- (void)getMessages
{
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"CHATWALA_USER_ID"])
    {
        NSString * user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"CHATWALA_USER_ID"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString * url = [NSString stringWithFormat:[self getUserMessagesEndPoint],user_id] ;
        NSLog(@"fetching messages: %@",url);
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //
            NSLog(@"fetched user messages: %@",responseObject);
            self.messages = [responseObject objectForKey:@"messages"];
            [NC postNotificationName:@"MessagesLoaded" object:nil userInfo:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //
            NSLog(@"failed to fecth messages");
            [NC postNotificationName:@"MessagesLoadFailed" object:nil userInfo:nil];
//            [SVProgressHUD showErrorWithStatus:@"failed to fecth messages"];
        }];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    messageTable = tableView;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CWMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    NSDictionary * dict = [self.messages objectAtIndex:indexPath.row];
//    [cell.textLabel setText:[dict valueForKey:@"message_id"]];
//    [cell setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dict valueForKey:@"thumbnail"]]]]];
    [cell setMessageData:dict];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString * mid = [[self.messages objectAtIndex:indexPath.row] valueForKey:@"message_id"];
    
    [[CWMessageManager sharedInstance]downloadMessageWithID:mid  progress:nil completion:^(BOOL success, NSURL *url) {
        //
        AppDelegate * appdel = [[UIApplication sharedApplication] delegate];
        NSLog(@"Download Complete! %@",url);
        [appdel.drawController closeDrawerAnimated:YES completion:^(BOOL finished) {
            [appdel application:[UIApplication sharedApplication] openURL:url sourceApplication:nil annotation:nil];
        }];
    }];
    /*
    selectedIndexPath = indexPath;
    AppDelegate * appdel = [[UIApplication sharedApplication] delegate];
    NSDictionary * dict = [self.messages objectAtIndex:indexPath.row];
    
    
    
    NSString * localPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[[dict valueForKey:@"message_id"] stringByAppendingString:@".zip"]];
    
    NSLog(@"checking localPath: %@",localPath);
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        
        NSLog(@"MESSAGE ALREADY DOWNLOADED!!");
        [appdel.drawController closeDrawerAnimated:YES completion:^(BOOL finished) {
            [appdel application:[UIApplication sharedApplication] openURL:[NSURL URLWithString:localPath] sourceApplication:nil annotation:nil];
        }];
        
    }else{
    

        
        
        
        NSString * messagePath =[NSString stringWithFormat:[self getMessageEndPoint],[dict valueForKey:@"message_id"]];
        
        
        //        [SUBMIT_MESSAGE_ENDPOINT stringByAppendingPathComponent:[[url pathComponents] objectAtIndex:1]];
        
        NSLog(@"downloading file at: %@",messagePath);
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURL *URL = [NSURL URLWithString:messagePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        
        NSProgress * progress;
        
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
            return [documentsDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
            
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if(error)
            {
                NSLog(@"error %@", error);
            }
            else
            {
                NSLog(@"File downloaded to: %@", filePath);
                [appdel.drawController closeDrawerAnimated:YES completion:^(BOOL finished) {
                    [appdel application:[UIApplication sharedApplication] openURL:filePath sourceApplication:nil annotation:nil];
                }];
            }
        }];
        
        [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
        [downloadTask resume];
    }
     */
}

- (void)updateProgressView:(NSNumber*)p
{
//    [SVProgressHUD showProgress:p.floatValue status:@"loading message"];
    CWMessageCell *cell = (CWMessageCell *)[messageTable cellForRowAtIndexPath:selectedIndexPath];
    [cell setProgress:p.floatValue];
}

- (void)completedDownload
{
//    [SVProgressHUD showSuccessWithStatus:@"message loaded"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSProgress *progress = (NSProgress *)object;
    CGFloat p = progress.fractionCompleted;
    if (p < 1.0) {
        [self performSelectorOnMainThread:@selector(updateProgressView:) withObject:@(p) waitUntilDone:NO];
    }else{
        [self performSelectorOnMainThread:@selector(completedDownload) withObject:nil waitUntilDone:NO];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}


@end
