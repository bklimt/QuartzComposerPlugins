//
//  HabituationPlugIn.h
//  Habituation
//
//  Created by Bryan Klimt on 12/15/08.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <Accelerate/Accelerate.h>

@interface HabituationPlugIn : QCPlugIn {
	// Metrics for the type of images seen/stored.
	int width_;
	int height_;
	NSUInteger rowBytes_;
	unsigned int num_samples_;
	
	// Arrays for storing the images seen and their sums.
	unsigned int *redSums_;
	unsigned int *greenSums_;
	unsigned int *blueSums_;
	unsigned char **samples_;
	
	// Indices into samples_ to make it a cycling queue.
	int front_;
	int rear_;
}

/*
 Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
 @property double inputFoo;
 @property(assign) NSString* outputBar;
 You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
 */

@property(assign) id<QCPlugInInputImageSource> inputImage;
@property(assign) NSUInteger inputSamples;
@property(assign) BOOL inputCycle;
@property(assign) BOOL inputDifference;
@property(assign) double inputDifferenceLowerBound;
@property(assign) double inputDifferenceUpperBound;

@property(assign) id<QCPlugInOutputImageProvider> outputImage;
@property(assign) NSUInteger outputCount;

@end
