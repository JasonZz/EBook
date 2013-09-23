//
//  EBookAddViewController.h
//  EBook
//
//  Created by Jason on 12-11-29.
//  Copyright (c) 2012年 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EBookAddViewController : UIViewController <UITextFieldDelegate>
{
    NSMutableArray                  *_localArrary;
    
}
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UITextField *linkTextField;
@end
