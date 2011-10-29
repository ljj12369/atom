#import "AtomController.h"
#import "AtomApp.h"

#import <WebKit/WebKit.h>
#import "JSCocoa.h"

@implementation AtomController

@synthesize webView, path;

- (void)dealloc {
  [jscocoa unlinkAllReferences];
  [jscocoa garbageCollect];
  [jscocoa release]; jscocoa = nil;

  [webView release];
  [path release];

  [super dealloc];
}

- (id)initWithPath:(NSString *)aPath {
  self = [super initWithWindowNibName:@"AtomWindow"];
  [self setPath:aPath];

  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  
  [webView setUIDelegate:self];

  [self setShouldCascadeWindows:YES];
  [self setWindowFrameAutosaveName:@"atomController"];

  jscocoa = [[JSCocoa alloc] initWithGlobalContext:[[webView mainFrame] globalContext]];
  [jscocoa setObject:self withName:@"atomController"];

  NSURL *resourceURL = [[NSBundle mainBundle] resourceURL];
  NSURL *indexURL = [resourceURL URLByAppendingPathComponent:@"index.html"];
  NSURLRequest *request = [NSURLRequest requestWithURL:indexURL];
  [[webView mainFrame] loadRequest:request];    
}

- (void)close {
  [(AtomApp *)NSApp removeController:self];
  [super close];
}

- (BOOL)handleKeyEvent:(NSEvent *)event {
  // ICKY: Using a global function defined in App.js to deal with key events
  JSValueRef returnValue = [jscocoa callJSFunctionNamed:@"handleKeyEvent" withArguments:event, nil];
  return [jscocoa toBool:returnValue];
}

// WebUIDelegate Protocol
- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems {
  return defaultMenuItems;
}


@end
