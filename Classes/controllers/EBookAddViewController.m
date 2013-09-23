//
//  EBookAddViewController.m
//  EBook
//
//  Created by Jason on 12-11-29.
//  Copyright (c) 2012年 Jason. All rights reserved.
//

#import "EBookAddViewController.h"
#import "StorageManager.h"

@interface EBookAddViewController ()

- (void)getLocalCollectBook;
- (void)addLocalCollect:(NSDictionary*)kDic;
@end

@implementation EBookAddViewController
@synthesize nameTextField = _nameTextField;
@synthesize linkTextField = _linkTextField;


- (void)dealloc
{
    [_localArrary release];
    [_nameTextField release];
    [_linkTextField release];
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
    // Do any additional setup after loading the view from its nib.
    
    _localArrary = [[NSMutableArray alloc] initWithCapacity:1];
    [self getLocalCollectBook];
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setLinkTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)getLocalCollectBook
{
    [_localArrary removeAllObjects];
    NSString *_collectPath = [StorageManager createFolderWithName:kCollectPath];
    NSString *_collectNamePath = [_collectPath stringByAppendingPathComponent:@"collect.plist"];
    NSArray *_localArray = [NSArray arrayWithContentsOfFile:_collectNamePath];
    if (_localArray) {
        [_localArrary addObjectsFromArray:_localArray];
    }
}

- (void)addLocalCollect:(NSDictionary*)kDic
{
    if (!kDic) {
        return;
    }
    NSString *_collectPath = [StorageManager createFolderWithName:kCollectPath];
    NSString *_collectNamePath = [_collectPath stringByAppendingPathComponent:@"collect.plist"];
    
    
    NSString *searchText = [kDic objectForKey:kKey_HrefLink];
    NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"(hreflink contains[cd] %@)", searchText];
    NSArray *_temp = [_localArrary filteredArrayUsingPredicate:predicate];
    
    if (_temp && [_temp count] > 0) {
        
    }else{
        [_localArrary addObject:kDic];
        [_localArrary writeToFile:_collectNamePath atomically:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameTextField) {
        [self.nameTextField resignFirstResponder];
        [self.linkTextField becomeFirstResponder];
    }else{
        
        NSString *_nameText = self.nameTextField.text;
        NSString *_linkText = self.linkTextField.text;
        if ([_linkText isEqualToString:@""]) {
            return NO;
        }
        NSRange _range = [_linkText rangeOfString:@"/"];
        if (_range.location == NSNotFound) {
            return NO;
        }else{
            _linkText = [_linkText stringByAppendingPathComponent:@"index.html"];
            NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:_nameText, kKey_Title, _linkText , kKey_HrefLink, nil];
            [self addLocalCollect:_dic];
        }
    }
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
