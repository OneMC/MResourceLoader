//
//  MResourceSessionManager.m
//  MResourceLoader
//
//  Created by MiaoChao on 2018/8/22.
//  Copyright © 2018年 MiaoChao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "MResourceSessionManager.h"
#import "MResourceDataFetcher.h"

@interface MResourceSessionManager()<NSURLSessionDataDelegate>
@property (nonatomic, strong) NSMutableDictionary *pendingTask;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSLock *lock;
@end

@implementation MResourceSessionManager
@synthesize session = _session;
- (void)dealloc {
    [self.session invalidateAndCancel];
}

+ (instancetype)shareSession {
    static MResourceSessionManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MResourceSessionManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSUInteger randomMax = 5;
        self.pendingTask = [NSMutableDictionary dictionaryWithCapacity:randomMax];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:self.operationQueue];
        _session = session;
        self.lock = [[NSLock alloc] init];
        self.lock.name = @"MResourceSessionManagerLock";
    }
    return self;
}

- (void)setDelegate:(id<NSURLSessionDataDelegate>)delegate forTask:(NSURLSessionDataTask*)task {
    NSParameterAssert(task);
    NSParameterAssert(delegate);
    
    [self.lock lock];
    [self.pendingTask setObject:delegate forKey:@(task.taskIdentifier)];
    [self.lock unlock];
}

- (id<NSURLSessionDataDelegate>)_delegateForTask:(NSURLSessionTask*)task {
    NSParameterAssert(task);
    [self.lock lock];
    id<NSURLSessionDataDelegate> delegate = nil;
    delegate = [self.pendingTask objectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
    return delegate;
}

- (void)_removeDelegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    [self.lock lock];
    [self.pendingTask removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    id<NSURLSessionDataDelegate>delegate = [self _delegateForTask:task];
    if ([delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [delegate URLSession:session task:task didCompleteWithError:error];
        [self _removeDelegateForTask:task];
    }
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    id<NSURLSessionDataDelegate>delegate = [self _delegateForTask:dataTask];
    if ([delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)]) {
        [delegate URLSession:session dataTask:dataTask  didReceiveResponse:response completionHandler:completionHandler];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    id<NSURLSessionDataDelegate>delegate = [self _delegateForTask:dataTask];
    if ([delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
        [delegate URLSession:session dataTask:dataTask didReceiveData:data];
    }
}

@end
