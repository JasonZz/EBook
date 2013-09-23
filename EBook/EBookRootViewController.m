//
//  EBookRootViewController.m
//  EBook
//
//  Created by Jason on 12-11-27.
//  Copyright (c) 2012年 Jason. All rights reserved.
//

#import "EBookRootViewController.h"
#import "EBookDetailsViewController.h"
#import "EBookSearchViewController.h"
#import "ASIHTTPRequest.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "BookItem.h"
#import "StorageManager.h"
#import "ASIFormDataRequest.h"

@interface EBookRootViewController ()

- (void)getCatalogWithUrlString:(NSString*)kStr;
- (void)onFinishedRequestCatalog:(ASIHTTPRequest*)request;
- (void)onFailedRequestCatalog:(ASIHTTPRequest*)request;
- (void)handleHtml:(NSString*)kString;
- (void)onSearchAction;
- (void)onRefreshAction;


- (void)showNewArticle:(NSNotification*)kNotifi;


- (NSString*)getStoragePath;
- (NSString*)getStorageKey ;

- (void)onSegmentSelected:(UISegmentedControl*)seg;
- (void)onSliderVauleChange:(UISlider*)slider;


- (void)onScrollToLast;


- (void)testGateWay;
- (void)onFinishedRequestGateWay:(ASIHTTPRequest*)request;
- (void)onFailedRequestGateWay:(ASIHTTPRequest*)request;

@end

@implementation EBookRootViewController


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSHOW_NEW_ARTICLE object:nil];
    [_cataLogArray release];
    [_tableview release];
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


- (void)testGateWay
{
    NSString *_urlString = @"http://hf888.com/post.php";
    //    NSLog(@"_urlString = %@" , _urlString);
    NSURL *_url = [NSURL URLWithString:_urlString];
//    ASIHTTPRequest *requst = [ASIHTTPRequest requestWithURL:_url];
////    requst.defaultResponseEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    requst.didFinishSelector = @selector(onFinishedRequestGateWay:);
//    requst.didFailSelector = @selector(onFailedRequestGateWay:);
//    requst.delegate = self;
//    [requst startAsynchronous];
    
    
    ASIFormDataRequest *requst = [ASIFormDataRequest requestWithURL:_url];
//    requst.defaultResponseEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    requst.requestMethod = @"POST";
    requst.didFinishSelector = @selector(onFinishedRequestGateWay:);
    requst.didFailSelector = @selector(onFailedRequestGateWay:);
    requst.delegate = self;

    [requst addPostValue:@"hefei" forKey:@"name"];
    [requst addPostValue:@"23" forKey:@"count"];
    
    
    [requst startAsynchronous];
}

- (void)onFinishedRequestGateWay:(ASIHTTPRequest*)request
{
    NSString *responseStr = [request responseString];

    NSLog(@"responseStr = %@" , responseStr);
}

