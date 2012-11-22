//
//  JKFlipFlopPlugIn.h
//  JKFlipFlop
//
//  Created by Bryan Klimt on 12/12/08.
//  Copyright (c) 2008 Bryan Klimt. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <Accelerate/Accelerate.h>

@interface JKFlipFlopPlugIn : QCPlugIn {
	BOOL state1_;
	BOOL state2_;
}

/*
Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
@property double inputFoo;
@property(assign) NSString* outputBar;
You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
*/

@property BOOL inputJ;
@property BOOL inputK;
@property BOOL inputModeD;
@property BOOL inputClock;
@property BOOL outputQ;

@end
