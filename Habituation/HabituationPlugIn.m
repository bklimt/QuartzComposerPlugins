//
//  HabituationPlugIn.m
//  Habituation
//
//  Created by Bryan Klimt on 12/15/08.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */

#import <OpenGL/CGLMacro.h>
#import "HabituationPlugIn.h"

#define	kQCPlugIn_Name				@"Habituation"
#define	kQCPlugIn_Description		@"Habituation is awesome!"

@implementation HabituationPlugIn

// Declare the input / output properties as dynamic; Quartz Composer will handle their implementation
@dynamic inputImage;
@dynamic inputSamples;
@dynamic inputCycle;
@dynamic inputDifference;
@dynamic inputDifferenceLowerBound;
@dynamic inputDifferenceUpperBound;
@dynamic outputImage;
@dynamic outputCount;

- (id) init {
	if (self = [super init]) {
		// Allocate any permanent resource required by the plug-in.
		width_ = 0;
		height_ = 0;
		rowBytes_ = 0;
		front_ = 0;
		rear_ = 0;
		// reallocate the buffers.
		samples_ = NULL;
		redSums_ = NULL;
		greenSums_ = NULL;
		blueSums_ = NULL;
	}
	return self;
}

- (void) finalize {
	// Release any non garbage collected resources created in -init.
	if (samples_) {
		for (int i = 0; i < num_samples_ + 1; ++i) {
			if (samples_[i]) {
				free(samples_[i]);
			}
		}
		free(samples_);
	}
	if (redSums_) {
		free(redSums_);
	}
	if (greenSums_) {
		free(greenSums_);
	}
	if (blueSums_) {
		free(blueSums_);
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
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"input image", QCPortAttributeNameKey,
				nil];
	} else if ([key isEqualToString:@"inputCycle"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"cycle", QCPortAttributeNameKey,
				[NSNumber numberWithBool: NO], QCPortAttributeDefaultValueKey,
				nil];
	} else if ([key isEqualToString:@"inputSamples"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"samples", QCPortAttributeNameKey,
				[NSNumber numberWithInt: 20], QCPortAttributeDefaultValueKey,
				nil];
	} else if ([key isEqualToString:@"inputDifference"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"difference", QCPortAttributeNameKey,
				[NSNumber numberWithBool: NO], QCPortAttributeDefaultValueKey,
				nil];
	} else if ([key isEqualToString:@"inputDifferenceLowerBound"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"diff lower bound", QCPortAttributeNameKey,
				[NSNumber numberWithDouble: 0.1], QCPortAttributeDefaultValueKey,
				nil];
	} else if ([key isEqualToString:@"inputDifferenceUpperBound"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"diff upper bound", QCPortAttributeNameKey,
				[NSNumber numberWithDouble: 0.3], QCPortAttributeDefaultValueKey,
				nil];
	} else if ([key isEqualToString:@"outputCount"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"count", QCPortAttributeNameKey,
				nil];
	} else if ([key isEqualToString:@"outputImage"]) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"output image", QCPortAttributeNameKey,
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

