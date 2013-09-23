//
//  NSStringAdditions.h
//  CenturyWeeklyV2
//
//  Created by jinjian on 12/22/11.
//  Copyright (c) 2011 KSMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (KS)
- (int) indexOf:(NSString *)text;
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;
- (NSString *) stringFromMD5;
- (BOOL)isEmpty;
-(BOOL)isEmptyOrNull;
- (NSComparisonResult)versionStringCompare:(NSString *)other;
@end
