//
//  ZPFileChannel_DropBox.m
//  ZotPad
//
//  Created by Mikko Rönkkö on 18.3.2012.
//  Copyright (c) 2012 Helsiki University of Technology. All rights reserved.
//

#import "ZPFileChannel_Dropbox.h"
#import <DropboxSDK/DropboxSDK.h>
#import "ZPPreferences.h"
#import "ASIHTTPRequest.h"
#import "ZPLogger.h"
#import "ZPServerConnection.h"

@implementation ZPFileChannel_Dropbox

-(id) init{
    
    self = [super init]; 
    DBSession* dbSession =
    [[DBSession alloc]
     initWithAppKey:@"or7xa2bxhzit1ws"
     appSecret:@"6azju842azhs5oz"
     root:kDBRootAppFolder];
    [DBSession setSharedSession:dbSession];
    
    progressViewsByRequest = [[NSMutableDictionary alloc] init];

    return self;
}

-(void) startDownloadingAttachment:(ZPZoteroAttachment*)attachment{
    
    if([[ZPPreferences instance] useDropbox]){
        
        //Link with dropBox account if not already linked
        
        if (![[DBSession sharedSession] isLinked]) {
            [[DBSession sharedSession] link];
        }

        //TODO: consider pooling these
        DBRestClient* restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
        
        NSString* tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"ZP%@%i",attachment.key,[[NSDate date] timeIntervalSince1970]*1000000]];
        
        [self linkAttachment:attachment withRequest:restClient];

        [restClient loadFile:[NSString stringWithFormat:@"/%@/%@",attachment.key,attachment.title] intoPath:tempFile];
    }
    // If Dropbox is not in use, just notify that we are done
    else [[ZPServerConnection instance] finishedDownloadingAttachment:attachment toFileAtPath:NULL usingFileChannel:self];

}
-(void) cancelDownloadingAttachment:(ZPZoteroAttachment*)attachment{

    DBRestClient* restClient = [self requestWithAttachment:attachment];
    
    [restClient cancelFileLoad:[NSString stringWithFormat:@"/%@/%@",attachment.key,attachment.title]];
    [self cleanupAfterFinishingAttachment:attachment];
}
-(void) useProgressView:(UIProgressView*) progressView forAttachment:(ZPZoteroAttachment*)attachment{


    DBRestClient* restClient = [self requestWithAttachment:attachment];

    @synchronized(progressViewsByRequest){
        [progressViewsByRequest setObject:progressView forKey:[self keyForRequest:restClient]];
    }
}
- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath{

    @synchronized(progressViewsByRequest){
        UIProgressView* progressView = [progressViewsByRequest objectForKey:[self keyForRequest:client]];
        if(progressView!=NULL) [progressView setProgress:progress];
    }
}
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    
    ZPZoteroAttachment* attachment = [self attachmentWithRequest:client];
    [[ZPServerConnection instance] finishedDownloadingAttachment:attachment toFileAtPath:localPath usingFileChannel:self];
    [self cleanupAfterFinishingAttachment:attachment];

}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    NSLog(@"There was an error loading the file - %@", error);

    ZPZoteroAttachment* attachment = [self attachmentWithRequest:client];
    [[ZPServerConnection instance] finishedDownloadingAttachment:attachment toFileAtPath:NULL usingFileChannel:self];

    [self cleanupAfterFinishingAttachment:attachment];

}

-(void) cleanupAfterFinishingAttachment:(ZPZoteroAttachment*)attachment{
    
    @synchronized(progressViewsByRequest){
        [progressViewsByRequest removeObjectForKey:[self keyForRequest:[self requestWithAttachment:attachment]]];
    }
    [super cleanupAfterFinishingAttachment:attachment];
}

@end