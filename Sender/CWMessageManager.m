//
//  CWMessageManager.m
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMessageManager.h"
#import "AppDelegate.h"

@interface CWMessageManager ()

@end


@implementation CWMessageManager
+(instancetype) sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [[super alloc] init];
    });
    return shared;
}

- (void)getMessages
{
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"CHATWALA_USER_ID"])
    {
        NSString * user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"CHATWALA_USER_ID"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString * url = [NSString stringWithFormat:@"%@/users/%@/messages",BASE_URL_ENDPOINT,user_id] ;
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    NSDictionary * dict = [self.messages objectAtIndex:indexPath.row];
    [cell.textLabel setText:[dict valueForKey:@"message_id"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate * appdel = [[UIApplication sharedApplication] delegate];
    NSDictionary * dict = [self.messages objectAtIndex:indexPath.row];
    
    NSString * messagePath =[NSString stringWithFormat:@"%@/%@",MESSAGE_ENDPOINT,[dict valueForKey:@"message_id"]];
    //        [SUBMIT_MESSAGE_ENDPOINT stringByAppendingPathComponent:[[url pathComponents] objectAtIndex:1]];
    
    NSLog(@"downloading file at: %@",messagePath);
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:messagePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
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
    
    [downloadTask resume];
    
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

@end
