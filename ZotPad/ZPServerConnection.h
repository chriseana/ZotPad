//
//  ZPServerConnection.h
//  ZotPad
//
//  Handles communication with Zotero server. Used as a singleton.
//
//  Created by Rönkkö Mikko on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"
#import "OAToken.h"
#import "ZPAuthenticationDialog.h"

@interface ZPServerConnection : NSObject{
    //The Oauht key to use
    NSString* _oauthkey;
    
    OAToken* _requestToken;
    
    // A reference to source view controller so that we can display modal views for authentication
    UIViewController* _sourceViewController;
    
    // Dialog that will show the Zotero login
    ZPAuthenticationDialog* _authenticationDialog;
}

// This class is used as a singleton
+ (ZPServerConnection*) instance;

// Check if the connection is already authenticated
- (BOOL) authenticated;

// Authenticates with OAuth
- (void) doAuthenticate:(UIViewController*) source;

// Methods used in the OAuth authentication
- (void) makeOAuthRequest: (OAToken *) token;
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;

@end