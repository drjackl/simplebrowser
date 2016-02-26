//
//  ViewController.m
//  BlocBrowser
//
//  Created by Jack Li on 2/23/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h> // for WKWebView

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate> // so VC can be webView's delegate (wV.delegate = self)

@property (nonatomic) WKWebView* webView; // default should be strong
@property (nonatomic) UITextField* textField;

@property (nonatomic, strong) UIButton* backButton; // just making strong explicit
@property (nonatomic, strong) UIButton* forwardButton;
@property (nonatomic, strong) UIButton* stopButton;
@property (nonatomic, strong) UIButton* reloadButton;

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
    
    // button bar: 1. initialize
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];
    
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setEnabled:NO];
    
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setEnabled:NO];
    
    // button bar: 2. set titles and targets
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back command") forState:UIControlStateNormal];
    [self.backButton addTarget:self.webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward command") forState:UIControlStateNormal];
    [self.forwardButton addTarget:self.webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop command") forState:UIControlStateNormal];
    [self.stopButton addTarget:self.webView action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    
    [self.reloadButton setTitle:NSLocalizedString(@"Refresh", @"Reload command") forState:UIControlStateNormal];
    [self.reloadButton addTarget:self.webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    
//    // experiment: load wikipedia.org when view loads
//    NSString* urlString = @"http://wikipedia.org";
//    NSURL* url = [NSURL URLWithString:urlString];
//    NSURLRequest* request = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:request];
    
    [mainView addSubview:self.webView];
    [mainView addSubview:self.textField];
    // button bar: 3. add as subviews (could also put self.webView and self.textField in below array too)
    for (UIView* viewToAdd in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        [mainView addSubview:viewToAdd];
    }
    
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
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight; // used to be just be single itemHeight for url field
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    // now, assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    //self.webView.frame = self.view.frame; // previously, the webview fill the main view
    CGFloat currentButtonX = 0;
    for (UIButton* button in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        button.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webView.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
    }
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
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
    self.stopButton.enabled = self.webView.isLoading;
    self.reloadButton.enabled = !self.webView.isLoading;
}

@end
