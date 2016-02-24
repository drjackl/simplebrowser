//
//  ViewController.m
//  BlocBrowser
//
//  Created by Jack Li on 2/23/16.
//  Copyright © 2016 Jack Li. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h> // for WKWebView

@interface ViewController () <WKNavigationDelegate> // so VC can be webView's delegate (wV.delegate = self)

@property (nonatomic, strong) WKWebView* webView;

//@property (nonatomic, strong) UIWebView* webView;
//@property (nonatomic, strong) WKWebView *myWebView;

@end

@implementation ViewController

// override to create view and add webView as subview
- (void) loadView {
    UIView* mainView = [UIView new];
    
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    // experiment: load wikipedia.org when view loads
    NSString* urlString = @"http://google.com";
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    [mainView addSubview:self.webView];
    
    self.view = mainView;
    NSLog(@"Main view created and web view subview added");
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

// override (before here, main view not guaranteed to have adjusted to rotation or resizing events)
- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // make the webview fill the main view
    self.webView.frame = self.view.frame;
}

// deleting didReceiveMemoryWarning boilerplate method

@end
