//
//  ViewController.h
//  BlocBrowser
//
//  Created by Jack Li on 2/23/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

// Replaces web view with fresh one, erasing all history. Also updates url field and buttons.
- (void) resetWebView;

@end

