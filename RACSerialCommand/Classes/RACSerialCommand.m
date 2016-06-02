
//
//  RACSerialCommand.m
//  RACSerialCommand
//
//  Created by Hai Feng Kao on 2016/06/03.
//
//

#import "RACSerialCommand.h"
#import <Foundation/Foundation.h>
#import "RACEXTScope.h"
#import "RACSignal.h"
#import "RACReplaySubject.h"
#import "NSObject+RACDeallocating.h"
#import "RACSignal+Operations.h"

typedef void(^VoidBlock)();
typedef void(^AsyncExecutionBlock)(VoidBlock completion);

@interface SHPBlockOperation : NSOperation

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithExecutionBlock:(AsyncExecutionBlock)block NS_DESIGNATED_INITIALIZER;;

@end

@interface SHPBlockOperation ()

@property (nonatomic, strong) AsyncExecutionBlock executionBlock;

@property (assign, getter=isExecuting) BOOL executing;
@property (assign, getter=isConcurrent) BOOL concurrent;
@property (assign, getter=isFinished) BOOL finished;
@end

@implementation SHPBlockOperation {

}
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize concurrent = _concurrent;

- (instancetype)init {
    NSAssert(NO, @"Please use designated initializer");
    return nil;
}

- (instancetype)initWithExecutionBlock:(AsyncExecutionBlock)block {
    self = [super init];
    if (self) {
        self.concurrent = YES;
        self.executionBlock = block;
    }
    return self;
}

- (void)start {
    self.executing = YES;

    @weakify(self)
    void (^completion)() = ^() {
        @strongify(self)
        self.executing = NO;
        self.finished = YES;
    };

    self.executionBlock(completion);

}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setConcurrent:(BOOL)concurrent
{
    [self willChangeValueForKey:@"isConcurrent"];
    _concurrent = concurrent;
    [self didChangeValueForKey:@"isConcurrent"];
}

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isConcurrent {
    return _concurrent;
}

- (BOOL)isExecuting
{
    return _executing;
}

- (BOOL)isFinished
{
    return _finished;
}

@end

@interface RACSerialCommand()
// The signal block that the receiver was initialized with.
@property (nonatomic, copy) RACSignal * (^signalBlock)(id input);
@property (strong) NSOperationQueue* queue;
@end

@implementation RACSerialCommand
- (instancetype)initWithSignalBlock:(RACSignal * (^)(id input))signalBlock {
    NSParameterAssert(signalBlock);

    if (self = [super init]) {
        _signalBlock = signalBlock;
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }

    return self;
}

- (RACSignal *)execute:(id)input {
    RACReplaySubject* subject = [RACReplaySubject subject];

    @weakify(subject);
    @weakify(self);
    SHPBlockOperation *operation = [[SHPBlockOperation alloc] initWithExecutionBlock:^(VoidBlock completion) {

        @strongify(self);
        @strongify(subject);

        if (!self.signalBlock) {
            // self has been dealloc
            completion();
            return;
        }

        RACSignal* signal = self.signalBlock(input);
        if (!signal) { 
            // complete immediately, we don't want the queue to be blocked
            [subject sendCompleted];
            completion(); 
            return;
        } 

        if (subject) {
            [signal subscribe:subject];
        }
        
        [signal subscribeError:^(NSError* error) {
            // error handling?
            completion();    
        } completed:^() {
            completion();    
        }];
    }];
    [self.queue addOperation:operation];

    return [subject takeUntil:self.rac_willDeallocSignal]; // nothing we can do when signalBlock is gone
}
@end
