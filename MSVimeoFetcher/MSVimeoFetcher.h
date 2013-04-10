//
//  MSVimeoFetcher.h
//  MSVimeoFetcher
//
//  Created by Eric Horacek on 4/9/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MSVimeoFetcherQuality) {
    MSVimeoFetcherQualityLow,
    MSVimeoFetcherQualityMedium,
    MSVimeoFetcherQualityHigh
};

extern NSString * const MSVimeoFetcherErrorDomain;
extern NSInteger const MSVimeoFetcherErrorHTMLParseFailure;
extern NSInteger const MSVimeoFetcherErrorRedirectFailure;

@interface MSVimeoFetcher : NSObject

+ (void)fetchStreamURLFromVideoURL:(NSURL *)videoURL quality:(MSVimeoFetcherQuality)quality completion:(void (^)(NSURL *streamURL, NSError *error))completion;

@end
