//
//  LikelihoodPlugIn.h
//  Likelihood
//
//  Created by Bryan Klimt on 12/12/08.
//  Copyright (c) 2008 Bryan Klimt. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <Accelerate/Accelerate.h>

#define NUM_COLORS 16

@interface LikelihoodPlugIn : QCPlugIn {
	// The coordinates of the centroids of the color clusters
	CGColorRef cluster_[NUM_COLORS];
}

/*
Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
@property double inputFoo;
@property(assign) NSString* outputBar;
You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
*/

@property(assign) id<QCPlugInInputImageSource> inputImage;
@property(assign) CGColorRef outputColor1;
@property(assign) CGColorRef outputColor2;
@property(assign) CGColorRef outputColor3;
@property(assign) CGColorRef outputColor4;
@property(assign) CGColorRef outputColor5;
@property(assign) CGColorRef outputColor6;
@property(assign) CGColorRef outputColor7;
@property(assign) CGColorRef outputColor8;
@property(assign) CGColorRef outputColor9;
@property(assign) CGColorRef outputColor10;
@property(assign) CGColorRef outputColor11;
@property(assign) CGColorRef outputColor12;
@property(assign) CGColorRef outputColor13;
@property(assign) CGColorRef outputColor14;
@property(assign) CGColorRef outputColor15;
@property(assign) CGColorRef outputColor16;
@property(assign) id<QCPlugInOutputImageProvider> outputImage;

@end
