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

@interface RACViewController ()
@property (nonatomic, strong) RACSerialCommand* command;
@end

@implementation RACViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    __block NSNumber* number = nil;
    RACSerialCommand* command = [[RACSerialCommand alloc] initWithSignalBlock:^RACSignal*(id input){
        NSLog(@"%@", input);
        number = input;
        return [RACSignal empty];
    }];
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
