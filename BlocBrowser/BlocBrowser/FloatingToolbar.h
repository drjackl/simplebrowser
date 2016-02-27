//
//  FloatingToolbar.h
//  BlocBrowser
//
//  Created by Jack Li on 2/26/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FloatingToolbar; // forward declare since protocol defined before @interface and references FloatingToolbar

@protocol FloatingToolbarDelegate <NSObject>

@optional
- (void) floatingToolbar:(FloatingToolbar*)toolBar didSelectButtonWithTitle:(NSString*)title;

@end // delegate protocol definition


@interface FloatingToolbar : UIView

// Custom initializer
- (instancetype) initWithFourTitles:(NSArray*)titles;

// Enables/disables button based on title
- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString*)title;

// Delegate if so desired
@property (nonatomic, weak) id <FloatingToolbarDelegate> delegate;

@end
