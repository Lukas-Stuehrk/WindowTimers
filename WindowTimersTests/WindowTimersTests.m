#import <Kiwi/Kiwi.h>
#import <UIKit/UIKit.h>
#import "WindowTimers.h"


SPEC_BEGIN(WindowTimersTests)
    __block WTWindowTimers *timers;
    __block JSContext *context;

    beforeEach(^{
        timers = [WTWindowTimers new];
        context = [JSContext new];
        [timers extend:context];
    });

    describe(@"the extend: method", ^{
        it(@"should provide the functions", ^{
            // Create a new context, since the test context is already extended.
            JSContext *jsContext = [JSContext new];

            [timers extend:jsContext];

            [[theValue([jsContext[@"setTimeout"] isUndefined]) should] beNo];
            [[theValue([jsContext[@"clearTimeout"] isUndefined]) should] beNo];
            [[theValue([jsContext[@"setInterval"] isUndefined]) should] beNo];
            [[theValue([jsContext[@"clearInterval"] isUndefined]) should] beNo];
        });

        it(@"should extend a JavaScript object", ^{
            [context evaluateScript:@"var foo = {}"];
            JSValue *foo = context[@"foo"];

            [timers extend:foo];

            [[theValue([foo[@"setTimeout"] isUndefined]) should] beNo];
            [[theValue([foo[@"clearTimeout"] isUndefined]) should] beNo];
            [[theValue([foo[@"setInterval"] isUndefined]) should] beNo];
            [[theValue([foo[@"clearInterval"] isUndefined]) should] beNo];
        });
    });

    describe(@"the setTimeout function", ^{
        it(@"should return the ID of the timeout", ^{
            JSValue *called = [context evaluateScript:@"setTimeout(function(){}, 100);"];
            [[theValue([called isNumber]) should] beYes];
        });

        it(@"should return unique IDs", ^{
            JSValue *firstID = [context evaluateScript:@"setTimeout(function(){}, 100);"];
            JSValue *secondID = [context evaluateScript:@"setTimeout(function(){}, 100);"];
            [[firstID shouldNot] equal:secondID];
        });

        it(@"should execute the given function", ^{
            [context evaluateScript:@"setTimeout(function(){called=true;}, 100)"];

            [[expectFutureValue(theValue([context[@"called"] toBool])) shouldEventually] beYes];
        });

        it(@"should execute the given function after the specific time", ^{
            __block CFTimeInterval startTime = 0;
            __block BOOL called = NO;
            context[@"callback"] = ^{
                called = YES;
                [[theValue(CACurrentMediaTime() - startTime) should] beLessThan:theValue(1.50)];
            };

            startTime = CACurrentMediaTime();
            [context evaluateScript:@"setTimeout(callback, 1000)"];

            [[expectFutureValue(theValue(called)) shouldEventually] beYes];
        });

        it(@"should pass the additional arguments to the callback", ^{
            __block BOOL called = NO;
            context[@"callback"] = ^(JSValue *firstArg, JSValue *secondArg, JSValue *thirdArg) {
                called = YES;
                [[[firstArg toString] should] equal:@"foo"];
                [[[secondArg toString] should] equal:@"bar"];
                [[[thirdArg toString] should] equal:@"foobar"];
            };
            [context evaluateScript:@"setTimeout(callback, 100, 'foo', 'bar', 'foobar');"];

            [[expectFutureValue(theValue(called)) shouldEventually] beYes];
        });
    });

    describe(@"The clearTimeout function", ^{
        it(@"should prevent a timeout", ^{
            __block BOOL called = NO;
            context[@"callback"] = ^{
                called = YES;
            };

            [context evaluateScript:@"var timeoutID = setTimeout(callback, 100)"];
            [context evaluateScript:@"clearTimeout(timeoutID);"];

            [[expectFutureValue(theValue(called)) shouldEventually] beNo];
        });
    });

    describe(@"the setInterval function", ^{
        it(@"should return the ID of the timeout", ^{
            JSValue *called = [context evaluateScript:@"setInterval(function(){}, 100);"];
            [[theValue([called isNumber]) should] beYes];
        });

        it(@"should return unique IDs", ^{
            JSValue *firstID = [context evaluateScript:@"setInterval(function(){}, 100);"];
            JSValue *secondID = [context evaluateScript:@"setInterval(function(){}, 100);"];
            [[firstID shouldNot] equal:secondID];
        });

        it(@"should execute the given function", ^{
            __block NSUInteger counter = 0;
            context[@"callback"] = ^{
                counter += 1;
            };

            [context evaluateScript:@"setInterval(callback, 100)"];
            [[expectFutureValue(theValue(counter)) shouldEventually] beGreaterThanOrEqualTo:
                    theValue(10)];
        });

        it(@"should execute the given function within the given interval", ^{
            __block NSUInteger counter = 0;
            __block CFTimeInterval lastCallTime = 0;
            context[@"callback"] = ^{
                counter += 1;
                [[theValue(CACurrentMediaTime() - lastCallTime) should] beLessThan:theValue(0.2)];

                lastCallTime = CACurrentMediaTime();
            };

            lastCallTime = CACurrentMediaTime();
            [context evaluateScript:@"setInterval(callback, 100)"];
            [[expectFutureValue(theValue(counter)) shouldEventually] beGreaterThan:theValue(5)];
        });

        it(@"should pass the additional arguments to the callback", ^ {
            __block BOOL called = NO;
            context[@"callback"] = ^(JSValue *firstArg, JSValue *secondArg, JSValue *thirdArg) {
                called = YES;
                [[[firstArg toString] should] equal:@"foo"];
                [[[secondArg toString] should] equal:@"bar"];
                [[[thirdArg toString] should] equal:@"foobar"];
            };
            [context evaluateScript:@"setInterval(callback, 100, 'foo', 'bar', 'foobar');"];

            [[expectFutureValue(theValue(called)) shouldEventually] beYes];
        });
    });

    describe(@"the clearInterval function", ^{
        it(@"should prevent an interval", ^{
            __block BOOL called = NO;
            context[@"callback"] = ^{
                called = YES;
            };

            [context evaluateScript:@"var timeoutID = setInterval(callback, 100)"];
            [context evaluateScript:@"clearInterval(timeoutID);"];

            [[expectFutureValue(theValue(called)) shouldEventually] beNo];
        });
    });

SPEC_END