- (void)onFailedRequestGateWay:(ASIHTTPRequest*)request
{

    NSError *_error = request.error;
    NSLog(@"error= %@" , [_error description]);
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CGRect _tableFrame = UIEdgeInsetsInsetRect([UIScreen mainScreen].bounds, UIEdgeInsetsMake(0., 0., 64., 0.));
    _tableview = [[UITableView alloc] initWithFrame:_tableFrame
                                              style:UITableViewStylePlain];
    _tableview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [self.view addSubview:_tableview];
    
    UIBarButtonItem *_rightItem = [[UIBarButtonItem  alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                 target:self
                                                                                 action:@selector(onSearchAction)];
    
    self.navigationItem.rightBarButtonItem = _rightItem;
    [_rightItem release];
    
    
    UIBarButtonItem *_leftItem = [[UIBarButtonItem  alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(onRefreshAction)];
    
    self.navigationItem.leftBarButtonItem = _leftItem;
    [_leftItem release];
    
    
    UISegmentedControl *_segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"最旧",@"居中",@"最新", nil]];
    _segment.segmentedControlStyle = UISegmentedControlStyleBar;
    _segment.tintColor = [UIColor colorWithRed:(116./255.) green:(137./255.) blue:(166./255.) alpha:1.];
    _segment.frame = CGRectMake(0., 0., 150., 30.);
    [_segment addTarget:self
                 action:@selector(onSegmentSelected:)
       forControlEvents:UIControlEventValueChanged];
//    self.navigationItem.titleView = _segment;
    
    
    UIView *_headerView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., 180., 44.)];
    _headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0., 4., 180., 14.)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:14.];
    _titleLabel.numberOfLines = 1;
    _titleLabel.tag = 100;
    _titleLabel.shadowColor = [UIColor lightGrayColor];
    
    [_headerView addSubview:_titleLabel];
    [_titleLabel release];
    
    UISlider *_sliderView = [[UISlider alloc] initWithFrame:CGRectMake(0., 19., 180., 0.)];
    _sliderView.tag = 99;
    [_sliderView addTarget:self
                    action:@selector(onSliderVauleChange:)
          forControlEvents:UIControlEventValueChanged];
    [_headerView addSubview:_sliderView];
    [_sliderView release];
    
    self.navigationItem.titleView = _headerView;
    [_headerView release];

    self.navigationItem.titleView.hidden = YES;
    
    _cataLogArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNewArticle:)
                                                 name:kSHOW_NEW_ARTICLE
                                               object:nil];


    
    [self testGateWay];
    NSString *_last = [[NSUserDefaults standardUserDefaults] objectForKey:kLAST_ARTICLE];
    if (_last) {
        NSString *_path = [self getStoragePath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:_path]) {
            NSArray *_array = [NSArray arrayWithContentsOfFile:_path];
            if (_array && [_array count] > 0) {
                [_cataLogArray removeAllObjects];
                [_cataLogArray addObjectsFromArray:_array];
                [_tableview reloadData];
                self.navigationItem.titleView.hidden = NO;
                
                [self onScrollToLast];
            }
        }
        
        [self getCatalogWithUrlString:_last];
    }else{
//        [self onSearchAction];
    }
}

