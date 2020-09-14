//
//  NoInputAccessoryView.m
//  JamKit
//
//  Created by 张文洁 on 2020/9/14.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import "NoInputAccessoryView.h"
#import "WebViewViewController.h"
#import <objc/runtime.h>

@implementation NoInputAccessoryView

- (id)inputAccessoryView {
    return nil;
}

- (void)removeInputAccessoryViewFromWKWebView:(WKWebView *)webView {
    
    UIView *targetView;
    
    for (UIView *view in webView.scrollView.subviews) {
        
        if([[view.class description] hasPrefix:@"WKContent"]) {
            
            targetView = view;
            
        }
        
    }
    if (!targetView) {
        
        return;
        
    }
    NSString *noInputAccessoryViewClassName = [NSString stringWithFormat:@"%@_NoInputAccessoryView", targetView.class.superclass];
    
    Class newClass = NSClassFromString(noInputAccessoryViewClassName);
    
    if(newClass == nil) {
        
        newClass = objc_allocateClassPair(targetView.class, [noInputAccessoryViewClassName cStringUsingEncoding:NSASCIIStringEncoding], 0);
        
        if(!newClass) {
            
            return;
            
        }
        Method method = class_getInstanceMethod([WebViewViewController class], @selector(inputAccessoryView));
        
        class_addMethod(newClass, @selector(inputAccessoryView), method_getImplementation(method), method_getTypeEncoding(method));
        
        objc_registerClassPair(newClass);
    }
    object_setClass(targetView, newClass);
}

@end
