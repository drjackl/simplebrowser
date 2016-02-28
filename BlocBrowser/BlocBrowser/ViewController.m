//
//  ViewController.m
//  BlocBrowser
//
//  Created by Jack Li on 2/23/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h> // for WKWebView
#import "FloatingToolbar.h"

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate, FloatingToolbarDelegate> // so VC can be webView's delegate (wV.delegate = self)

@property (nonatomic) WKWebView* webView; // default should be strong
@property (nonatomic) UITextField* textField;

@property (nonatomic, strong) FloatingToolbar* toolbar; // just making strong explicit

@property (nonatomic) UIActivityIndicatorView* activityIndicator;

//@property (nonatomic, strong) UIWebView* webView;
//@property (nonatomic, strong) WKWebView *myWebView;

@end

@implementation ViewController

// override (UIVC) to create view and add webView as subview
- (void) loadView {
    UIView* mainView = [UIView new];
    
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL or Google query (add a space)", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    // toolbar: initialize
    self.toolbar = [[FloatingToolbar alloc] initWithFourTitles:@[kWebBrowserBackString, kWebBrowserForwardString, kWebBrowserStopString, kWebBrowserRefreshString]];
    self.toolbar.delegate = self;
    
//    // experiment: load wikipedia.org when view loads
//    NSString* urlString = @"http://wikipedia.org";
//    NSURL* url = [NSURL URLWithString:urlString];
//    NSURLRequest* request = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:request];
    
    [mainView addSubview:self.webView];
    [mainView addSubview:self.textField];
    // toolbar: add as subview
    [mainView addSubview:self.toolbar];

    self.view = mainView;
    NSLog(@"end of loadView: Main view created and web view subview added");
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithCustomView:self.activityIndicator];
    //[self.activityIndicator startAnimating]; // experiment: see how it looks
    
    // move out of viewWillLayoutSubviews so only called once
    self.toolbar.frame = CGRectMake(20, 100, 280, 60); // original values
    
    // Do any additional setup after loading the view, typically from a nib.

//    // stack overflow, first solution -autorelease
//    // http://stackoverflow.com/questions/1769030/display-a-webpage-inside-a-uiwebview
//    [super viewDidLoad];
//    self.webView = [[UIWebView alloc]
//                     initWithFrame:CGRectMake(0, 0, 200, 300)];
//    
//    NSString *urlAddress = @"http://www.google.com";
//    NSURL *url = [[NSURL alloc] initWithString:urlAddress];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//    
//    [self.webView loadRequest:requestObj];
//    
//    [self.view addSubview:self.webView];

    
//    // stackoverflow: 2nd solution (storyboard)
//    // http://stackoverflow.com/questions/1769030/display-a-webpage-inside-a-uiwebview
//    [super viewDidLoad];
//    NSString *urlNameInString = @"https://www.google.com";
//    NSURL *url = [NSURL URLWithString:urlNameInString];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
//    
//    [self.view addSubview:self.myWebView];
//    
//    [self.myWebView loadRequest:urlRequest];
}

// override (UIVC) to set widget frames (before here,
// main view not guaranteed to have adjusted to rotation or resizing events)
- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // first, calculate some dimensions
    static const CGFloat itemHeight = 50; // for both url field and button bar
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;// - itemHeight; // used to be just be single itemHeight for url field
    
    // now, assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    //self.webView.frame = self.view.frame; // previously, the webview fill the main view
    
    //self.toolbar.frame = CGRectMake(20, 100, 280, 60); // original values
    //self.toolbar.frame = CGRectMake(200, 150, 480, 160); // experimental values
}

// deleting didReceiveMemoryWarning boilerplate method

#pragma mark - UITextFieldDelegate

