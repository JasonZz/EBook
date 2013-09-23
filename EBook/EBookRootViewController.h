//
//  EBookRootViewController.h
//  EBook
//
//  Created by Jason on 12-11-27.
//  Copyright (c) 2012年 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EBookRootViewController : UIViewController <UITableViewDataSource , UITableViewDelegate>
{
    NSMutableArray              *_cataLogArray;
    UITableView                 *_tableview;
}
@end
