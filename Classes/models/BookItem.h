//
//  BookItem.h
//  EBook
//
//  Created by Jason on 12-11-27.
//  Copyright (c) 2012年 Jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookItem : NSObject
@property (nonatomic , retain)NSString *title;
@property (nonatomic , retain)NSString *hrefLink;
- (NSDictionary*)itemToDic;
@end
