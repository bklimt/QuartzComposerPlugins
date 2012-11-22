//
//  ColorReducePlugIn.m
//  ColorReduce
//
//  Created by Bryan Klimt on 12/17/08.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "ColorReducePlugIn.h"

#define	kQCPlugIn_Name				@"ColorReduce"
#define	kQCPlugIn_Description		@"ColorReduce description"
#define NUM_COLORS 16

@implementation ColorReducePlugIn

// Declare the input / output properties as dynamic; Quartz Composer will handle their implementation
@dynamic inputImage;
@dynamic inputColors;
@dynamic inputDither;
@dynamic inputOverrideColors;
@dynamic inputIterations;
@dynamic inputColor1;
@dynamic inputColor2;
@dynamic inputColor3;
@dynamic inputColor4;
@dynamic inputColor5;
@dynamic inputColor6;
@dynamic inputColor7;
@dynamic inputColor8;
@dynamic inputColor9;
@dynamic inputColor10;
@dynamic inputColor11;
@dynamic inputColor12;
@dynamic inputColor13;
@dynamic inputColor14;
@dynamic inputColor15;
@dynamic inputColor16;
@dynamic outputColor1;
@dynamic outputColor2;
@dynamic outputColor3;
@dynamic outputColor4;
@dynamic outputColor5;
@dynamic outputColor6;
@dynamic outputColor7;
@dynamic outputColor8;
@dynamic outputColor9;
@dynamic outputColor10;
@dynamic outputColor11;
@dynamic outputColor12;
@dynamic outputColor13;
@dynamic outputColor14;
@dynamic outputColor15;
@dynamic outputColor16;
@dynamic outputImage;

const double START_COLORS[NUM_COLORS][3] = {
{ 0.0, 0.0, 0.0 },
{ 0.5, 0.0, 0.0 },
{ 1.0, 0.0, 0.0 },
{ 0.0, 0.5, 0.0 },
{ 1.0, 0.5, 0.0 },
{ 0.0, 1.0, 0.0 },
{ 0.5, 1.0, 0.0 },
{ 1.0, 1.0, 0.0 },
{ 0.0, 0.0, 1.0 },
{ 0.5, 0.0, 1.0 },
{ 1.0, 0.0, 1.0 },
{ 0.0, 0.5, 1.0 },
{ 1.0, 0.5, 1.0 },
{ 0.0, 1.0, 1.0 },
{ 0.5, 1.0, 1.0 },
{ 1.0, 1.0, 1.0 }
};

- (id) init {
	if (self = [super init]) {
		// Allocate any permanent resource required by the plug-in.
		for (int i = 0; i < NUM_COLORS; ++i) {
			cluster_[i] = CGColorCreateGenericRGB(START_COLORS[i][0], START_COLORS[i][1], START_COLORS[i][2], 1.0);
		}
	}
	return self;
}

