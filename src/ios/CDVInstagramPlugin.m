/*
    The MIT License (MIT)
    Copyright (c) 2013 Vlad Stirbu
    
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

@implementation CDVInstagramPlugin

-(void)isInstalled:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString *callbackId = [arguments pop];
    
    CDVPluginResult *result;
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
        [self writeJavascript: [result toSuccessCallbackString:callbackId]];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        
        [self writeJavascript: [result toErrorCallbackString:callbackId]];
    }
    

    
}

- (void)share:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString    *callbackId     = [arguments pop];
    NSString    *objectAtIndex0 = [arguments objectAtIndex:0];
    
    CDVPluginResult *result;
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        //imageToUpload is a file path with .ig file extension
        NSLog(@"open in instagram");
        
        NSData *imageObj = [NSData dataFromBase64String:objectAtIndex0];
        
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *path = [tmpDir stringByAppendingPathComponent:@"instagram.igo"];
        
        [imageObj writeToFile:path atomically:true];
        
        UIDocumentInteractionController* documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
        [documentInteractionController retain];
        
        documentInteractionController.UTI = @"com.instagram.exclusivegram";
        
        if(! [documentInteractionController presentPreviewAnimated:YES]){
            NSLog(@"ERROR in presenting preview %@", self.webView.delegate);
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:2];
            
            [self writeJavascript:[result toErrorCallbackString:callbackId]];
        }
        [documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.webView animated:YES];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
        [self writeJavascript:[result toSuccessCallbackString:callbackId]];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:1];
        
        [self writeJavascript:[result toErrorCallbackString:callbackId]];
    }
}

@end
