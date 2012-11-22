//
//  SwitchPlugIn.m
//  Switch
//
//  Created by Bryan Klimt on 12/12/08.
//  Copyright (c) 2008 Bryan Klimt. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */

#import <OpenGL/CGLMacro.h>
#import "SwitchPlugIn.h"

#define	kQCPlugIn_Name				@"Switch"
#define	kQCPlugIn_Description		@"Switch is awesome!"

@implementation SwitchPlugIn

// Declare the input / output properties as dynamic; Quartz Composer will handle their implementation
@dynamic inputCondition;
@dynamic inputNumberIf;
@dynamic inputNumberElse;
@dynamic outputNumber;
@dynamic inputColorIf;
@dynamic inputColorElse;
@dynamic outputColor;

- (id) init {
	if (self = [super init]) {
		// Allocate any permanent resource required by the plug-in.
	}
	return self;
}

- (void) finalize {
	// Release any non garbage collected resources created in -init.
	[super finalize];
}

- (void) dealloc {
	// Release any resources created in -init.
	[super dealloc];
}

+ (NSDictionary*) attributes {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			kQCPlugIn_Name, QCPlugInAttributeNameKey,
			kQCPlugIn_Description, QCPlugInAttributeDescriptionKey,
			nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey: (NSString*) key {
	// Specify the optional attributes for property based ports
	// (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).	
	if ([key isEqualToString:@"inputCondition"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"condition", QCPortAttributeNameKey,
				[NSNumber numberWithBool: NO], QCPortAttributeDefaultValueKey,
				nil];
	} else if ([key isEqualToString:@"inputNumberIf"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"number if true", QCPortAttributeNameKey,
				[NSNumber numberWithInt: 0], QCPortAttributeDefaultValueKey,
				nil];
	} else if ([key isEqualToString:@"inputNumberElse"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"number if false", QCPortAttributeNameKey,
				[NSNumber numberWithInt: 0], QCPortAttributeDefaultValueKey,
				nil];
	} else if ([key isEqualToString:@"outputNumber"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"number", QCPortAttributeNameKey,
				nil];
	} else if ([key isEqualToString:@"inputColorIf"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"color if true", QCPortAttributeNameKey,
				nil];
	} else if ([key isEqualToString:@"inputColorElse"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"color if false", QCPortAttributeNameKey,
				nil];
	} else if ([key isEqualToString:@"outputColor"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"color", QCPortAttributeNameKey,
				nil];
	} else {
		return nil;
	}
}

+ (QCPlugInExecutionMode) executionMode {
	// Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider,
	// kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode) timeMode {
	// Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone,
	// kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	return kQCPlugInTimeModeNone;
}

@end

@implementation SwitchPlugIn (Execution)

- (BOOL) startExecution: (id<QCPlugInContext>) context {
	// Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	// Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	return YES;
}

- (void) enableExecution: (id<QCPlugInContext>) context {
	// Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
}

static void _BufferReleaseCallback(const void* address, void* info) {
	free((void*)address);
}

- (BOOL) execute: (id<QCPlugInContext>) context atTime: (NSTimeInterval) time withArguments: (NSDictionary*) arguments {
	// Called by Quartz Composer whenever the plug-in instance needs to execute.  Only read from the plug-in inputs
	// and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context)
	// within that method and nowhere else.  Return NO in case of failure during the execution (this will prevent
	// rendering of the current frame to complete).

	if (self.inputCondition) {
		self.outputNumber = self.inputNumberIf;
		self.outputColor = self.inputColorIf;
	} else {
		self.outputNumber = self.inputNumberElse;
		self.outputColor = self.inputColorElse;
	}
	return YES;
}

- (void) disableExecution:(id<QCPlugInContext>)context {
	// Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
}

- (void) stopExecution:(id<QCPlugInContext>)context {
	// Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
}

@end
