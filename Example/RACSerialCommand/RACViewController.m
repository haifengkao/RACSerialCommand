//
//  RACViewController.m
//  RACSerialCommand
//
//  Created by Hai Feng Kao on 06/03/2016.
//  Copyright (c) 2016 Hai Feng Kao. All rights reserved.
//

#import "RACViewController.h"
#import "RACSerialCommand.h"
#import "RACSignal.h"
#import "RACSignal+Operations.h"
#import "RACDisposable.h"
#import "RACSubscriber.h"

@interface RACViewController ()
@property (nonatomic, strong) RACSerialCommand* command;
@end

@implementation RACViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    return;
    __block NSNumber* number = nil;
    RACSerialCommand* command = [[RACSerialCommand alloc] initWithSignalBlock:^RACSignal*(id input){
        NSLog(@"init %@", input);
        number = input;
        RACSignal* signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) 
        {
            [subscriber sendNext:input];
            NSLog(@"sent %@", input);

            [[[RACSignal empty] delay:2.0] subscribeCompleted:^() {
                [subscriber sendCompleted];    
            }];
            
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
        return signal;
    }];
    [command useMainThread];
    [command execute:@(1)];
    [command execute:@(2)];
    [command execute:@(3)];
    
    _command = command;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
