/*   Copyright 2014 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <objc/runtime.h>
#import "ANTimeTracker.h"
#import "ANAdFetcherBase+ANTest.h"
#import "NSObject+Swizzling.h"
#import <objc/runtime.h>
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation ANAdFetcherBase (ANTest)
#pragma clang diagnostic pop



+ (void)load {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
    
        [[self class] exchangeInstanceSelector:@selector(requestAd)
                                  withSelector:@selector(test_requestAd)];
        [[self class] exchangeInstanceSelector:@selector(handleAdServerResponse:)
                                  withSelector:@selector(test_handleAdServerResponse:)];
        

        
//        [[self class] exchangeInstanceSelector:@selector(webView:didFinishNavigation:)
//                                  withSelector:@selector(test_webView:didFinishNavigation:)];
    }];
    [operation start];
}



-(void)test_requestAd{
    [ANTimeTracker sharedInstance].networkAdRequestInit = [NSDate date];
    [self test_requestAd];
}

- (void)test_handleAdServerResponse:(NSData *)data{
    [ANTimeTracker sharedInstance].networkAdRequestComplete = [NSDate date];
    [self test_handleAdServerResponse:data];

}
@end