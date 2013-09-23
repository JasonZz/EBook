//
//  StorageManager.m
//  EBook
//
//  Created by Jason on 12-11-28.
//  Copyright (c) 2012年 Jason. All rights reserved.
//

#import "StorageManager.h"


@implementation StorageManager
static StorageManager *instance;

- (void)dealloc
{
//    EBookRelease(_rootPath);
    [super dealloc];
}
//- (id)init
//{
//    self = [super init];
//    if (self) {
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        _rootPath = EBookRetain([[paths objectAtIndex:0] stringByAppendingPathComponent:@"BookCache"]);
//    }
//    return self;
//}

+ (StorageManager *)sharedStorageManager
{
    if (instance == nil)
    {
        instance = [[StorageManager alloc] init];
    }
    
    return instance;
}

+ (NSString*)getRootPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootPath = EBookRetain([[paths objectAtIndex:0] stringByAppendingPathComponent:@"BookCache"]);
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return rootPath;
}

+ (NSString*)createFolderWithName:(NSString*)kName
{
    NSString *path = [[StorageManager getRootPath] stringByAppendingPathComponent:kName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *_error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&_error];
        if (_error) {
            return nil;
        }else{
            return path;
        }
    }else{
        return path;
    }
}


@end
