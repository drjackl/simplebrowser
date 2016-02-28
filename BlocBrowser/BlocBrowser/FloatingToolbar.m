//
//  FloatingToolbar.m
//  BlocBrowser
//
//  Created by Jack Li on 2/26/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "FloatingToolbar.h"

@interface FloatingToolbar () // extension

@property (nonatomic) NSArray* currentTitles;
@property (nonatomic) NSArray* colors;
@property (nonatomic) int rotationOffset; // for color rotation
@property (nonatomic) NSMutableArray* buttons; // mutable for rotation
//@property (nonatomic) NSArray* labels;
//@property (nonatomic, weak) UILabel* currentLabel;

@property (nonatomic) UITapGestureRecognizer* tapGesture; // includes touchesEvents now
@property (nonatomic) UIPanGestureRecognizer* panGesture;

@property (nonatomic) UIPinchGestureRecognizer* pinchGesture;
@property (nonatomic) UILongPressGestureRecognizer* pressGesture;

@end


@implementation FloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    self = [super init];
    if (self) {
        // save titles, set 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:165/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        self.rotationOffset = 0;
        // make the 4 labels
//        NSMutableArray* labelsArray = [[NSMutableArray alloc] init];
//        [self.currentTitles enumerateObjectsUsingBlock:^(NSString* currentTitle, NSUInteger currentTitleIndex, BOOL * _Nonnull stop) {
//            UILabel* label = [[UILabel alloc] init];
//            label.userInteractionEnabled = NO; // does not initially receive touch events
//            label.alpha = 0.25;
//            
//            label.text = currentTitle;
//            UIColor* colorForThisLabel = self.colors[currentTitleIndex];
//            label.backgroundColor = colorForThisLabel;
//            
//            label.textAlignment = NSTextAlignmentCenter;
//            label.font = [UIFont systemFontOfSize:10];
//            label.textColor = [UIColor whiteColor];
//            
//            [labelsArray addObject:label]; // missing this one line caused toolbar to not show!!
//        }];
        NSMutableArray* buttonsArray = [[NSMutableArray alloc] init];
        [self.currentTitles enumerateObjectsUsingBlock:^(NSString* currentTitle, NSUInteger currentTitleIndex, BOOL * _Nonnull stop) {
            UIButton* button = [[UIButton alloc] init];//[UIButton buttonWithType:UIButtonTypeCustom];
            //button.userInteractionEnabled = NO; // does not initially receive touch events
            button.enabled = NO;
            button.alpha = 0.25;
            
            //button.titleLabel.text = @"TESTTTTT"; // doesn't work, use setTitle:
            [button setTitle:currentTitle forState:UIControlStateNormal];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted]; // mimic transparent background when pressed
            UIColor* colorForThisLabel = self.colors[currentTitleIndex];
            button.backgroundColor = colorForThisLabel;
            
//            button.titleLabel.textAlignment = NSTextAlignmentCenter; // no need in button
            button.titleLabel.font = [UIFont systemFontOfSize:10];
//            button.titleLabel.textColor = [UIColor whiteColor]; // use setTitleColor:
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [buttonsArray addObject:button]; // missing this one line caused toolbar to not show!!
        }];
        
        //self.labels = labelsArray;
        self.buttons = buttonsArray;
        
        // need to add target-action to buttons for behavior!
        for (UIButton* button in self.buttons) {
            if ([button.titleLabel.text isEqualToString:@"Back"]) {
                [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
            } else if ([button.titleLabel.text isEqualToString:@"Forward"]) {
                [button addTarget:self action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
            } else if ([button.titleLabel.text isEqualToString:@"Stop"]) {
                [button addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
            } else if ([button.titleLabel.text isEqualToString:@"Refresh"]) {
                [button addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
//        for (UILabel* thisLabel in self.labels) {
//            [self addSubview:thisLabel];
//        }
        for (UIButton* thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)]; // assign method to call when tap detected
        [self addGestureRecognizer:self.tapGesture]; // tell view to route touch events through this gesture recognizer
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        self.pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.pressGesture];
    }
    return self;
}

- (void) doWebCommand:(NSString*)command {
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:command];
    }
}

- (void) goBack {
    [self doWebCommand:@"Back"];
}

- (void) goForward {
    [self doWebCommand:@"Forward"];
}

- (void) stop {
    [self doWebCommand:@"Stop"];
}

- (void) reload {
    [self doWebCommand:@"Refresh"];
}

- (void) layoutSubviews {
    // set frames for the 4 labels: top buttons indexes 0 1, bottom 2 3
//    [self.labels enumerateObjectsUsingBlock:^(UILabel* thisLabel, NSUInteger currentLabelIndex, BOOL * _Nonnull stop) {
//        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
//        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
//        
//        CGFloat labelX = 0;
//        CGFloat labelY = 0;
//        // adjust labelX and labelY for each label
//        if (currentLabelIndex > 1) { // 2 or 3, so on bottom
//            labelY = CGRectGetHeight(self.bounds) / 2;
//        }
//        if (currentLabelIndex % 2 == 1) { // 1 or 3, so on the right
//            labelX = CGRectGetWidth(self.bounds) / 2;
//        }
//        
//        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
//    }];
    [self.buttons enumerateObjectsUsingBlock:^(UIButton* thisButton, NSUInteger i, BOOL * _Nonnull stop) { // forgot to change to UIButton* but still not clicking on buttons
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
        
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        // adjust labelX and labelY for each label
        if (i > 1) { // 2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        if (i % 2 == 1) { // 1 or 3, so on the right
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }];
}

#pragma mark - Touch Handling

// given a touch, find the label underneath (if it is a label)
//- (UILabel*) labelFromTouches:(NSSet*)touches withEvent:(UIEvent*)event {
//    UITouch* touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self]; // finds touch coordinates
//    UIView* subview = [self hitTest:location withEvent:event]; // finds view
//    
//    if ([subview isKindOfClass:[UILabel class]]) {
//        return (UILabel *)subview;
//    } else {
//        return nil;
//    }
//}

- (void) tapFired:(UITapGestureRecognizer*)recognizer {
    // first, detect that state was recognized (all other states undetected)
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [recognizer locationInView:self]; // get gesture location wrt self.bounds
        UIView* tappedView = [self hitTest:location withEvent:nil]; // finds view
        
        // check if view was in fact one of our labels
//        if ([self.labels containsObject:tappedView]) {
        if ([self.buttons containsObject:tappedView]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
//                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel*)tappedView).text]; // need to cast to UILabel to get text attribute
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UIButton*)tappedView).titleLabel.text]; // need to cast to UILabel to get text attribute

            }
        }
    }
}

