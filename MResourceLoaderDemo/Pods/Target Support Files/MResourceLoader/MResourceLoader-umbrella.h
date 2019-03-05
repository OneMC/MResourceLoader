#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MResourceCacheManager.h"
#import "MResourceCacher.h"
#import "MResourceContentInfo.h"
#import "MResourceDataCreator.h"
#import "MResourceDataFetcher.h"
#import "MResourceDataFiller.h"
#import "MResourceDataReader.h"
#import "MResourceFileHandler.h"
#import "MResourceLoader.h"
#import "MResourceScheme.h"
#import "MResourceSessionManager.h"
#import "MResourceUtility.h"
#import "NSString+MRResourceUtility.h"

FOUNDATION_EXPORT double MResourceLoaderVersionNumber;
FOUNDATION_EXPORT const unsigned char MResourceLoaderVersionString[];

