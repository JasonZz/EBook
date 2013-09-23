//
//  StorageManager.h
//  EBook
//
//  Created by Jason on 12-11-28.
//  Copyright (c) 2012年 Jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StorageManager : NSObject
{
    
    
    NSString                 *_rootPath;
}

+ (StorageManager *)sharedStorageManager;
+ (NSString*)getRootPath;
+ (NSString*)createFolderWithName:(NSString*)kName;
@end