// override <UITextFieldDelegate> to make URL field work
- (BOOL) textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    
    // start processing user input
    NSString* userInput = textField.text;
    
    NSString* urlString = userInput; // default url is just what user typed
    if ([userInput containsString:@" "]) { // but if contains space, we'll treat as Google search
        NSString* query = [userInput stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        urlString = [NSString stringWithFormat:@"http://google.com/search?q=%@", query];
    }
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    if (!url.scheme) { // user didn't type http:// or https:// so prepend
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", urlString]];
    }
    
    // load url request
    if (url) {
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
    
    return NO;
}

#pragma mark - WKNavigationDelegate

// override <WKNavigationDelegate> (called when page starts loading)
- (void) webView:(WKWebView*)webView didStartProvisionalNavigation:(WKNavigation*)navigation {
    [self updateButtonsAndTitle];
}

// override <WKNavigationDelegate> (called when page stops loading)
- (void) webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation {
    [self updateButtonsAndTitle];
}

// override <WKNavigationDelegate> to handle page load failure (also below method)
- (void) webView:(WKWebView*)webView
didFailProvisionalNavigation:(WKNavigation*)navigation
       withError:(NSError*)error {
    [self webView:webView didFailNavigation:navigation withError:error];
}

- (void) webView:(WKWebView*)webView didFailNavigation:(WKNavigation*)navigation
       withError:(NSError*)error {
    if (error.code != NSURLErrorCancelled) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [self updateButtonsAndTitle];
}

#pragma mark - FloatingToolbarDelegate
- (void) floatingToolbar:(FloatingToolbar*)toolBar didSelectButtonWithTitle:(NSString*)title {
    if ([title isEqual:kWebBrowserBackString]) {
        [self.webView goBack];
    } else if ([title isEqual:kWebBrowserForwardString]) {
        [self.webView goForward];
    } else if ([title isEqual:kWebBrowserStopString]) {
        [self.webView stopLoading];
    } else if ([title isEqual:kWebBrowserRefreshString]) {
        [self.webView reload];
    }
}

// only allow this drag placement if toolbar not pushed off screen
- (void) floatingToolbar:(FloatingToolbar*)toolBar didTryToPanWithOffset:(CGPoint)offset {
    CGPoint startingPoint = toolBar.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolBar.frame), CGRectGetHeight(toolBar.frame));
    //NSLog(@"View bounds: %@", NSStringFromCGRect(self.view.bounds));
    NSLog(@"New frame: %@", NSStringFromCGRect(potentialNewFrame));
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolBar.frame = potentialNewFrame;
    }
}

// similar to panning/dragging, only allow if fits within view bounds
- (void) floatingToolbar:(FloatingToolbar*)toolBar didTryToResizeWithScale:(CGFloat)scale {
    CGPoint startingPoint = toolBar.frame.origin;
    CGSize newSize = CGSizeMake(CGRectGetWidth(toolBar.frame)*scale, CGRectGetHeight(toolBar.frame)*scale);
    CGFloat offsetX = (newSize.width-CGRectGetWidth(toolBar.frame)) / 2;
    CGFloat offsetY = (newSize.height-CGRectGetHeight(toolBar.frame)) / 2;
    NSLog(@"New Size: %@", NSStringFromCGSize(newSize));
    NSLog(@"Offsets: %.2f %.2f", offsetX, offsetY);
    
    CGRect potentialNewFrame = CGRectMake(startingPoint.x - offsetX,
                                          startingPoint.y - offsetY,
                                          newSize.width, newSize.height);
    //NSLog(@"View bounds: %@", NSStringFromCGRect(self.view.bounds));
    NSLog(@"New frame: %@", NSStringFromCGRect(potentialNewFrame));
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolBar.frame = potentialNewFrame;
    }
    
//    CGSize startingSize = toolBar.frame.size;
//    CGSize newSize = CGSizeMake(startingSize.width * scale, startingSize.height * scale);
//    
//    //CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolBar.frame), CGRectGetHeight(toolBar.frame));
//    CGRect potentialNewFrame = CGRectMake(CGRectGetMinX(toolBar.frame), CGRectGetMinY(toolBar.frame), newSize.width, newSize.height);
//    //NSLog(@"View bounds: %@", NSStringFromCGRect(self.view.bounds));
//    NSLog(@"New frame: %@", NSStringFromCGRect(potentialNewFrame));
//    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
//        toolBar.frame = potentialNewFrame;
//    }
}

#pragma mark - Miscellaneous

// handle all UI updates: updating page title, enable/disable buttons in bar, spinner
- (void) updateButtonsAndTitle {
    // set nav bar title to page title or url addy
    self.title = self.webView.URL.absoluteString;
    if ([self.webView.title length]) { // if page has a title, use it instead of url addy
        self.title = [self.webView.title copy];
    }
    // if loading, set spinner
    if (self.webView.isLoading) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    // set enabled state of buttons
    [self.toolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.toolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.toolbar setEnabled:[self.webView isLoading] forButtonWithTitle:kWebBrowserStopString];
    [self.toolbar setEnabled:![self.webView isLoading]&&self.webView.URL forButtonWithTitle:kWebBrowserRefreshString]; // since page can be clear after loading (restting), must also ensure a page has a URL if it can be reloaded
}

- (void) resetWebView {
    [self.webView removeFromSuperview];
    
    WKWebView* newWebView = [[WKWebView alloc] init];
    newWebView.navigationDelegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    self.textField.text = nil;
    
    [self updateButtonsAndTitle];
}

@end
