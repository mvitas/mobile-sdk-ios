/*   Copyright 2013 APPNEXUS INC
 
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

#import "ANAdAdapterBannerDFP.h"

#import "DFPExtras.h"

@interface ANAdAdapterBannerDFP ()
@property (nonatomic, readwrite, strong) DFPBannerView *dfpBanner;
@end


/**
 * Server side overridable
 */
@interface DFPBannerServerSideParameters : NSObject
@property(nonatomic, readwrite) BOOL isSwipable;
@property(nonatomic, readwrite) BOOL isSmartBanner;
@end
@implementation DFPBannerServerSideParameters
@synthesize isSwipable;
@synthesize isSmartBanner;
@end



@implementation ANAdAdapterBannerDFP
@synthesize delegate;


#pragma mark ANCustomAdapterBanner

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(UIViewController *)rootViewController
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
            targetingParameters:(ANTARGETINGPARAMETERS *)targetingParameters
{
    NSLog(@"Requesting DFP banner with size: %0.1fx%0.1f", size.width, size.height);
	GADAdSize gadAdSize;
    DFPBannerServerSideParameters *ssparam = [self parseServerSide:parameterString];
    
    // Allow server side to enable Smart Banners for this placement
    if (ssparam.isSmartBanner) {
        UIApplication *application = [UIApplication sharedApplication];
        BOOL orientationIsPortrait = UIInterfaceOrientationIsPortrait([application statusBarOrientation]);
        if(orientationIsPortrait) {
            gadAdSize = kGADAdSizeSmartBannerPortrait;
        } else {
            gadAdSize = kGADAdSizeSmartBannerLandscape;
        }
    } else {
        gadAdSize = GADAdSizeFromCGSize(size);
    }
    
	GADRequest* request = [self createRequestFromTargetingParameters:targetingParameters];
    self.dfpBanner = [[DFPBannerView alloc] initWithAdSize:gadAdSize];
	self.dfpBanner.adUnitID = idString;
    self.dfpBanner.rootViewController = rootViewController;
    self.dfpBanner.delegate = self;
	[self.dfpBanner loadRequest:request];
}

- (GADRequest *)createRequestFromTargetingParameters:(ANTARGETINGPARAMETERS *)targetingParameters
{
	GADRequest *request = [GADRequest request];
    
    ANGENDER gender = targetingParameters.gender;
    switch (gender) {
        case MALE:
            request.gender = kGADGenderMale;
            break;
        case FEMALE:
            request.gender = kGADGenderFemale;
            break;
        case UNKNOWN:
            request.gender = kGADGenderUnknown;
        default:
            break;
    }

    ANLOCATION *location = targetingParameters.location;
    if (location) {
        [request setLocationWithLatitude:location.latitude
                               longitude:location.longitude
                                accuracy:location.horizontalAccuracy];
    }
    
    DFPExtras *extras = [DFPExtras new];
    NSMutableDictionary *extrasDictionary = [targetingParameters.customKeywords mutableCopy];

    NSString *age = targetingParameters.age;
    if (age) {
        [extrasDictionary setValue:age forKey:@"Age"];
    }
    
    extras.additionalParameters = extrasDictionary;
    
    [request registerAdNetworkExtras:extras];
    
    
    return request;
}


- (DFPBannerServerSideParameters*) parseServerSide:(NSString*) serverSideParameters
{
    DFPBannerServerSideParameters *p = [DFPBannerServerSideParameters new];
    NSError *jsonParsingError = nil;
    if (serverSideParameters == nil || [ serverSideParameters length] == 0) {
        return p;
    }

    NSData* data = [serverSideParameters dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    
    if (jsonParsingError == nil && jsonResponse != nil) {
        p.isSwipable = [[jsonResponse valueForKey:@"swipeable"] boolValue];
        p.isSmartBanner = [[jsonResponse valueForKey:@"smartbanner"] boolValue];
    }
    return p;
}

#pragma mark GADBannerViewDelegate

- (void)adViewDidReceiveAd:(DFPBannerView *)view
{
    NSLog(@"DFP banner did load");
	[self.delegate didLoadBannerAd:view];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"DFP banner failed to load with error: %@", [error localizedDescription]);
    ANAdResponseCode code = ANAdResponseInternalError;
    
    switch (error.code) {
        case kGADErrorInvalidRequest:
            code = ANAdResponseInvalidRequest;
            break;
        case kGADErrorNoFill:
            code = ANAdResponseUnableToFill;
            break;
        case kGADErrorNetworkError:
            code = ANAdResponseNetworkError;
            break;
        case kGADErrorServerError:
            code = ANAdResponseNetworkError;
            break;
        case kGADErrorOSVersionTooLow:
            code = ANAdResponseInternalError;
            break;
        case kGADErrorTimeout:
            code = ANAdResponseNetworkError;
            break;
        case kGADErrorInterstitialAlreadyUsed:
            code = ANAdResponseInternalError;
            break;
        case kGADErrorMediationDataError:
            code = ANAdResponseInvalidRequest;
            break;
        case kGADErrorMediationAdapterError:
            code = ANAdResponseInternalError;
            break;
        case kGADErrorMediationNoFill:
            code = ANAdResponseUnableToFill;
            break;
        case kGADErrorMediationInvalidAdSize:
            code = ANAdResponseInvalidRequest;
            break;
        case kGADErrorInternalError:
            code = ANAdResponseInternalError;
            break;
        case kGADErrorInvalidArgument:
            code = ANAdResponseInvalidRequest;
            break;
        default:
            code = ANAdResponseInternalError;
            break;
    }
    
 	[self.delegate didFailToLoadAd:(ANADRESPONSECODE)code];
}

- (void)adViewWillPresentScreen:(DFPBannerView *)adView {
    [self.delegate willPresentAd];
}

- (void)adViewWillDismissScreen:(DFPBannerView *)adView {
    [self.delegate willCloseAd];
}

- (void)adViewDidDismissScreen:(DFPBannerView *)adView {
    [self.delegate didCloseAd];
}

- (void)adViewWillLeaveApplication:(DFPBannerView *)adView {
    [self.delegate willLeaveApplication];
}

- (void)dealloc
{
    NSLog(@"DFP banner being destroyed");
	self.dfpBanner.delegate = nil;
	self.dfpBanner = nil;
}

@end
