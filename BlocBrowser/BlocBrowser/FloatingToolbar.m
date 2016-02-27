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
@property (nonatomic) NSArray* labels;
@property (nonatomic, weak) UILabel* currentLabel;

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
        
        // make the 4 labels
        NSMutableArray* labelsArray = [[NSMutableArray alloc] init];
        [self.currentTitles enumerateObjectsUsingBlock:^(NSString* currentTitle, NSUInteger currentTitleIndex, BOOL * _Nonnull stop) {
            UILabel* label = [[UILabel alloc] init];
            label.userInteractionEnabled = NO; // does not initially receive touch events
            label.alpha = 0.25;
            
            label.text = currentTitle;
            UIColor* colorForThisLabel = self.colors[currentTitleIndex];
            label.backgroundColor = colorForThisLabel;
            
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label]; // missing this one line caused toolbar to not show!!
        }];
        
        self.labels = labelsArray;
        
        for (UILabel* thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
    }
    return self;
}

- (void) layoutSubviews {
    // set frames for the 4 labels: top buttons indexes 0 1, bottom 2 3
    [self.labels enumerateObjectsUsingBlock:^(UILabel* thisLabel, NSUInteger currentLabelIndex, BOOL * _Nonnull stop) {
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        // adjust labelX and labelY for each label
        if (currentLabelIndex > 1) { // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        if (currentLabelIndex % 2 == 1) { // 1 or 3, so on the right
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }];
}

#pragma mark - Touch Handling

- (UILabel*) labelFromTouches:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self]; // finds touch coordinates
    UIView* subview = [self hitTest:location withEvent:event]; // finds view
    
    if ([subview isKindOfClass:[UILabel class]]) {
        return (UILabel *)subview;
    } else {
        return nil;
    }
}

// when touch begins, dim label to highlight and store currentLable
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UILabel* label = [self labelFromTouches:touches withEvent:event];
    
    self.currentLabel = label;
    self.currentLabel.alpha = 0.5;
}

// when touch moves, check if touching same label
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    UILabel* label = [self labelFromTouches:touches withEvent:event];
    
    if (self.currentLabel != label) { // initial label no longer being touched
        self.currentLabel.alpha = 1;
    } else { // initial label still being touched
        self.currentLabel.alpha = 0.5;
    }
}

// if finger lifted over same label, inform the delegate
- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent*)event {
    UILabel* label = [self labelFromTouches:touches withEvent:event];
    
    if (self.currentLabel == label) {
        NSLog(@"Label tapped: %@", self.currentLabel.text);
        
        // always required to check for optional protocol methods, else app crash
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
            [self.delegate floatingToolbar:self didSelectButtonWithTitle:self.currentLabel.text];
        }
    }
    
    // either way, reset tracking variables to initial values
    self.currentLabel.alpha = 1;
    self.currentLabel = nil;
}

// if touch cancelled, reset tracking variables
- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    self.currentLabel.alpha = 1;
    self.currentLabel = nil;
}

#pragma mark - Button Enabling


- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel* label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
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
