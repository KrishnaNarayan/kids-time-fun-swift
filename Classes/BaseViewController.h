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
