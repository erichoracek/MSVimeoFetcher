//
//  MSVimeoFetcher.m
//  MSVimeoFetcher
//
//  Created by Eric Horacek on 4/9/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSVimeoFetcher.h"
#import "AFNetworking.h"

NSString * const MSVimeoFetcherUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3";
NSString * const MSVimeoFetcherErrorDomain = @"MSVimeoFetcherErrorDomain";
NSInteger const MSVimeoFetcherErrorHTMLParseFailure = 1;
NSInteger const MSVimeoFetcherErrorRedirectFailure = 2;

@implementation MSVimeoFetcher

+ (void)fetchStreamURLFromVideoURL:(NSURL *)videoURL quality:(MSVimeoFetcherQuality)quality completion:(void (^)(NSURL *url, NSError *error))completion
{
    NSParameterAssert(videoURL);
    NSParameterAssert(completion);
    void(^parseError)() = ^() {
        completion(nil, [NSError errorWithDomain:MSVimeoFetcherErrorDomain code:MSVimeoFetcherErrorHTMLParseFailure userInfo:@{ NSLocalizedDescriptionKey : @"Unable to parse vimeo response. Try again later." }]);
    };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:videoURL];
    [request setValue:MSVimeoFetcherUserAgent forHTTPHeaderField:@"User-Agent"];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *requestOperation, id responseObject) {
        NSScanner *scanner = [[NSScanner alloc] initWithString:[requestOperation responseString]];
        if (![scanner scanUpToString:@"<video " intoString:nil]) {
            parseError();
            return;
        }
        NSString *urlAttribute = @"data-src=\"";
        if ([scanner scanUpToString:urlAttribute intoString:nil]) {
            [scanner setScanLocation:(scanner.scanLocation + urlAttribute.length)];
        } else {
            parseError();
            return;
        }
        NSString *videoURLString;
        if ([scanner scanUpToString:@"profiles=" intoString:&videoURLString]) {
        } else {
            parseError();
            return;
        }
        // Add http:
        if (NSEqualRanges([videoURLString rangeOfString:@"//"], NSMakeRange(0, 2))) {
            videoURLString = [NSString stringWithFormat:@"http:%@", videoURLString];
        }
        switch (quality) {
            case MSVimeoFetcherQualityLow:
                videoURLString = [videoURLString stringByAppendingString:@"profiles=iphone"];
                break;
            case MSVimeoFetcherQualityMedium:
                videoURLString = [videoURLString stringByAppendingString:@"profiles=standard"];
                break;
            case MSVimeoFetcherQualityHigh:
                videoURLString = [videoURLString stringByAppendingString:@"profiles=high"];
                break;
        }
        NSMutableURLRequest *redirectRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:videoURLString]];
        [redirectRequest setValue:MSVimeoFetcherUserAgent forHTTPHeaderField:@"User-Agent"];
        AFHTTPRequestOperation *redirectRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:redirectRequest];
        [redirectRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            completion(nil, [NSError errorWithDomain:MSVimeoFetcherErrorDomain code:MSVimeoFetcherErrorRedirectFailure userInfo:@{ NSLocalizedDescriptionKey : @"Redirect to vimeo CDN failed. Try again later." }]);
        } failure:^(AFHTTPRequestOperation *redirectRequestOperation, NSError *error) {
            if (redirectRequestOperation.response.statusCode == 302) {
                // This is the error we'll get due to our returning of nil in the redirect response block
                return;
            }
            completion(nil, error);
        }];
        [redirectRequestOperation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
            if (request && [redirectResponse.URL isEqual:redirectRequest.URL]) {
                completion([request URL], nil);
                return nil;
            }
            return request;
        }];
        [redirectRequestOperation start];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
    [requestOperation start];
}

@end
