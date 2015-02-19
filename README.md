# WTWindowTimers

In iOS 7, Apple introduced the possibility to [execute JavaScript via the JavaScriptCore JavaScript 
engine] (http://nshipster.com/javascriptcore/). Unfortunately, JavaScriptCore is missing some 
objects and functions a JavaScript environment of a browser would have. Especially the methods 
described in the [WTWindowTimers specification]
(https://html.spec.whatwg.org/multipage/webappapis.html#windowtimers), such as `setTimeout` or 
`setInterval` are not provided. This library implements those methods, so it is possible to use
JavaScript libraries which were originally developed for in-browser use in your Objective-C 
(or Swift) application without the need to use a hidden WebView.
 
 
## Provided functions
This library tries to implement the full specification fo the Window Timers, including passing a
string as first argument to `setTimeout` or `setInterval` or passing additional arguments to both
mentioned functions.

## How to use it
Create a new instance of the `WTWindowTimers` class. Then call the `extend:` method and pass either
a `JSContext` instance or a `JSValue` instance. The given object will be extend with the functions.
 
```
#import <WindowTimers/WindowTimers.h>

...

JSContext *jsContext = [JSContext new];

WTWindowTimers *timers = [WTWindowTimers new];
[timers extend:jsContext];

// Now jsContext has the additional functions setTimeout, clearTimeout, setInterval, clearInterval
jsContext[@"callCounter"] = @0;
[jsContext evaluateScript:@"setTimeout(function(){callCounter += 1;}, 1000);"];

// Run the main loop for at least 1.1 seconds so we make sure that the callback is executed.
[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
NSLog(@"callCounter is %@", jsContext[@"callCounter"]); // Will log 1.

```
