//
//  EBookSearchViewController.m
//  EBook
//
//  Created by Jason on 12-11-28.
//  Copyright (c) 2012年 Jason. All rights reserved.
//

#import "EBookSearchViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "BookItem.h"

#import "EBookAddViewController.h"

#import "StorageManager.h"


#define kSEARCH_STR             @"http://www.ranwen.net/modules/article/search.php"
@interface EBookSearchViewController ()

- (void)doSearchWithKey:(NSString*)kKeys;
- (void)onSearchWithKey:(NSString*)kKeys;

- (void)onFinishedRequestSearch:(ASIHTTPRequest*)request;
- (void)onFailedRequestSearch:(ASIHTTPRequest*)request;
- (void)handleSearchHtml:(NSString*)kString;

- (void)dismiss;
- (void)usedSee;
- (void)addCollect ;
@end

@implementation EBookSearchViewController

- (void)dealloc
{
    [_searchBarItem release];
    [_searchDisplayVc release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _bookArray = [[NSMutableArray alloc] init];
    _bookArrayCache = [[NSMutableArray alloc] initWithCapacity:1];
    
    
    UIBarButtonItem *_left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:self
                                                                           action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = _left;
    [_left release];
    
    
    UIBarButtonItem *_add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                           target:self
                                                                           action:@selector(addCollect)];
    
    UIBarButtonItem *_right = [[UIBarButtonItem alloc] initWithTitle:@"收藏"
                                                               style:UIBarButtonSystemItemAction
                                                              target:self
                                                              action:@selector(usedSee)];
    
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_add , _right, nil];

    self.navigationItem.rightBarButtonItem = _add;
    [_right release];
    [_add release];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    CGRect _tableFrame = UIEdgeInsetsInsetRect([UIScreen mainScreen].bounds, UIEdgeInsetsMake(0., 0., 64., 0.));
    self.tableView.frame = _tableFrame;
    _searchBarItem = [[UISearchBar alloc] initWithFrame:CGRectMake(0., 0., CGRectGetWidth([UIScreen mainScreen].bounds), 44.)];
    _searchBarItem.delegate = self;
    self.tableView.tableHeaderView = _searchBarItem;


    NSArray *_scopArray = [NSArray arrayWithObjects:@"文章名称",@"文章作者",@"关键字",nil];
    _searchDisplayVc = [[UISearchDisplayController alloc] initWithSearchBar:_searchBarItem
                                                         contentsController:self];
    _searchDisplayVc.searchBar.scopeButtonTitles = nil;
//    _searchDisplayVc.delegate = self;
    _searchDisplayVc.searchResultsDelegate = self;
    _searchDisplayVc.searchResultsDataSource = self;
    
//    [self usedSee];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self usedSee];
}
 

- (void)addCollect
{
    EBookAddViewController *_addVc = [[EBookAddViewController alloc] initWithNibName:@"EBookAddViewController"
                                                                              bundle:nil];
    [self.navigationController pushViewController:_addVc
                                         animated:YES];
    [_addVc release];
}


- (void)usedSee
{
    [_bookArray removeAllObjects];
    [_bookArrayCache removeAllObjects];
    
    NSString *_finalPath = nil;
    NSString *_collectPath = [StorageManager createFolderWithName:kCollectPath];
    NSString *_collectNamePath = [_collectPath stringByAppendingPathComponent:@"collect.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_collectNamePath]) {
        _finalPath = _collectNamePath;
    }else{
        NSString *_cllectPath = [[NSBundle mainBundle] pathForResource:@"collect" ofType:@"plist"];
        NSError *_error = nil;
        [[NSFileManager defaultManager] copyItemAtPath:_cllectPath toPath:_collectNamePath error:&_error];
        if (!_error) {
            _finalPath = _collectNamePath;
        }else{
            _finalPath = _cllectPath;
        }
    }
    
    NSArray *_localArray = [NSArray arrayWithContentsOfFile:_finalPath];
    if (_localArray) {
        [_bookArray addObjectsFromArray:_localArray];
        [_bookArrayCache addObjectsFromArray:_localArray];
    }
    [self.tableView reloadData];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_bookArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[_bookArray objectAtIndex:indexPath.row] objectForKey:kKey_Title];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    BookItem *_item = [[BookItem alloc] init];
    
    NSString *titleName = [[_bookArray objectAtIndex:indexPath.row] objectForKey:kKey_Title];
    NSString *hrefLink = [[_bookArray objectAtIndex:indexPath.row] objectForKey:kKey_HrefLink];
    _item.title = titleName;
    _item.hrefLink = hrefLink;
    [[NSUserDefaults standardUserDefaults] setObject:_item.hrefLink forKey:kLAST_ARTICLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (_item) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSHOW_NEW_ARTICLE
                                                            object:_item];
        [self dismiss];
    }
    [_item release];
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
// 
//    NSLog(@"searchString = %@" , searchString);
//    // Return YES to cause the search result table view to be reloaded.
//    return YES;
//}

