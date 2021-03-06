/**
* Tae Won Ha — @hataewon
*
* http://taewon.de
* http://qvacua.com
*
* See LICENSE
*/

#import <WebKit/WebKit.h>
#import <OCDiscount/OCDiscount.h>
#import "VRMarkdownPreviewView.h"


#define CONSTRAINT(fmt) [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:fmt options:0 metrics:nil views:views]]


@implementation VRMarkdownPreviewView {
  CGFloat _pageYOffset;
  CGFloat _pageXOffset;

  WebView *_webView;
  NSString *_template;
  NSString *_errorHtml;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
  [_webView stringByEvaluatingJavaScriptFromString:
      [NSString stringWithFormat:@"window.scrollTo(%f, %f)", _pageXOffset, _pageYOffset]
  ];
}

- (id)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (!self) {return nil;}

  _webView = [[WebView alloc] initWithFrame:CGRectZero];
  _webView.translatesAutoresizingMaskIntoConstraints = NO;
  _webView.frameLoadDelegate = self;
  [self addSubview:_webView];

  NSDictionary *views = @{
      @"webView" : _webView,
  };

  CONSTRAINT(@"H:|[webView]|");
  CONSTRAINT(@"V:|[webView]|");

  NSURL *templateUrl = [[NSBundle bundleForClass:[self class]] URLForResource:@"template" withExtension:@"html"];
  _template = [NSString stringWithContentsOfURL:templateUrl encoding:NSUTF8StringEncoding error:NULL];

  NSURL *errorHtmlUrl = [[NSBundle bundleForClass:[self class]] URLForResource:@"error" withExtension:@"html"];
  _errorHtml = [NSString stringWithContentsOfURL:errorHtmlUrl encoding:NSUTF8StringEncoding error:NULL];

  return self;
}

- (BOOL)previewFileAtUrl:(NSURL *)url {
  _pageYOffset = [_webView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"].floatValue;
  _pageXOffset = [_webView stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"].floatValue;

  NSString *markdown = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
  NSString *htmlContent = [markdown htmlFromMarkdown];

  NSString *result = nil;
  if (htmlContent == nil) {
    result = _errorHtml;
  } else {
    result = [_template stringByReplacingOccurrencesOfString:@"<% TITLE %>" withString:url.lastPathComponent];
    result = [result stringByReplacingOccurrencesOfString:@"<% CONTENT %>" withString:htmlContent];
  }

  [_webView.mainFrame loadHTMLString:result baseURL:url.URLByDeletingLastPathComponent];

  return YES;
}

@end
