//
//  RACSerialCommandTests.m
//  RACSerialCommandTests
//
//  Created by Hai Feng Kao on 06/03/2016.
//  Copyright (c) 2016 Hai Feng Kao. All rights reserved.
//

// https://github.com/kiwi-bdd/Kiwi

#import "RACSerialCommand.h"
#import "RACsignal.h"

SPEC_BEGIN(InitialTests)

describe(@"RACSerialCommand", ^{

  context(@"will pass", ^{

      it(@"should output 1 2 3", ^{
          __block NSNumber* number = nil;
          RACSerialCommand* command = [[RACSerialCommand alloc] initWithSignalBlock:^RACSignal*(id input){
              NSLog(@"%@", input);
              number = input;
              return [RACSignal empty];
          }];
        [command execute:@(1)];
        [command execute:@(2)];
        [command execute:@(3)];
        [[expectFutureValue(number) shouldEventually] equal:@(3)];
      });
  });
});

SPEC_END

