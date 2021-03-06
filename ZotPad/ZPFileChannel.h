//
//  ZPFileChannel.h
//  ZotPad
//
//  Created by Mikko Rönkkö on 18.3.2012.
//  Copyright (c) 2012 Mikko Rönkkö. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZPFileUploadManager.h"
#import "ZPFileDownloadManager.h"
#import "ASIHTTPRequest.h"



@interface ZPFileChannel : NSObject {
    NSMutableDictionary* _requestsByAttachment;
}

+(ZPFileChannel*) fileChannelForAttachment:(ZPZoteroAttachment*) attachment;
+(NSInteger) activeUploads;
+(NSInteger) activeDownloads;
+(void) removeProgressView:(UIProgressView*) progressView;

-(void) startDownloadingAttachment:(ZPZoteroAttachment*)attachment;
-(void) cancelDownloadingAttachment:(ZPZoteroAttachment*)attachment;
-(void) useProgressView:(UIProgressView*) progressView forDownloadingAttachment:(ZPZoteroAttachment*)attachment;
-(int) fileChannelType;


-(void) startUploadingAttachment:(ZPZoteroAttachment*)attachment overWriteConflictingServerVersion:(BOOL)overwriteConflicting;
-(void) cancelUploadingAttachment:(ZPZoteroAttachment*)attachment;
-(void) useProgressView:(UIProgressView*) progressView forUploadingAttachment:(ZPZoteroAttachment*)attachment;


-(void) removeProgressView:(UIProgressView*) progressView;
-(NSArray*) allRequests;

//Helper methods

-(void) cleanupAfterFinishingAttachment:(ZPZoteroAttachment*)attachment;
-(void) linkAttachment:(ZPZoteroAttachment*)attachment withRequest:(NSObject*)request;
-(id) requestWithAttachment:(ZPZoteroAttachment*)attachment;

-(void) presentConflictViewForAttachment:(ZPZoteroAttachment*) attachment reason:(NSString*) reason;

-(void) logVersionInformationForAttachment:(ZPZoteroAttachment*) attachment;

/*
 Returns the content of a request and response as string. Useful for logging.
 */
-(NSString*) requestDumpAsString:(ASIHTTPRequest*)request;



@end