#pragma mark -
#pragma mark UISearchBar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    NSLog(@"searchString = %@" , searchBar.text);
//    [self doSearchWithKey:searchBar.text];
}

- (void)onSearchWithKey:(NSString*)kKeys
{
    if ([kKeys isEqualToString:@""]) {
        [_bookArray removeAllObjects];
        [_bookArray addObjectsFromArray:_bookArrayCache];
    }else{
        NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"(title contains[cd] %@)", kKeys];
        NSArray *_temp = [_bookArrayCache filteredArrayUsingPredicate:predicate];
        if (_temp && [_temp count] > 0) {
            NSLog(@"_temp = %@" , _temp);
            [_bookArray removeAllObjects];
            [_bookArray addObjectsFromArray:_temp];
        }
    }
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"searchText = %@" , searchText);
    [self onSearchWithKey:searchText];
}

- (void)doSearchWithKey:(NSString*)kKeys
{
    if ([kKeys isEqualToString:@""]) {
        return;
    }
    
    NSString *_searchType = [[_searchDisplayVc.searchBar scopeButtonTitles] objectAtIndex:[_searchDisplayVc.searchBar selectedScopeButtonIndex]];
    
    if ([_searchType isEqualToString:@"文章名称"]) {
        _searchType = @"articlename"; 
    }else if([_searchType isEqualToString:@"文章作者"]){
        _searchType = @"author";
    }else{
        _searchType = @"keywords";
    }
    
    NSString *paramsStr = [NSString stringWithFormat:@"searchtype=%@&searchkey=%@&action=login" ,_searchType,kKeys];
    NSString *_urlString = [NSString stringWithFormat:@"%@?%@" , kSEARCH_STR,[paramsStr URLEncodedString]];
//    NSLog(@"_urlString = %@" , _urlString);
    NSURL *_url = [NSURL URLWithString:kSEARCH_STR];
    NSLog(@"_url = %@" , _url);
    ASIFormDataRequest *requst = [ASIFormDataRequest requestWithURL:_url];
    requst.defaultResponseEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    requst.requestMethod = @"POST";
    requst.didFinishSelector = @selector(onFinishedRequestSearch:);
    requst.didFailSelector = @selector(onFailedRequestSearch:);
    
    [requst addRequestHeader:@"Host" value:@"www.ranwen.net"];
    [requst addRequestHeader:@"Origin" value:@"www.ranwen.net"];
    [requst addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.91 Safari/537.11"];
    [requst addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [requst addRequestHeader:@"Accept-Language" value:@"zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3"];
    [requst addRequestHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    [requst addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [requst addRequestHeader:@"Connection" value:@"keep-alive"];
    [requst addRequestHeader:@"Referer" value:@"http://www.ranwen.net/modules/article/search.php"];
    
    
    
//    [requst addRequestHeader:@"Cookie" value:@"CNZZDATA3733582=cnzz_eid=73090545-1354002769-&ntime=1354072546&cnzz_a=8&retime=1354075355448&sin=&ltime=1354075355448&rtime=1; __utma=213703831.1421954827.1354002775.1354002775.1354002775.1; __utmz=213703831.1354002775.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); jieqiVisitTime=jieqiArticlesearchTime%3D1354075337; jieqiVisitId=article_articleviews%3D10852"];
//
    [requst addPostValue:_searchType forKey:@"searchtype"];
    [requst addPostValue:kKeys forKey:@"searchkey"];
    [requst addPostValue:@"login" forKey:@"action"];
//    [requst addPostValue:@" 搜 索 " forKey:@"submit"];
    
    requst.delegate = self;
    [requst startAsynchronous];
}

- (void)onFinishedRequestSearch:(ASIHTTPRequest*)request
{
    
//    NSLog(@"request.responseHeaders = %@" , request.responseHeaders);
    NSString *responseStr = [request responseString];
    [self handleSearchHtml:responseStr];
}
- (void)onFailedRequestSearch:(ASIHTTPRequest*)request
{
//    NSLog(@"%@" ,request.error.debugDescription);
}

- (void)handleSearchHtml:(NSString*)kString
{
//    NSLog(@"kString = %@" , kString);
}


- (void)dismiss
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
