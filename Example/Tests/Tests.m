//
//  RACSerialCommandTests.m
//  RACSerialCommandTests
//
//  Created by Hai Feng Kao on 06/03/2016.
//  Copyright (c) 2016 Hai Feng Kao. All rights reserved.
//

// https://github.com/kiwi-bdd/Kiwi

#import "RACSerialCommand.h"
#import "RACSignal.h"
#import "RACScheduler.h"
#import "RACSignal+Operations.h"
#import "RACDisposable.h"
#import "RACSubscriber.h"


SPEC_BEGIN(InitialTests)

describe(@"RACSerialCommand", ^{

  context(@"will pass", ^{

      it(@"should output 1 2 3", ^{
          __block NSNumber* number = nil;
          RACSerialCommand* command = [[RACSerialCommand alloc] initWithSignalBlock:^RACSignal*(id input){
            NSLog(@"init %@", input);
            number = input;
            RACSignal* signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [subscriber sendNext:input];
                NSLog(@"sent %@", input);

                [[[RACSignal empty] delay:2.0] subscribeCompleted:^() {
                    [subscriber sendCompleted];
                }];
                 return nil;
            }];

            return signal;
          }];
          RACScheduler* scheduler = [RACScheduler mainThreadScheduler];
          [RACSignal startEagerlyWithScheduler:scheduler block:^(id<RACSubscriber> subscriber){ 
              [command execute:@(1)];
              [command execute:@(2)];
              [command execute:@(3)];
          }];
        [[expectFutureValue(number) shouldEventuallyBeforeTimingOutAfter(10000.0)] equal:@(3)];
      });
  });
});

SPEC_END

