//
//  CCSVGSource.m
//  CCSVG
//
//  Created by Luke Lutman on 12-05-22.
//  Copyright (c) 2012 Zinc Roe Design. All rights reserved.
//

#import <openvg/mkOpenVG_SVG.h>
#import <MonkVG/openvg.h>
#import <MonkVG/vgext.h>
#import "CCSVGSource.h"
#import "CCFileUtils.h"


@interface CCSVGSource ()

@property (nonatomic, readwrite, assign) BOOL isOptimized;

@property (nonatomic, readwrite, assign) MonkSVG::OpenVG_SVGHandler::SmartPtr svg;

@end


@implementation CCSVGSource


#pragma mark

+ (void)initialize {
    [self setTessellationIterations:3];
}

+ (void)setTessellationIterations:(NSUInteger)numberOfTesselationIterations {
    vgSeti(VG_TESSELLATION_ITERATIONS_MNK, numberOfTesselationIterations);
}


#pragma mark

@synthesize contentRect = contentRect_;

@synthesize contentSize = contentSize_;

@synthesize isOptimized = isOptimized_;

@synthesize svg = svg_;

- (BOOL)hasTransparentColors {
	return svg_->hasTransparentColors();
}


#pragma mark 

- (id)init {
    if ((self = [super init])) {
        isOptimized_ = NO;
        svg_ = boost::static_pointer_cast<MonkSVG::OpenVG_SVGHandler>(MonkSVG::OpenVG_SVGHandler::create());
    }
    return self;
}

- (id)initWithData:(NSData *)data {
    if ((self = [self init])) {
        
        MonkSVG::SVG parser;
        parser.initialize(svg_);
        parser.read((char *)data.bytes);
        
        contentRect_ = CGRectMake(svg_->minX(), svg_->minY(), svg_->width(), svg_->height());
        contentSize_ = CGSizeMake(svg_->width(), svg_->height());
        
    }
    return self;
}

- (id)initWithFile:(NSString *)name {
	
	NSString *path;
    
    NSBundle* bundle = [CCFileUtils sharedFileUtils].bundle;
	path = [bundle pathForResource:name ofType:nil];
    NSAssert1(path, @"Missing SVG file: %@", name);
	
	NSData *data;
	data = [NSData dataWithContentsOfFile:path];
    NSAssert1(data, @"Invalid SVG file: %@", name);
	
	return [self initWithData:data];
    
}

- (void)dealloc {
    [super dealloc];
}


#pragma mark

- (void)draw {
    //GL_NO_ERROR
//    [self optimize]; // FIXME: optimizing seems to be broken in GLES 2.0.  
    
    svg_->draw();
    
}

- (void)optimize {
    
    if (!isOptimized_) {
        
        VGfloat matrix[9];
        vgGetMatrix(matrix);
        
        vgLoadIdentity();
        svg_->optimize();
        vgLoadMatrix(matrix);
        
        isOptimized_ = YES;
        
    }
    
}


@end
