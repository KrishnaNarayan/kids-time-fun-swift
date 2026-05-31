// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.

//
//  BaseViewController.h
//  KTF-v1.7
//
//  Created by satya on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DismissActivityDelegate <NSObject>
- (void)didDismissActivity:(id)sender;
@end

@interface BaseViewController : UIViewController {

}

@end
