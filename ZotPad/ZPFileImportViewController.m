//
//  ZPFileImportView.m
//  ZotPad
//
//  Created by Mikko Rönkkö on 8.4.2012.
//  Copyright (c) 2012 Mikko Rönkkö. All rights reserved.
//

#import "ZPCore.h"

#import "ZPFileImportViewController.h"
#include <QuartzCore/QuartzCore.h>


#import "ZPItemDataDownloadManager.h"
#import "ZPAttachmentCarouselDelegate.h"
#import "ZPUploadVersionConflictViewControllerViewController.h"

@interface ZPFileImportViewController (){
    ZPAttachmentCarouselDelegate* _carouselDelegate;
}


@end


@implementation ZPFileImportViewController

@synthesize url, carousel, isFullyPresented;

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    ZPZoteroAttachment* attachment = [ZPZoteroAttachment dataObjectForAttachedFile:url.absoluteString];

    //The carousel needs to be configured here so that we know the dimensions
    
    if(_carouselDelegate == NULL){
        _carouselDelegate = [[ZPAttachmentCarouselDelegate alloc] init];
        _carouselDelegate.owner = self;
        _carouselDelegate.mode = ZPATTACHMENTICONGVIEWCONTROLLER_MODE_UPLOAD;
        _carouselDelegate.show = ZPATTACHMENTICONGVIEWCONTROLLER_SHOW_MODIFIED;
        _carouselDelegate.attachmentCarousel = carousel;
        [_carouselDelegate configureWithAttachmentArray:[NSArray arrayWithObject:attachment]];
        carousel.dataSource = _carouselDelegate;
        carousel.delegate = self;
    }
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    isFullyPresented = TRUE;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) dealloc{
    [_carouselDelegate unregisterProgressViewsBeforeUnloading];
}
- (void) viewWillUnload{
    [super viewWillUnload];
    [_carouselDelegate unregisterProgressViewsBeforeUnloading];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    isFullyPresented = FALSE;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"FileUploadConflictFromDialog"]){
        ZPUploadVersionConflictViewControllerViewController* target = segue.destinationViewController;
        target.fileChannel = [(NSDictionary*) sender objectForKey:@"fileChannel"];
        target.attachment = [(NSDictionary*) sender objectForKey:ZPKEY_ATTACHMENT];
    }
}

#pragma mark - Alert view delegate methods
//TODO: Is this needed?

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    isFullyPresented = FALSE;
    [self dismissModalViewControllerAnimated:YES];
}

@end
