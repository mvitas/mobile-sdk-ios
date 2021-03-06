/*
 *
 *    Copyright 2017 APPNEXUS INC
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */


#import "ANVideoAdPlayer+Test.h"
#import "NSObject+Swizzling.h"
#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#import "ANTimeTracker.h"

@implementation ANVideoAdPlayer(Test)

@dynamic vastURLContent;
@dynamic creativeURL;
@dynamic videoDuration;
@dynamic vastXMLContent;
//@dynamic playHeadTimeForVideo;



-(void)createInstreamVideoWithDuration{
    self.videoDuration = 10;
}


-(void)createInstreamVideoWithCreativeTag{
    self.creativeURL =  @"http://sampletag.com";
}

-(void)createInstreamVideoWithVastCreativeURL{
    self.vastURLContent =  @"http://sampletag.com";
  }

-(void)createInstreamVideoWithVASTCreativeXML;
{
    self.vastXMLContent =  @"http://sampletag.com";
}

-(NSUInteger) getAdPlayElapsedTime{
    return 10;
}

+ (void)load {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
    
        [[self class] exchangeInstanceSelector:@selector(webView:didStartProvisionalNavigation:)
                                  withSelector:@selector(test_webView:didStartProvisionalNavigation:)];
        
        [[self class] exchangeInstanceSelector:@selector(webView:didFinishNavigation:)
                                  withSelector:@selector(test_webView:didFinishNavigation:)];
    }];
    [operation start];
}

-(void)test_webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [ANTimeTracker sharedInstance].webViewInitLoadingAt = [NSDate date];
    [self test_webView:webView didStartProvisionalNavigation:navigation];
}

- (void)test_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [ANTimeTracker sharedInstance].webViewFinishLoadingAt = [NSDate date];
    [self test_webView:webView didFinishNavigation:navigation];
}


@end
