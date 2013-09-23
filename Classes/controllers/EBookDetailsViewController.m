//
//  EBookDetailsViewController.m
//  EBook
//
//  Created by Jason on 12-11-27.
//  Copyright (c) 2012年 Jason. All rights reserved.
//

#import "EBookDetailsViewController.h"
#import "ASIHTTPRequest.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "BookItem.h"


#import "StorageManager.h"

@interface EBookDetailsViewController ()

- (void)getBookDetails;
- (void)onFinishedRequestDetails:(ASIHTTPRequest*)request;
- (void)onFailedRequestDetails:(ASIHTTPRequest*)request;
- (void)handleDetailsHtml:(NSString*)kString;
- (NSString*)generateHtmlStr:(NSString*)str;

- (NSString*)getStoragePath;
- (NSString*)getStorageContent;

- (void)addStorage;
- (void)refresh:(id)sender;
@end

@implementation EBookDetailsViewController
@synthesize currentItem;

- (void)dealloc
{
    EBookRelease(_content);
    [_requst release];
    [_webview release];
    [currentItem release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIBarButtonItem *_right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                            target:self
                                                                            action:@selector(refresh:)];
    
    self.navigationItem.rightBarButtonItem = _right;
    [_right release];
    
    CGRect _webFrame = UIEdgeInsetsInsetRect([UIScreen mainScreen].bounds, UIEdgeInsetsMake(0., 0., 64., 0.));
    _webview = [[UIWebView alloc] initWithFrame:_webFrame];
    [self.view addSubview:_webview];
    if (self.currentItem) {
        
        NSString *_titleName = self.currentItem.title;
        NSString *_specialStr = @"章 ";
        NSRange _range = [_titleName rangeOfString:_specialStr];
        if (_range.location != NSNotFound) {
            _titleName = [_titleName substringFromIndex:(_range.location + _specialStr.length)];
        }
        self.navigationItem.title = _titleName;
    }
    
    
    NSString *_htmlStr = [self getStorageContent];
    if (_htmlStr) {
        [_webview loadHTMLString:_htmlStr
                         baseURL:nil];
    }else{
        [self getBookDetails];        
    }
}

- (void)refresh:(id)sender
{
    [self getBookDetails];
}

- (void)addStorage
{
    NSString *_writePath = [self getStoragePath];
    if (_writePath && _content) {
        NSError *_error = nil;
        [_content writeToFile:_writePath
                   atomically:YES
                     encoding:NSUTF8StringEncoding
                        error:&_error];
        if (!_error) {
//            NSLog(@"write success!!");
        }
    }
}

- (NSString*)getStorageContent
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getStoragePath]]) {
        return [NSString stringWithContentsOfFile:[self getStoragePath]
                                         encoding:NSUTF8StringEncoding
                                            error:NULL];
    }
    return nil;
}

- (NSString*)getStoragePath
{
    NSString *_writeToPath = nil;
    if (self.currentItem.hrefLink) {
        NSString *_path = self.currentItem.hrefLink;
        
        NSString *_fileName = [_path lastPathComponent];
        
        _path = [_path stringByDeletingPathExtension];
        _path = [_path stringByDeletingLastPathComponent];
        _path = [_path lastPathComponent];
        
        NSString *_storagePath = [StorageManager createFolderWithName:_path];
        _writeToPath = [_storagePath stringByAppendingPathComponent:_fileName];
    }
    return _writeToPath;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_requst) {
        _requst.delegate = nil;
        [_requst cancel];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - private
- (void)getBookDetails
{
    if (!self.currentItem) {
        return;
    }
    NSURL *_url = [NSURL URLWithString:self.currentItem.hrefLink];
    ASIHTTPRequest *requst = [ASIHTTPRequest requestWithURL:_url];
    requst.defaultResponseEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    requst.didFinishSelector = @selector(onFinishedRequestDetails:);
    requst.didFailSelector = @selector(onFailedRequestDetails:);
    requst.delegate = self;
    [requst startAsynchronous];
    _requst = [requst retain];
}

- (void)onFinishedRequestDetails:(ASIHTTPRequest*)request
{
    NSString *responseStr = [request responseString];
//    NSLog(@"responseStr %@" , responseStr);
    [self handleDetailsHtml:responseStr];
}
- (void)onFailedRequestDetails:(ASIHTTPRequest*)request
{
    
}
- (void)handleDetailsHtml:(NSString*)responseBody
{
    NSAutoreleasePool *_pool = [[NSAutoreleasePool alloc] init];
    NSError *_error = nil;
    HTMLParser *parse = [[HTMLParser alloc] initWithString:responseBody error:&_error];
    NSString *_htmlContent = nil;
    if (parse) {
        HTMLNode *_bodyNode = [parse body];
        if (_bodyNode) {
            HTMLNode *_contentNode = [_bodyNode findChildWithAttribute:@"name" matchingName:@"content" allowPartial:YES];
            if (_contentNode) {
                NSString *_contentStr = [_contentNode rawContents];
                NSString *_temp = [_contentStr substringFromIndex:130];
                NSRange range = [_temp rangeOfString:@"</div>"];
                _temp = [_temp substringToIndex:range.location];
                _htmlContent = _temp;
            }
        }
    }
    _htmlContent = [self generateHtmlStr:_htmlContent];
    
    _content = EBookRetain(_htmlContent);
    [_webview loadHTMLString:_htmlContent baseURL:nil];
    
    [self addStorage];
    [parse release];
    [_pool release];
}

- (NSString*)generateHtmlStr:(NSString*)str
{
    NSString *head = @"<html>\
    <head>\
    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\
    <body>";
    
    NSString *end = @"</body>\
    </html>";
    NSString *_generate = [NSString stringWithFormat:@"%@%@%@" , head , str , end];
    return _generate;
}
@end