- (void) finalize {
	// Release any non garbage collected resources created in -init.
	for (int i = 0; i < 16; ++i) {
		CGColorRelease(cluster_[i]);
	}
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
	if ([key isEqualToString:@"inputImage"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input image", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColors"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"number of colors", QCPortAttributeNameKey,
		        [NSNumber numberWithInt: 16], QCPortAttributeDefaultValueKey, nil];
	} else if ([key isEqualToString:@"inputDither"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"dither", QCPortAttributeNameKey,
		        NO, QCPortAttributeDefaultValueKey, nil];
	} else if ([key isEqualToString:@"inputOverrideColors"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"override colors", QCPortAttributeNameKey,
		        NO, QCPortAttributeDefaultValueKey, nil];
	} else if ([key isEqualToString:@"inputIterations"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"k-means iterations per frame", QCPortAttributeNameKey,
		        [NSNumber numberWithInt: 1], QCPortAttributeDefaultValueKey, nil];
	} else if ([key isEqualToString:@"inputColor1"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 1", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor2"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 2", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor3"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 3", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor4"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 4", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor5"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 5", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor6"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 6", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor7"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 7", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor8"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 8", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor9"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 9", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor10"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 10", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor11"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 11", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor12"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 12", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor13"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 13", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor14"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 14", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor15"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 15", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"inputColor16"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"input color 16", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor1"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 1", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor2"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 2", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor3"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 3", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor4"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 4", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor5"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 5", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor6"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 6", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor7"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 7", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor8"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 8", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor9"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 9", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor10"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 10", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor11"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 11", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor12"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 12", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor13"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 13", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor14"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 14", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor15"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 15", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputColor16"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output color 16", QCPortAttributeNameKey, nil];
	} else if ([key isEqualToString:@"outputImage"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys: @"output image", QCPortAttributeNameKey, nil];
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

@implementation ColorReducePlugIn (Execution)

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

#if __BIG_ENDIAN__

#define FORMAT QCPlugInPixelFormatARGB8
#define ALPHA_OFFSET 0
#define RED_OFFSET 1
#define GREEN_OFFSET 2
#define BLUE_OFFSET 3

#else

#define FORMAT QCPlugInPixelFormatBGRA8
#define ALPHA_OFFSET 3
#define RED_OFFSET 2
#define GREEN_OFFSET 1
#define BLUE_OFFSET 0

#endif	

- (BOOL) execute: (id<QCPlugInContext>) context atTime: (NSTimeInterval) time withArguments: (NSDictionary*) arguments {
	// Called by Quartz Composer whenever the plug-in instance needs to execute.  Only read from the plug-in inputs
	// and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context)
	// within that method and nowhere else.  Return NO in case of failure during the execution (this will prevent
	// rendering of the current frame to complete).
	//
	// The OpenGL context for rendering can be accessed and defined for CGL macros using:
	// CGLContextObj cgl_ctx = [context CGLContextObj];
	
	// If there's no source image, bail.
	id<QCPlugInInputImageSource> inputImage = self.inputImage;
	NSUInteger num_colors = self.inputColors;
	BOOL dither = self.inputDither;
	if (num_colors < 1) {
		num_colors = 1;
	}
	if (num_colors > NUM_COLORS) {
		num_colors = NUM_COLORS;
	}
	if (inputImage) {
		// Get a buffer representation from the source image.
		const int bytesPerPixel = 4;
		CGColorSpaceRef colorSpace = (CGColorSpaceGetModel([inputImage imageColorSpace]) == kCGColorSpaceModelRGB ?
									  [inputImage imageColorSpace] :
									  [context colorSpace]);
		if (![inputImage lockBufferRepresentationWithPixelFormat: FORMAT colorSpace: colorSpace forBounds: [inputImage imageBounds]]) {
			return NO;
		}
		
		// Create a buffer for the input image.
		vImage_Buffer inBuffer;
		inBuffer.data = (void*)[inputImage bufferBaseAddress];
		inBuffer.rowBytes = [inputImage bufferBytesPerRow];
		inBuffer.width = [inputImage bufferPixelsWide];
		inBuffer.height = [inputImage bufferPixelsHigh];
		int inputRowPadding = inBuffer.rowBytes - (inBuffer.width * bytesPerPixel);
		
		// Create an output memory buffer.
		vImage_Buffer outBuffer;
		outBuffer.width = inBuffer.width;
		outBuffer.height = inBuffer.height;
		outBuffer.rowBytes = outBuffer.width * 4;
		if (outBuffer.rowBytes % 16) {
			outBuffer.rowBytes = (outBuffer.rowBytes / 16 + 1) * 16;
		}
		outBuffer.data = valloc(outBuffer.rowBytes * outBuffer.height);
		if (outBuffer.data == NULL) {
			return NO;
		}
		int outputRowPadding = outBuffer.rowBytes - (outBuffer.width * bytesPerPixel);
		
		for (int iteration = 0; iteration < self.inputIterations; ++iteration) {
			if (self.inputOverrideColors && iteration == self.inputIterations - 1) {
				for (unsigned char c = 0; c < NUM_COLORS; ++c) {
					CGColorRelease(cluster_[c]);
				}
				cluster_[0] = CGColorCreateCopy(self.inputColor1);
				cluster_[1] = CGColorCreateCopy(self.inputColor2);
				cluster_[2] = CGColorCreateCopy(self.inputColor3);
				cluster_[3] = CGColorCreateCopy(self.inputColor4);
				cluster_[4] = CGColorCreateCopy(self.inputColor5);
				cluster_[5] = CGColorCreateCopy(self.inputColor6);
				cluster_[6] = CGColorCreateCopy(self.inputColor7);
				cluster_[7] = CGColorCreateCopy(self.inputColor8);
				cluster_[8] = CGColorCreateCopy(self.inputColor9);
				cluster_[9] = CGColorCreateCopy(self.inputColor10);
				cluster_[10] = CGColorCreateCopy(self.inputColor11);
				cluster_[11] = CGColorCreateCopy(self.inputColor12);
				cluster_[12] = CGColorCreateCopy(self.inputColor13);
				cluster_[13] = CGColorCreateCopy(self.inputColor14);
				cluster_[14] = CGColorCreateCopy(self.inputColor15);
				cluster_[15] = CGColorCreateCopy(self.inputColor16);
			}			
			
			// Structures for updating the numerator and denominator of the new centroid for the cluster.
			unsigned int red[NUM_COLORS];
			unsigned int green[NUM_COLORS];
			unsigned int blue[NUM_COLORS];
			unsigned int count[NUM_COLORS];		
			for (int i = 0; i < num_colors; ++i) {
				red[i] = 0;
				green[i] = 0;
				blue[i] = 0;
				count[i] = 0;
			}
			
			// Assign each pixel to the cluster nearest it.
			unsigned char *r = (unsigned char*)inBuffer.data + RED_OFFSET;
			unsigned char *g = (unsigned char*)inBuffer.data + GREEN_OFFSET;
			unsigned char *b = (unsigned char*)inBuffer.data + BLUE_OFFSET;
			unsigned char *out_r = (unsigned char*)outBuffer.data + RED_OFFSET;
			unsigned char *out_g = (unsigned char*)outBuffer.data + GREEN_OFFSET;
			unsigned char *out_b = (unsigned char*)outBuffer.data + BLUE_OFFSET;
			unsigned char *out_alpha = (unsigned char*)outBuffer.data + ALPHA_OFFSET;
			for (int row = 0; row < inBuffer.height; ++row) {
				for (int column = 0; column < inBuffer.width; ++column) {
					unsigned char cluster = num_colors;
					double closest = 0.0;
					double dists[NUM_COLORS];
					double totalDist = 0.0;
					for (unsigned char c = 0; c < num_colors; ++c) {
						const CGFloat *color = CGColorGetComponents(cluster_[c]);
						double dist = (color[0] * 255 - *r) * (color[0] * 255 - *r) +
									  (color[1] * 255 - *g) * (color[1] * 255 - *g) +
									  (color[2] * 255 - *b) * (color[2] * 255 - *b);
						dists[c] = (3 * 255 * 255) / dist;
						totalDist += dists[c];
						if (cluster == num_colors || dist < closest) {
							cluster = c;
							closest = dist;
							*out_r = (unsigned char)(color[0] * 255);
							*out_g = (unsigned char)(color[1] * 255);
							*out_b = (unsigned char)(color[2] * 255);
							*out_alpha = 255;
						}
					}
					if (dither) {
						double p = ((rand() % 10001) / 10000.0) * totalDist;
						for (unsigned char c = 0; c < num_colors; ++c) {
							p -= dists[c];
							if (p < 0.001) {
								const CGFloat *color = CGColorGetComponents(cluster_[c]);
								*out_r = (unsigned char)(color[0] * 255);
								*out_g = (unsigned char)(color[1] * 255);
								*out_b = (unsigned char)(color[2] * 255);
								*out_alpha = 255;
								break;
							}
						}
					}
					red[cluster] += *r;
					green[cluster] += *g;
					blue[cluster] += *b;
					count[cluster] += 1;
					r += bytesPerPixel;
					g += bytesPerPixel;
					b += bytesPerPixel;
					out_r += bytesPerPixel;
					out_g += bytesPerPixel;
					out_b += bytesPerPixel;
					out_alpha += bytesPerPixel;
				}		
				r += inputRowPadding;
				g += inputRowPadding;
				b += inputRowPadding;
				out_r += outputRowPadding;
				out_g += outputRowPadding;
				out_b += outputRowPadding;
				out_alpha += outputRowPadding;
			}
			
			// Now recompute the centroid of each cluster.
			for (unsigned char c = 0; c < NUM_COLORS; ++c) {
				CGColorRelease(cluster_[c]);
				if (count[c]) {
					float n = (float)count[c] * 255.0;
					cluster_[c] = CGColorCreateGenericRGB(red[c] / n, green[c] / n, blue[c] / n, 1.0);
				} else {
					float n = 255.0;
					cluster_[c] = CGColorCreateGenericRGB((rand() % 256) / n, (rand() % 256) / n, (rand() % 256) / n, 1.0);
				}
			}
		}
		
		// Release the buffer representation.
		[inputImage unlockBufferRepresentation];
		
		// Create simple provider from memory buffer
		id provider = [context outputImageProviderFromBufferWithPixelFormat: FORMAT
																 pixelsWide: outBuffer.width
																 pixelsHigh: outBuffer.height
																baseAddress: outBuffer.data
																bytesPerRow: outBuffer.rowBytes
															releaseCallback: _BufferReleaseCallback
															 releaseContext: NULL
																 colorSpace: colorSpace
														   shouldColorMatch: YES];
		if (provider == nil) {
			free(outBuffer.data);
			return NO;
		}
		self.outputImage = provider;
	} else {
		self.outputImage = nil;
	}
	
	// Output the colors
	self.outputColor1 = cluster_[0];
	self.outputColor2 = cluster_[1];
	self.outputColor3 = cluster_[2];
	self.outputColor4 = cluster_[3];
	self.outputColor5 = cluster_[4];
	self.outputColor6 = cluster_[5];
	self.outputColor7 = cluster_[6];
	self.outputColor8 = cluster_[7];
	self.outputColor9 = cluster_[8];
	self.outputColor10 = cluster_[9];
	self.outputColor11 = cluster_[10];
	self.outputColor12 = cluster_[11];
	self.outputColor13 = cluster_[12];
	self.outputColor14 = cluster_[13];
	self.outputColor15 = cluster_[14];
	self.outputColor16 = cluster_[15];
	
	return YES;
}

- (void) disableExecution:(id<QCPlugInContext>)context {
	// Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
}

- (void) stopExecution:(id<QCPlugInContext>)context {
	// Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
}

@end
