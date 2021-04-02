/*
    The MIT License (MIT)
    Copyright (c) 2013 - 2014 Vlad Stirbu
    
    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    
    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Cordova/CDV.h>
#import "CDVInstagramPlugin.h"
#import <Photos/Photos.h>

#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])
#define IS_IOS13orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0)
#define IS_IOS142orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 14.2)

static NSString *InstagramId = @"com.burbn.instagram";

typedef NS_ENUM(NSUInteger, LOGIC_MODE) {
    LM_DEFAULT = 0,
    LM_IGO,
    LM_IG,
    LM_LIBRARY
};
typedef NS_ENUM(NSUInteger, ERROR_CODE) {
    EC_INSTAGRAM_INACCESSIBLE = 1,
    EC_OTHER_APP_LAUNCHED,
    EC_APP_INTENT_LAUNCH_FAILURE,
    EC_APP_INTENT_GENERAL_FAILURE
};

@implementation CDVInstagramPlugin

@synthesize toInstagram;
@synthesize callbackId;
@synthesize interactionController;

-(void)isInstalled:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    CDVPluginResult *result;
    
    NSLog(@"IOS Version: %f", IOS_VERSION);

    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
    
}

- (void)share:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    self.toInstagram = FALSE;
    NSString    *objectAtIndex0 = [command argumentAtIndex:0];
    NSString    *caption = [command argumentAtIndex:1];
    NSNumber    *mode = [command argumentAtIndex:2];
    
    __block CDVPluginResult *result;
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        NSLog(@"open in instagram");
        
        NSData *imageObj = [[NSData alloc] initWithBase64EncodedString:objectAtIndex0 options:0];
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *path;
        NSString *uti;

        if (mode.intValue == LM_DEFAULT) {
            if (IS_IOS13orHIGHER) {
                path = [tmpDir stringByAppendingPathComponent:@"instagram.ig"];
                uti = @"com.instagram.photo";
            } else {
                path = [tmpDir stringByAppendingPathComponent:@"instagram.igo"];
                uti = @"com.instagram.exclusivegram";
            }
            NSLog(@"Using DEFAULT logic mode: %@", path);
        }
        else if (mode.intValue == LM_IG) {
            path = [tmpDir stringByAppendingPathComponent:@"instagram.ig"];
            uti = @"com.instagram.photo";
        }
        else if (mode.intValue == LM_IGO) {
            path = [tmpDir stringByAppendingPathComponent:@"instagram.igo"];
            uti = @"com.instagram.exclusivegram";
        }
        else {
            NSString *fileName;
            fileName = @"cordova-instagram.jpg"; // todo: perhaps a random hash would be better.
            path = [tmpDir stringByAppendingPathComponent:fileName];
        }

        NSLog(@"Saving temporary file under app specific folder: %@", path);
        [imageObj writeToFile:path atomically:true];

        if (mode.intValue != LM_LIBRARY) {
            NSLog(@"launching with Document Interaction UTI");
            self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];

            // not sure why this is here. It doesn't work and is pointless. Posterity?
            if (caption) {
                self.interactionController .annotation = @{@"InstagramCaption" : caption};
            }

            self.interactionController .UTI = uti;
            self.interactionController .delegate = self;
            if ([self.interactionController presentOpenInMenuFromRect:CGRectZero inView:self.webView animated:YES]){
                NSLog(@"menu is presented");
            }
        } else {
            NSLog(@"Attempting to save to library, read as a PHAsset for it's localidentifier, and launch using App Intent.");
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            
            __block NSString* localId;

            // Add it to the photo library
            NSLog(@"Sharing to library now..");
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                localId = [[assetChangeRequest placeholderForCreatedAsset] localIdentifier];
            } completionHandler:^(BOOL success, NSError *error) {
                if (!success) {
                    NSLog(@"Error creating asset: %@", error);
                } else {
                    @try {
                        NSString *localIdentifierEscaped = [localId stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
		                NSURL *instagramShareURL   = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?LocalIdentifier=%@", localIdentifierEscaped]];
                        NSLog(@"Opening %@, using intent: %@", localId, instagramShareURL);

                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication] openURL:instagramShareURL options:@{} completionHandler:^(BOOL success) {
                                if (success) {
                                    NSLog(@"Successfully opened instagram");

                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                                        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
                                    });
                                }
                                else {
                                    NSLog(@"Failed to open instagram");

                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:EC_APP_INTENT_LAUNCH_FAILURE];
                                        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
                                    });
                                }
                            }];
                        });
                    }
                    @catch(id anException) {
                        NSLog(@"Failed to open due to: %@", anException);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:EC_APP_INTENT_GENERAL_FAILURE];
                            [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
                        });
                    }
                }
            }];
            
        }
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:EC_INSTAGRAM_INACCESSIBLE];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
}

- (void)shareAsset:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    NSString    *localIdentifier = [command argumentAtIndex:0];
    
    CDVPluginResult *result;
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        NSLog(@"open asset in instagram");
        
		NSString *localIdentifierEscaped = [localIdentifier stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
		NSURL *instagramShareURL   = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?LocalIdentifier=%@", localIdentifierEscaped]];
		
		[[UIApplication sharedApplication] openURL:instagramShareURL];

		result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
        
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:EC_INSTAGRAM_INACCESSIBLE];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
}

- (void) documentInteractionController: (UIDocumentInteractionController *) controller willBeginSendingToApplication: (NSString *) application {
    NSLog(@"willBeginSendingToApplication");
    if ([application isEqualToString:InstagramId]) {
        self.toInstagram = TRUE;
    }
}

- (void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller {
    CDVPluginResult *result;

    NSLog(@"documentInteractionControllerDidDismissOpenInMenu");
    
    if (self.toInstagram) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:EC_OTHER_APP_LAUNCHED];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
}

@end