- (void) panFired:(UIPanGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) { // StateRecognized is finger lifted
        // location no longer important but what direction it travelled in
        CGPoint translation = [recognizer translationInView:self];
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        // at end, reset translation to zero so we get difference of each mini-pan
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Pinch scale: %f", recognizer.scale);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToResizeWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToResizeWithScale:recognizer.scale];
        }
        
        [recognizer setScale:1.0]; // need to reset each time, else not smooth
    }
}

- (void) longPressFired:(UILongPressGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //[self rotateButtons];
        [self rotateColors];
    }
}

// 0 1 >> 2 0
// 2 3    3 1
// 0 -> 1, 1 -> 3, 3 -> 2, 2 -> 0
// 0.x += buttonWidth, 1.y += buttonHeight, 3.x -= buttonWdith, 2.y -= buttonHeight
- (void) rotateButtons {
//    CGSize buttonSize = ((UIButton*)self.buttons[0]).frame.size;
//    
//    //((UIButton*)self.buttons[0]).frame.origin.x += buttonSize.width; // doesn't work
//    
//    [self.buttons enumerateObjectsUsingBlock:^(UIButton* thisButton, NSUInteger i, BOOL * _Nonnull stop) {
//        //CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
//        //CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
//        
//        CGFloat buttonX = 0;
//        CGFloat buttonY = 0;
//        // adjust labelX and labelY for each label
//        if (i % 2 == 1) { // on bottom: 3 or 1 (used to be 2 or 3)
//            buttonY = buttonSize.height;
//        }
//        if (i < 2) { // on right: 0 or 1 (used to be 1 or 3)
//            buttonX = buttonSize.width;
//        }
//        
//        thisButton.frame = CGRectMake(buttonX, buttonY, buttonSize.width, buttonSize.height);
//    }];
    
    
    // rotate positions in array
    UIButton* placeholder = self.buttons[2];
    self.buttons[2] = self.buttons[3];
    self.buttons[3] = self.buttons[1];
    self.buttons[1] = self.buttons[0];
    self.buttons[0] = placeholder;
    
    [self layoutSubviews];
    //[self setNeedsDisplay];
}

- (void) rotateColors {
    [self.buttons enumerateObjectsUsingBlock:^(UIButton* btn, NSUInteger i, BOOL * _Nonnull stop) {
        btn.backgroundColor = self.colors[(i - self.rotationOffset) % self.colors.count];
    }];
    self.rotationOffset = (self.rotationOffset + 1) % self.colors.count;
}

//// when touch begins, dim label to highlight and store currentLabel
//- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UILabel* label = [self labelFromTouches:touches withEvent:event];
//    
//    self.currentLabel = label;
//    self.currentLabel.alpha = 0.5;
//}
//
//// when touch moves, check if touching same label
//- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
//    UILabel* label = [self labelFromTouches:touches withEvent:event];
//    
//    if (self.currentLabel != label) { // initial label no longer being touched
//        self.currentLabel.alpha = 1;
//    } else { // initial label still being touched
//        self.currentLabel.alpha = 0.5;
//    }
//}
//
//// if finger lifted over same label, inform the delegate
//- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent*)event {
//    UILabel* label = [self labelFromTouches:touches withEvent:event];
//    
//    if (self.currentLabel == label) {
//        NSLog(@"Label tapped: %@", self.currentLabel.text);
//        
//        // always required to check for optional protocol methods, else app crash
//        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
//            [self.delegate floatingToolbar:self didSelectButtonWithTitle:self.currentLabel.text];
//        }
//    }
//    
//    // either way, reset tracking variables to initial values
//    self.currentLabel.alpha = 1;
//    self.currentLabel = nil;
//}
//
//// if touch cancelled, reset tracking variables
//- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
//    self.currentLabel.alpha = 1;
//    self.currentLabel = nil;
//}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    //NSUInteger index = [self.currentTitles indexOfObject:title]; // cannot use self.currentTitles
    NSUInteger index = [self.buttons indexOfObjectPassingTest:^BOOL(UIButton* btn, NSUInteger idx, BOOL * _Nonnull stop) {
        return [btn.titleLabel.text isEqualToString:title];
    }];
    
    if (index != NSNotFound) {
//        UILabel* label = [self.labels objectAtIndex:index];
//        label.userInteractionEnabled = enabled;
//        label.alpha = enabled ? 1.0 : 0.25;
        UIButton* button = [self.buttons objectAtIndex:index];
        //button.userInteractionEnabled = enabled;
        button.enabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