@implementation HabituationPlugIn (Execution)

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
	
	double num_samples = self.inputSamples;
	BOOL cycle = self.inputCycle;
	BOOL difference = self.inputDifference;
	double differenceLowerBound = self.inputDifferenceLowerBound;
	double differenceUpperBound = self.inputDifferenceUpperBound;
	
	// If there's no source image, bail.
	id<QCPlugInInputImageSource> inputImage = self.inputImage;
	if (!inputImage) {
		self.outputImage = nil;
		self.outputCount = 0;
		return YES;
	}
	
	// Get a buffer representation from the source image.
	CGColorSpaceRef colorSpace = (CGColorSpaceGetModel([inputImage imageColorSpace]) == kCGColorSpaceModelRGB ?
								  [inputImage imageColorSpace] :
								  [context colorSpace]);
	if (![inputImage lockBufferRepresentationWithPixelFormat: FORMAT
												  colorSpace: colorSpace
												   forBounds: [inputImage imageBounds]]) {
		return NO;
	}
	
	// Check to see if we have to re-initialize the data before we start.
	BOOL reset = NO;
	if (width_ !=  [inputImage bufferPixelsWide] ||
		height_ != [inputImage bufferPixelsHigh] ||
		rowBytes_ != [inputImage bufferBytesPerRow] ||
		num_samples_ != num_samples) {
		reset = YES;
		// reset the state
		width_ = [inputImage bufferPixelsWide];
		height_ = [inputImage bufferPixelsHigh];
		rowBytes_ = [inputImage bufferBytesPerRow];
		front_ = 0;
		rear_ = 0;
		// reallocate the buffers.
		if (redSums_) { free(redSums_); }
		if (greenSums_) { free(greenSums_); }
		if (blueSums_) { free(blueSums_); }
		redSums_ = (unsigned int*)malloc(sizeof(unsigned int) * width_ * height_);
		greenSums_ = (unsigned int*)malloc(sizeof(unsigned int) * width_ * height_);
		blueSums_ = (unsigned int*)malloc(sizeof(unsigned int) * width_ * height_);
		if (samples_) {
			for (int i = 0; i < num_samples_ + 1; ++i) {
				if (samples_[i]) {
					free(samples_[i]);
				}
			}
			free(samples_);
		}
		num_samples_ = num_samples;
		samples_ = (unsigned char**)malloc((num_samples_ + 1) * sizeof(unsigned char*));
		for (int i = 0; i < num_samples_ + 1; ++i) {
			samples_[i] = (unsigned char*)malloc(rowBytes_ * height_);
		}
		for (int row = 0; row < height_; ++row) {
			for (int column = 0; column < width_; ++column) {
				int sums_offset = row * width_ + column;
				redSums_[sums_offset] = 0;
				greenSums_[sums_offset] = 0;
				blueSums_[sums_offset] = 0;
			}
		}
		
	}
	
	// Create an output memory buffer.
	vImage_Buffer outBuffer;
	outBuffer.width = width_;
	outBuffer.height = height_;
	outBuffer.rowBytes = outBuffer.width * 4;
	if (outBuffer.rowBytes % 16) {
		outBuffer.rowBytes = (outBuffer.rowBytes / 16 + 1) * 16;
	}
	outBuffer.data = valloc(outBuffer.rowBytes * outBuffer.height);
	if (outBuffer.data == NULL) {
		return NO;
	}
	
	// Create a buffer for the input image.
	vImage_Buffer inBuffer;
	inBuffer.data = (void*)[inputImage bufferBaseAddress];
	inBuffer.rowBytes = rowBytes_;
	inBuffer.width = width_;
	inBuffer.height = height_;
	
	// Generate the average image.
	const int bytesPerPixel = 4;
	int count = (rear_ >= front_) ? rear_ - front_ : (rear_ - front_) + num_samples_ + 1;
	if (count == 0) {
		count = 1;
	}
	
	int inputRowPadding = inBuffer.rowBytes - (inBuffer.width * bytesPerPixel);
	int outputRowPadding = outBuffer.rowBytes - (outBuffer.width * bytesPerPixel);
	
	unsigned char *output_red = (unsigned char*)outBuffer.data + RED_OFFSET;
	unsigned char *output_green = (unsigned char*)outBuffer.data + GREEN_OFFSET;
	unsigned char *output_blue = (unsigned char*)outBuffer.data + BLUE_OFFSET;
	unsigned char *output_alpha = (unsigned char*)outBuffer.data + ALPHA_OFFSET;
	
	unsigned char *input_red = (unsigned char*)inBuffer.data + RED_OFFSET;
	unsigned char *input_green = (unsigned char*)inBuffer.data + GREEN_OFFSET;
	unsigned char *input_blue = (unsigned char*)inBuffer.data + BLUE_OFFSET;
	unsigned char *input_alpha = (unsigned char*)inBuffer.data + ALPHA_OFFSET;
	
	unsigned int *redSum = redSums_;
	unsigned int *greenSum = greenSums_;
	unsigned int *blueSum = blueSums_;
	
	for (int row = 0; row < height_; ++row) {
		for (int column = 0; column < width_; ++column) {
			*output_red = (unsigned char)(*redSum++ / count);
			*output_green = (unsigned char)(*greenSum++ / count);
			*output_blue = (unsigned char)(*blueSum++ / count);
			*output_alpha = *input_alpha;
			
			if (difference) {
				const unsigned int error = (*output_red - *input_red) * (*output_red - *input_red) +
				(*output_green - *input_green) * (*output_green - *input_green) +
				(*output_blue - *input_blue) * (*output_blue - *input_blue);
				const unsigned int max_error = 3 * 255 * 255;
				double error_frac = sqrt(error) / sqrt(max_error);
				if (error_frac < differenceLowerBound) {
					error_frac = 0;
				} else if (error_frac > differenceUpperBound) {
					error_frac = 1;
				} else {
					error_frac = (error_frac - differenceLowerBound) / (differenceUpperBound - differenceLowerBound);
				}
				unsigned char error_color = error_frac * 255;
				*output_red = error_color;
				*output_green = error_color;
				*output_blue = error_color;
			}
			
			input_red += bytesPerPixel;
			input_green += bytesPerPixel;
			input_blue += bytesPerPixel;
			input_alpha += bytesPerPixel;
			
			output_red += bytesPerPixel;
			output_green += bytesPerPixel;
			output_blue += bytesPerPixel;
			output_alpha += bytesPerPixel;
		}
		
		input_red += inputRowPadding;
		input_green += inputRowPadding;
		input_blue += inputRowPadding;
		input_alpha += inputRowPadding;
		
		output_red += outputRowPadding;
		output_green += outputRowPadding;
		output_blue += outputRowPadding;
		output_alpha += outputRowPadding;		
	}
	
	// Subtract the oldest image from the sums, if you've seen enough.
	if ((rear_ + 1) % (num_samples_ + 1) == front_ && cycle) {
		front_ = (front_ + 1) % (num_samples_ + 1);
		int rowPadding = rowBytes_ - (width_ * bytesPerPixel);
		
		unsigned char *red = samples_[front_] + RED_OFFSET;
		unsigned char *green = samples_[front_] + GREEN_OFFSET;
		unsigned char *blue = samples_[front_] + BLUE_OFFSET;
		
		redSum = redSums_;
		greenSum = greenSums_;
		blueSum = blueSums_;
		
		for (int row = 0; row < height_; ++row) {
			for (int column = 0; column < width_; ++column) {
				*redSum++ -= *red;
				*greenSum++ -= *green;
				*blueSum++ -= *blue;
				
				red += bytesPerPixel;
				green += bytesPerPixel;
				blue += bytesPerPixel;
			}
			
			red += rowPadding;
			green += rowPadding;
			blue += rowPadding;
		}
	}
	
	// Add the input image to the known data.
	if ((rear_ + 1) % (num_samples_ + 1) != front_) {
		rear_ = (rear_ + 1) % (num_samples_ + 1);
		memcpy(samples_[rear_], (unsigned char*)inBuffer.data, inBuffer.rowBytes * inBuffer.height);
		
		unsigned char *red = inBuffer.data + RED_OFFSET;
		unsigned char *green = inBuffer.data + GREEN_OFFSET;
		unsigned char *blue = inBuffer.data + BLUE_OFFSET;
		
		redSum = redSums_;
		greenSum = greenSums_;
		blueSum = blueSums_;
		
		for (int row = 0; row < height_; ++row) {
			for (int column = 0; column < width_; ++column) {
				*redSum++ += *red;
				*greenSum++ += *green;
				*blueSum++ += *blue;
				
				red += bytesPerPixel;
				green += bytesPerPixel;
				blue += bytesPerPixel;
			}
			
			red += inputRowPadding;
			green += inputRowPadding;
			blue += inputRowPadding;
		}
	}
	
	// Release the buffer representation.
	[inputImage unlockBufferRepresentation];
	
	// If this was a reset, don't render the image with no data.
	if (reset) {
		self.outputImage = nil;
		self.outputCount = count;
		return YES;
	}
	
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
	
	// Update the result image
	self.outputImage = provider;
	self.outputCount = count;
	return YES;
}

- (void) disableExecution:(id<QCPlugInContext>)context {
	// Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
}

- (void) stopExecution:(id<QCPlugInContext>)context {
	// Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
}

@end
