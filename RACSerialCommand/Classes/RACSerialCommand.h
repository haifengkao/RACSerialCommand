//
//  RACSerialCommand.h
//  RACSerialCommand
//
//  Created by Hai Feng Kao on 2016/06/03.
//
//

#import <Foundation/Foundation.h>
@class RACSignal;

// Make RACCommand executes command serially
// Useful when you need to protect a single resource that cannot be shared
@interface RACSerialCommand : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSignalBlock:(RACSignal * (^)(id input))signalBlock;
- (RACSignal *)execute:(id)input;

@end