- (void)onSliderVauleChange:(UISlider*)slider
{
    float value = slider.value;
    int count = [_cataLogArray count];
    if (count > 0) {
        int _index = (count - 1) * value;
        NSIndexPath *_indexpath = [NSIndexPath indexPathForRow:_index inSection:0];
        [_tableview scrollToRowAtIndexPath:_indexpath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    }
}

- (void)onSegmentSelected:(UISegmentedControl*)seg
{
//    NSLog(@"index = %d" , seg.selectedSegmentIndex);
    
    NSIndexPath *_indexpath = nil;
    switch (seg.selectedSegmentIndex) {
        case 0:
        {
            _indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        }
            break;
        case 1:
        {
            _indexpath = [NSIndexPath indexPathForRow:[_cataLogArray count] / 2 inSection:0];
        }
            break;
        case 2:
        {
            _indexpath = [NSIndexPath indexPathForRow:([_cataLogArray count] - 1) inSection:0];
        }
            break;
        default:
            break;
    }
    [_tableview scrollToRowAtIndexPath:_indexpath
                      atScrollPosition:UITableViewScrollPositionTop
                              animated:YES];
}

- (void)onScrollToLast
{
    NSIndexPath *_currentIndexPath = nil;
    NSString *_last = [[NSUserDefaults standardUserDefaults] objectForKey:kLAST_ARTICLE];
    if (_last) {
        id lastObject = [[NSUserDefaults standardUserDefaults] objectForKey:_last];
        if (lastObject) {
            int index = [lastObject intValue];
            _currentIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            float value = (CGFloat)index / (CGFloat)([_cataLogArray count] - 1);
            UISlider *_slider = (UISlider*)[self.navigationItem.titleView viewWithTag:99];
            if (_slider) _slider.value = value;
        }else{
            _currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            UISlider *_slider = (UISlider*)[self.navigationItem.titleView viewWithTag:99];
            if (_slider) _slider.value = 0.;
        }
    }else{
        _currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [_tableview scrollToRowAtIndexPath:_currentIndexPath
                      atScrollPosition:UITableViewScrollPositionTop
                              animated:YES];
}


- (void)showNewArticle:(NSNotification*)kNotifi
{
    NSNotification *_notification = kNotifi;
    if (_notification) {
        BookItem *_bookItem = (BookItem*)_notification.object;
        
        UILabel *_titleLabel = (UILabel*)[self.navigationItem.titleView viewWithTag:100];
        if (_titleLabel) _titleLabel.text = _bookItem.title;
        
        NSString *_path = [self getStoragePath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:_path]) {
            NSArray *_array = [NSArray arrayWithContentsOfFile:_path];
            if (_array && [_array count] > 0) {
                [_cataLogArray removeAllObjects];
                [_cataLogArray addObjectsFromArray:_array];
                [_tableview reloadData];
                
                [self onScrollToLast];
            }
        }
        
        [self getCatalogWithUrlString:_bookItem.hrefLink];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *_last = [[NSUserDefaults standardUserDefaults] objectForKey:kLAST_ARTICLE];
    if (_last) {
//        [self getCatalogWithUrlString:_last];
    }else{
        [self onSearchAction];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - private
- (void)getCatalogWithUrlString:(NSString*)kStr
{
    NSString *_urlString = [NSString stringWithFormat:@"%@/%@", kBaseUrlString , kStr];
//    NSLog(@"_urlString = %@" , _urlString);
    NSURL *_url = [NSURL URLWithString:_urlString];
    ASIHTTPRequest *requst = [ASIHTTPRequest requestWithURL:_url];
    requst.defaultResponseEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    requst.didFinishSelector = @selector(onFinishedRequestCatalog:);
    requst.didFailSelector = @selector(onFailedRequestCatalog:);
    requst.delegate = self;
    [requst startAsynchronous];
}

- (void)onFinishedRequestCatalog:(ASIHTTPRequest*)request
{
    NSString *responseStr = [request responseString];
    [self handleHtml:responseStr];
}
- (void)onFailedRequestCatalog:(ASIHTTPRequest*)request
{
    
}

- (void)handleHtml:(NSString*)responseBody
{
    NSAutoreleasePool *_pool = [[NSAutoreleasePool alloc] init];
    NSError *_error = nil;
    HTMLParser *parse = [[HTMLParser alloc] initWithString:responseBody error:&_error];
    if (_error) {
        return;
    }
    
    
    NSString *_last = [[NSUserDefaults standardUserDefaults] objectForKey:kLAST_ARTICLE];
    if (_last) {
//        NSLog(@"_last = %@" ,_last);
        _last = [_last stringByDeletingLastPathComponent];
    }
    
    HTMLNode *bodyNode = [parse body];
    HTMLNode *_titleNode = [bodyNode findChildTag:@"h1"];
    if(_titleNode && [[_titleNode getAttributeNamed:@"class"] isEqualToString:@"bname"]){
        //self.navigationItem.title = [_titleNode contents];
        UILabel *_titleLabel = (UILabel*)[self.navigationItem.titleView viewWithTag:100];
        if (_titleLabel) _titleLabel.text = [_titleNode contents];
    }
    NSArray *_contentArray = [bodyNode findChildrenOfClass:@"dccss"];
    if (_contentArray && [_contentArray count] > 0) {
        [_cataLogArray removeAllObjects];
        for (HTMLNode *node in _contentArray) {
            if (node) {
                HTMLNode *_hrefNode = [node findChildTag:@"a"];
                if (_hrefNode) {
                    BookItem *_item = [[BookItem alloc] init];
                    _item.title = [_hrefNode contents];
                    _item.hrefLink = [NSString stringWithFormat:@"%@/%@/%@",kBaseUrlString,_last,[_hrefNode getAttributeNamed:@"href"]];
                    [_cataLogArray addObject:[_item itemToDic]];
                    [_item release];
                }
            }
        }
    }
    [parse release];
    
    if ([_cataLogArray count] > 0) {
        NSString *_path = [self getStoragePath];
        if([[NSFileManager defaultManager] fileExistsAtPath:_path]){
            [[NSFileManager defaultManager] removeItemAtPath:_path error:NULL];
        }
        
        BOOL success = [_cataLogArray writeToFile:_path atomically:YES];
        if (success) {
            NSLog(@"success");
        }
    }
    self.navigationItem.titleView.hidden = NO;
    
    [_tableview reloadData];
    
    [self onScrollToLast];
    [_pool release];
}

- (NSString*)getStorageKey
{
    NSString *_writeToPath = nil;
    NSString *_last = [[NSUserDefaults standardUserDefaults] objectForKey:kLAST_ARTICLE];
    if (_last) {
        _last = [_last stringByDeletingLastPathComponent];
        _writeToPath = [_last lastPathComponent];
    }
    return _writeToPath;
}

- (NSString*)getStoragePath
{
    NSString *_writeToPath = nil;
    NSString *_last = [[NSUserDefaults standardUserDefaults] objectForKey:kLAST_ARTICLE];
    if (_last) {
        _last = [_last stringByDeletingLastPathComponent];
        NSString *_fileName = [_last lastPathComponent];
        NSString *_storageName = [NSString stringWithFormat:@"%@.plist" , _fileName];
        _writeToPath = [StorageManager createFolderWithName:_fileName];
        _writeToPath = [_writeToPath stringByAppendingPathComponent:_storageName];
    }
    return _writeToPath;
}


- (void)onSearchAction
{
    EBookSearchViewController *_search = [[EBookSearchViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *_Nav = [[UINavigationController alloc] initWithRootViewController:_search];
    [_search release];
    
    [self.navigationController presentModalViewController:_Nav
                                                 animated:YES];
    [_Nav release];
}
- (void)onRefreshAction
{
    NSString *_last = [[NSUserDefaults standardUserDefaults] objectForKey:kLAST_ARTICLE];
    if (_last) {
        [self getCatalogWithUrlString:_last];
    }
}


#pragma mark - tableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_cataLogArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *_cellIdentifier = @"bookitemcell";
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    UIFont *_font = [UIFont boldSystemFontOfSize:16.];
    if (!_cell){
        _cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:_cellIdentifier] autorelease];
    
    
        
        
        UILabel *_label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = _font;
        _label.tag = 100;
        _label.textColor = [UIColor blackColor];
        _label.numberOfLines = 0;
        [_cell.contentView addSubview:_label];
        [_label release];
    }
    
    UILabel *_label = (UILabel*)[_cell.contentView viewWithTag:100];
    if (_label) {
        NSString *_text = [[_cataLogArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        
        float padding = 10.;

        CGSize _textSize =  [_text sizeWithFont:_font
                              constrainedToSize:CGSizeMake(CGRectGetWidth(_tableview.frame) - padding, MAXFLOAT)
                                  lineBreakMode:UILineBreakModeWordWrap];
        float y = ( CGRectGetHeight(_cell.frame) - _textSize.height ) / 2.;
        _label.frame = CGRectMake(5., y, _textSize.width, _textSize.height);
        _label.text = _text;
        
        NSString *_last = [[NSUserDefaults standardUserDefaults] objectForKey:kLAST_ARTICLE];
        if (_last) {
            id lastObject = [[NSUserDefaults standardUserDefaults] objectForKey:_last];
            if (lastObject) {
                if ([lastObject intValue] == indexPath.row) {
                    _label.textColor = [UIColor redColor];
                }else{
                    _label.textColor = [UIColor blackColor];
                }
            }else{
                _label.textColor = [UIColor blackColor];
            }
        }
    }
    
    return _cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *_text = [[_cataLogArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    float padding = 10.;
    UIFont *_font = [UIFont boldSystemFontOfSize:16.];
    CGSize _textSize =  [_text sizeWithFont:_font
                          constrainedToSize:CGSizeMake(CGRectGetWidth(_tableview.frame) - padding, MAXFLOAT)
                              lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = padding + _textSize.height;
    return 40 > height ? 40:height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EBookDetailsViewController *_details = [[EBookDetailsViewController alloc] init];
    BookItem *item = [[BookItem alloc] init];
    item.title = [[_cataLogArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    item.hrefLink = [[_cataLogArray objectAtIndex:indexPath.row] objectForKey:@"hreflink"];
    _details.currentItem = item;
    [item release];
    
    [self.navigationController pushViewController:_details animated:YES];
    [_details release];
    
    
    NSString *_last = [[NSUserDefaults standardUserDefaults] objectForKey:kLAST_ARTICLE];
    if (_last) {
            
        id lastObject = [[NSUserDefaults standardUserDefaults] objectForKey:_last];
        if (lastObject) {
            NSIndexPath *_preIndex = [NSIndexPath indexPathForRow:[lastObject intValue] inSection:0];
            UITableViewCell *_cell = [tableView cellForRowAtIndexPath:_preIndex];
            if (_cell) {
                UILabel *_label = (UILabel*)[_cell viewWithTag:100];
                if(_label)_label.textColor = [UIColor blackColor];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:indexPath.row] forKey:_last];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UITableViewCell *_cell = [tableView cellForRowAtIndexPath:indexPath];
        if (_cell) {
            UILabel *_label = (UILabel*)[_cell viewWithTag:100];
            if(_label)_label.textColor = [UIColor redColor];
        }
    }
}
@end
