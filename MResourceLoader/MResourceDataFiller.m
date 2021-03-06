//
//  MResourceDataFiller.m
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "MResourceDataFiller.h"
#import "MResourceDataReader.h"
#import "MResourceDataFetcher.h"
#import "MResourceContentInfo.h"
#import "MResourceScheme.h"
#import "MResourceCacheManager.h"

@interface MResourceDataFiller()
@property (nonatomic, strong) NSMutableArray<MResourceDataCreator*> *pendingDataCreators;
@property (nonatomic, strong, readonly) AVAssetResourceLoadingRequest *loadingRequest;
@property (nonatomic, strong) MResourceCacher *cacher;
@property (nonatomic, strong) NSLock *lock;
@end

@implementation MResourceDataFiller

- (void)dealloc {
    [self _cleanDataCreators];
    MResourceCacheManager *cacheManager = [MResourceCacheManager defaultManager];
    if (cacheManager.currentDiskUsage > cacheManager.maxDiskUsage) {
        [cacheManager clearOlderCache];
    }
}

- (instancetype)initWithLoadingRequest:(AVAssetResourceLoadingRequest*)loadingRequest {
    self = [super init];
    if (self) {
        _loadingRequest = loadingRequest;
        _lock = [[NSLock alloc] init];
        _lock.name = @"MResourceDataFillerLock";
    }
    return self;
}

- (void)start {
    [self _continueFillData];
}

- (void)cancel {
    [self _finishFillWithError:nil];
}

- (void)_continueFillData {
    AVAssetResourceLoadingDataRequest *dataRequest = self.loadingRequest.dataRequest;
    MRLong currentOffset = dataRequest.currentOffset;
    if (currentOffset >= dataRequest.requestedOffset + dataRequest.requestedLength) {
        [self _finishFillWithError:nil];
        return;
    }
    
    NSUInteger expectDataLength = (NSUInteger)(dataRequest.requestedLength - (dataRequest.currentOffset - dataRequest.requestedOffset));
    MRRange expectDataRange = MRMakeRange(currentOffset, expectDataLength);
    
    if (!self.cacher.contentInfo) {
        [self _fetchDataFromRemote:expectDataRange];
        return;
    }
    
    MRRange localDataRange = [self.cacher localDataRangeForRange:expectDataRange];
    if (localDataRange.length > 0) {
        if (localDataRange.location == expectDataRange.location) {
            [self _readDataFromLocal:localDataRange];
        } else {
            MRRange dataFragment = MRMakeRange(currentOffset, (NSUInteger)(localDataRange.location - expectDataRange.location));
            [self _fetchDataFromRemote:dataFragment];
        }
    } else {
        [self _fetchDataFromRemote:expectDataRange];
    }
}

- (void)_readDataFromLocal:(MRRange)range {
    if (range.length < 1) {
        return;
    }
    NSURL *url = [MResourceScheme originURL:self.loadingRequest.request.URL];
    MResourceDataReader *reader = [[MResourceDataReader alloc] initWithURL:url];
    reader.delegate = self;
    reader.cacher = self.cacher;
    [self _addDataCreator:reader];
    [reader startCreateDataInRange:range];
}

- (void)_fetchDataFromRemote:(MRRange)range {
    if (range.length < 1) {
        return;
    }
    NSURL *url = [MResourceScheme originURL:self.loadingRequest.request.URL];
    MResourceDataFetcher *fetcher = [[MResourceDataFetcher alloc] initWithURL:url];
    fetcher.delegate = self;
    fetcher.cacher = self.cacher;
    [self _addDataCreator:fetcher];
    [fetcher startCreateDataInRange:range];
}

- (void)_fullfillContentInfo:(MResourceContentInfo*)contentInfo {
    AVAssetResourceLoadingContentInformationRequest *contentInformationRequest = self.loadingRequest.contentInformationRequest;
    if (contentInfo && contentInformationRequest &&
        !contentInformationRequest.contentType) {
        
        // Fullfill content information
        contentInformationRequest.contentType = contentInfo.contentType;
        contentInformationRequest.contentLength = [contentInfo.contentLength longLongValue];
        contentInformationRequest.byteRangeAccessSupported = contentInfo.byteRangeAccessSupported;
        [self.cacher cacheContentInfo:contentInfo];
    }
}

- (void)_finishFillWithError:(NSError*)error {
    if (self.loadingRequest.isFinished) {
        return;
    }
    if (error) {
        [self.loadingRequest finishLoadingWithError:error];
    } else {
        [self.loadingRequest finishLoading];
    }
}

- (void)_addDataCreator:(MResourceDataCreator*)dataCreator {
    [self.lock lock];
    [self.pendingDataCreators addObject:dataCreator];
    [self.lock unlock];
}

- (void)_removeDataCreator:(MResourceDataCreator*)dataCreator {
    [self.lock lock];
    [self.pendingDataCreators removeObject:dataCreator];
    [self.lock unlock];
}

- (void)_cleanDataCreators {
    [self.lock lock];
    [self.pendingDataCreators enumerateObjectsUsingBlock:^(MResourceDataCreator * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj stop];
    }];
    [self.lock unlock];
}

#pragma mark - MResourceCreateDataDelegate
- (void)dataCreator:(MResourceDataCreator*)creator didCreateContentInfo:(MResourceContentInfo*)info {
    [self _fullfillContentInfo:info];
}

- (void)dataCreator:(MResourceDataCreator *)creator didCreateData:(NSData *)data {
    if (data.length > 0) {
        [self.loadingRequest.dataRequest respondWithData:data];
    }
}

- (void)dataCreator:(MResourceDataCreator *)creator didFinishWithError:(NSError*)error {
    [creator stop];
    [self _removeDataCreator:creator];
    
    if (error) {
        [self _finishFillWithError:error];
    } else {
        [self _continueFillData];
    }
}

#pragma mark - pendingDataCreators
- (NSMutableArray*)pendingDataCreators {
    if (!_pendingDataCreators) {
        _pendingDataCreators = [NSMutableArray array];
    }
    return _pendingDataCreators;
}

- (MResourceCacher*)cacher {
    if (!_cacher) {
        NSURL *originUrl = [MResourceScheme originURL:self.loadingRequest.request.URL];
        _cacher = [[MResourceCacher alloc] initWithURL:originUrl];
    }
    return _cacher;
}
@end
