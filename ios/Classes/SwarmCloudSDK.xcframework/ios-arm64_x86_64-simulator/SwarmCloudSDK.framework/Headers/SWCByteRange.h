//
//  SWCByteRange.h
//  SwarmCloudSDK
//
//  Created by Timmy on 2021/5/10.
//  Copyright © 2021 SwarmCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct SWCRange {
    long long start;
    long long end;
} SWCRange;

static const long long SWCNotFound = LONG_LONG_MAX;

BOOL SWCRangeIsFull(SWCRange range);                   //  compare to SWCMakeRange(0, KTVHCNotFound)
BOOL SWCRangeIsVaild(SWCRange range);                  // compare to SWCMakeRange(SWCNotFound, SWCNotFound)
BOOL SWCRangeIsInvaild(SWCRange range);
BOOL SWCEqualRanges(SWCRange range1, SWCRange range2);
long long SWCRangeGetLength(SWCRange range);
NSString * SWCStringFromRange(SWCRange range);               // Range : {%lld, %lld}
NSString *SWCRangeGetHeaderString(SWCRange range);           // bytes=start-end
NSString *SWCRangeGetHeaderStringFromNSRange(NSRange range);
NSDictionary *SWCRangeFillToRequestHeaders(SWCRange range, NSDictionary *eaders);
NSDictionary *SWCRangeFillToRequestHeadersIfNeeded(SWCRange range, NSDictionary *headers);      // 没有Range的时候添加
NSDictionary *SWCRangeFillToResponseHeaders(SWCRange range, NSDictionary *headers, long long totalLength);

SWCRange SWCMakeRange(long long start, long long end);
SWCRange SWCRangeZero(void);
SWCRange SWCRangeFull(void);
SWCRange SWCRangeInvaild(void);
SWCRange SWCRangeWithSeparateValue(NSString *value);
SWCRange SWCRangeWithRequestHeaderValue(NSString *value);
SWCRange SWCRangeWithResponseHeaderValue(NSString *value, long long *totalLength);
SWCRange SWCRangeWithEnsureLength(SWCRange range, long long ensureLength);
