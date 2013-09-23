//
//  BookItem.m
//  EBook
//
//  Created by Jason on 12-11-27.
//  Copyright (c) 2012年 Jason. All rights reserved.
//

#import "BookItem.h"

@implementation BookItem
@synthesize title;
@synthesize hrefLink;

- (void)dealloc
{
    [title release];
    [hrefLink release];
    [super dealloc];
}

- (NSDictionary*)itemToDic
{
    return [NSDictionary dictionaryWithObjectsAndKeys:self.title,@"title",self.hrefLink,@"hreflink", nil];
}
@end
