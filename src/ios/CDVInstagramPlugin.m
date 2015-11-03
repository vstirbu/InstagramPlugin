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

static NSString *InstagramId = @"com.burbn.instagram";

@implementation CDVInstagramPlugin

@synthesize toInstagram;
@synthesize callbackId;
@synthesize interactionController;

-(void)isInstalled:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    CDVPluginResult *result;
    
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
    
    CDVPluginResult *result;
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        NSLog(@"open in instagram");
        
        NSData* imageObj = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:objectAtIndex0]];
        UIImage* image = [UIImage imageWithData:imageObj];
        image = [self saveImage:image withText:caption];
        imageObj = UIImagePNGRepresentation(image);
        
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *path = [tmpDir stringByAppendingPathComponent:@"instagram.igo"];
        
        [imageObj writeToFile:path atomically:true];
        
        self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
        self.interactionController .UTI = @"com.instagram.exclusivegram";
        if (caption) {
            self.interactionController .annotation = @{@"InstagramCaption" : caption};
        }
        self.interactionController .delegate = self;
        [self.interactionController presentOpenInMenuFromRect:CGRectZero inView:self.webView animated:YES];
        
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:1];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
}

- (void) documentInteractionController: (UIDocumentInteractionController *) controller willBeginSendingToApplication: (NSString *) application {
    if ([application isEqualToString:InstagramId]) {
        self.toInstagram = TRUE;
    }
}

- (void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller {
    CDVPluginResult *result;
    
    if (self.toInstagram) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:2];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
}

- (UIImage*)saveImage:(UIImage*)image withText:(NSString*)text {
    
    double minSide = MIN(image.size.width, image.size.height);
    CGSize size = CGSizeMake(minSide, minSide);
    
    double refWidth = CGImageGetWidth(image.CGImage);
    double refHeight = CGImageGetHeight(image.CGImage);
    
    double x = (refWidth - size.width) / 2.0;
    double y = (refHeight - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    
    CGSize labelSize = CGSizeMake(minSide - 40, 30);
    CGPoint startPoint = CGPointMake(20, minSide - labelSize.height);
    
    // Draw it
    UIGraphicsBeginImageContext(CGSizeMake(minSide, minSide));
    [cropped drawInRect:CGRectMake(0,0,minSide,minSide)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextStrokeRectWithWidth(context, CGRectMake(0, minSide - labelSize.height, minSide, labelSize.height), labelSize.height);
    
    // Center the label
    UIFont *font = [self fontToFitInSize:labelSize forText:text];
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: font}];
    startPoint = CGPointMake((minSide - textSize.width) / 2, (minSide - labelSize.height));
    CGRect rect = CGRectMake(startPoint.x, startPoint.y, textSize.width, textSize.height);
    [[UIColor blackColor] set];
    //    CGContextStrokeRectWithWidth(context, rect, labelSize.height);
    [text drawInRect:rect withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIFont*)fontToFitInSize:(CGSize)size forText:(NSString*)text {
    CGFloat baseFont = 0;
    UIFont* myFont = [UIFont systemFontOfSize:baseFont];
    CGSize fSize = [text sizeWithFont:myFont];
    CGFloat step = 0.1f;
    
    BOOL stop = NO;
    CGFloat previousH;
    while (!stop) {
        myFont = [UIFont systemFontOfSize:baseFont + step ];
        fSize = [text sizeWithFont:myFont constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat pad = myFont.lineHeight / 3;
        if (fSize.height + pad > size.height ||
            fSize.width + pad > size.width) {
            myFont = [UIFont systemFontOfSize:previousH];
            fSize = CGSizeMake(fSize.width, previousH);
            stop = YES;
        } else {
            previousH = baseFont+step;
        }
        
        step++;
    }
    return myFont;
}

@end
