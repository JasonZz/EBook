//
//  EBookSearchViewController.h
//  EBook
//
//  Created by Jason on 12-11-28.
//  Copyright (c) 2012年 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSHOW_NEW_ARTICLE               @"showNewArticle"
#define kLAST_ARTICLE                   @"lastArticle"

@interface EBookSearchViewController : UITableViewController<UISearchBarDelegate ,UISearchDisplayDelegate>
{
    UISearchBar                         *_searchBarItem;
    UISearchDisplayController           *_searchDisplayVc;
    
    NSMutableArray                      *_bookArray;
    NSMutableArray                      *_bookArrayCache;
}
@end
