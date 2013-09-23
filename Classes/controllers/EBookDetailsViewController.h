//
//  EBookDetailsViewController.h
//  EBook
//
//  Created by Jason on 12-11-27.
//  Copyright (c) 2012年 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookItem.h"
#import "ASIHTTPRequest.h"

@interface EBookDetailsViewController : UIViewController
{
    UIWebView               *_webview;
    ASIHTTPRequest          *_requst;
    NSString                *_content;
}

@property (nonatomic , retain) BookItem *currentItem;
@end
