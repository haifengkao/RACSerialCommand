
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

@interface RACSerialCommand()
// The signal block that the receiver was initialized with.
@property (nonatomic, copy) RACSignal * (^signalBlock)(id input);
@property (nonatomic, strong) RACSubject* subject;
@property (nonatomic, strong) RACSignal* queue;
@property (assign) BOOL shouldUseMainThread;
@end

@implementation RACSerialCommand
- (instancetype)initWithSignalBlock:(RACSignal * (^)(id input))signalBlock {
    NSParameterAssert(signalBlock);

    if (self = [super init]) {
        _signalBlock = signalBlock;
        RACSubject* subject = [RACSubject subject];
        RACSignal* queue = [[subject concat] takeUntil:self.rac_willDeallocSignal];
        _subject = subject;
        _queue = queue;
        [queue subscribeNext:^(id x) {
            // activate the queue
        }];
    }

    return self;
}


/** 
  * If you want the signal to deliver on the main thread, call this method right after init
  * 
  */
- (void)useMainThread
{
    self.shouldUseMainThread = YES;
}

/** 
  * we want to keep the interface the same as RACCommand
  * but the mechanism doesn't allow us to return the command signal
  * 
  * @return nil
  */
- (RACSignal *)execute:(id)input {

    if (self.shouldUseMainThread) {
        // TODO: i'm too lazy to implement this stuff. A simple assert will work as well
        NSAssert([NSOperationQueue.currentQueue isEqual:NSOperationQueue.mainQueue] || [NSThread isMainThread], @"if you call execute on main thread, the signal will be delivered on main thread as well");
    }

    @weakify(self);
    RACSignal* signal = [RACSignal defer:^(){
        @strongify(self);

        if (!self.signalBlock) {
            // self has been dealloc
            return [RACSignal empty];
        }

        RACSignal* signal = self.signalBlock(input);
        if (!signal) { 
            // complete immediately, we don't want the queue to be blocked
            return [RACSignal empty];
        } 
        return signal;
    }];

    // add the signal to the queue
    [self.subject sendNext:signal];

    return nil; // the signal will be activated when subscribed. We don't want it to happen
}

@end
