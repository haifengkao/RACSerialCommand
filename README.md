# RACSerialCommand

[![CI Status](http://img.shields.io/travis/haifengkao/RACSerialCommand.svg?style=flat)](https://travis-ci.org/haifengkao/RACSerialCommand)
[![Coverage Status](https://coveralls.io/repos/haifengkao/RACSerialCommand/badge.svg?branch=master&service=github)](https://coveralls.io/github/haifengkao/RACSerialCommand?branch=master)
[![Version](https://img.shields.io/cocoapods/v/RACSerialCommand.svg?style=flat)](http://cocoapods.org/pods/RACSerialCommand)
[![License](https://img.shields.io/cocoapods/l/RACSerialCommand.svg?style=flat)](http://cocoapods.org/pods/RACSerialCommand)
[![Platform](https://img.shields.io/cocoapods/p/RACSerialCommand.svg?style=flat)](http://cocoapods.org/pods/RACSerialCommand)

## Example

Serialize RACSignal execution:
``` objc
    RACSerialCommand* command = [[RACSerialCommand alloc] initWithSignalBlock:^RACSignal*(id input){
        NSLog(@"%@", input);
        return [RACSignal empty];
    }];
    [command execute:@(1)];
    [command execute:@(2)];
    [command execute:@(3)];
    
    // will output 1 2 3
```

## Requirements

## Installation

RACSerialCommand is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RACSerialCommand"
```

## Author

Hai Feng Kao, haifeng@cocoaspice.in

## License

RACSerialCommand is available under the MIT license. See the LICENSE file for more info.
