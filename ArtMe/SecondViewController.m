//
//  SecondViewController.m
//  ArtMe
//
//  Created by Caroline Hermans on 12/3/16.
//  Copyright © 2016 Caroline Hermans. All rights reserved.
//

#import "SecondViewController.h"
#import "AVFoundation/AVFoundation.h"
#import <CoreImage/CoreImage.h>
#import <GLKit/GLKit.h>

@interface SecondViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Load info for face detection and scaling
    [self loadFaceSizeValues];
    
    // Set up OpenGL
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _videoPreviewView = [[GLKView alloc] initWithFrame:CGRectMake(_paintingFaceX, _paintingFaceY, _paintingFaceHeight, _paintingFaceWidth) context:_eaglContext];
    _videoPreviewView.enableSetNeedsDisplay = NO;
    
    // Clear backgrounds so that the views are semi-transparent
    _videoPreviewView.backgroundColor = [UIColor clearColor];
    _paintingImageView.backgroundColor = [UIColor clearColor];
    
    // Portrait mode
    _videoPreviewView.transform = CGAffineTransformMakeRotation(M_PI_2);
    
 
    // Add views for the camera feed
    [self.view addSubview:_videoPreviewView];
    [self.view bringSubviewToFront:_videoPreviewView];
    
    // Layer painting view on top of camera feed view
    [self.view bringSubviewToFront:_paintingImageView];
    
    // Continue setting up video preview
    [_videoPreviewView bindDrawable];
    _videoPreviewViewBounds = CGRectZero;
    _videoPreviewViewBounds.size.width = _videoPreviewView.drawableWidth;
    _videoPreviewViewBounds.size.height = _videoPreviewView.drawableHeight;

    
    _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
    
    // Start running AVCapture
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 0)
    {
        
        [self _start];
    }

    
    // Set up face detection
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"CIDetectorAccuracy", @"CIDetectorAccuracyLow", nil];
    
    
    _detector =  [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
    
    
    // Set up global painting information
    _paintingArtist = [_currentPaintingDictionary objectForKey:@"painter"];
    _paintingYear = [_currentPaintingDictionary objectForKey:@"year"];
    _paintingImage = [_currentPaintingDictionary objectForKey:@"img"];
    
    // Draw the camera feed in the correct place
    _drawRect = CGRectMake(_paintingFaceX, _paintingFaceY, _paintingFaceHeight, _paintingFaceWidth);
    
    [self displayPaintingInfo];
}

// Handler grabs each AVCapture frame
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // Get CIImage from camera feed
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];

    CGRect sourceExtent = sourceImage.extent;
    
    // Flip the video feed horizontally to be a mirror
    sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeScale(1, -1)];
    sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeTranslation(0, sourceExtent.size.height)];
    
    // Filter image based on which painting is selected
    CIFilter *tempAndTintFilter = [CIFilter filterWithName:@"CITemperatureAndTint"];
    [tempAndTintFilter setValue:sourceImage forKey:kCIInputImageKey];
    [tempAndTintFilter setValue:[CIVector vectorWithX:6500 Y:500] forKey:@"inputNeutral"];
    if ([_paintingName isEqualToString:@"The Mona Lisa"]) {
        [tempAndTintFilter setValue:[CIVector vectorWithX:6500 Y:410] forKey:@"inputTargetNeutral"];
    } else if ([_paintingName isEqualToString:@"Portrait of Henry VIII"]){
        [tempAndTintFilter setValue:[CIVector vectorWithX:6520 Y:500] forKey:@"inputTargetNeutral"];
    } else if ([_paintingName isEqualToString:@"Self Portrait"]){
        [tempAndTintFilter setValue:[CIVector vectorWithX:6700 Y:510] forKey:@"inputTargetNeutral"];
    } else if ([_paintingName isEqualToString:@"Girl with a Pearl Earring"]){
        [tempAndTintFilter setValue:[CIVector vectorWithX:6600 Y:490] forKey:@"inputTargetNeutral"];
    } else if ([_paintingName isEqualToString:@"The Laughing Cavaliercolors are "]){
        [tempAndTintFilter setValue:[CIVector vectorWithX:6520 Y:500] forKey:@"inputTargetNeutral"];
    }
    CIImage *filteredImage = [tempAndTintFilter outputImage];
    
    if ([_paintingName isEqualToString:@"Self Portrait"]) {
        CIFilter *colorControlsFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
        [colorControlsFilter setValue: filteredImage forKey:kCIInputImageKey];
        [colorControlsFilter setValue: @0.9 forKey:@"inputEV" ];
        filteredImage = [colorControlsFilter outputImage];
    } else if ([_paintingName isEqualToString:@"Girl with a Pearl Earring"]) {
        CIFilter *colorControlsFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
        [colorControlsFilter setValue: filteredImage forKey:kCIInputImageKey];
        [colorControlsFilter setValue: @0.9 forKey:@"inputEV" ];
        filteredImage = [colorControlsFilter outputImage];
    }
    

    // Set CIDetector orientation to recognize portrait mode
    NSDictionary* imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6] forKey:CIDetectorImageOrientation];

    // Detect face features
    NSArray *features = [_detector featuresInImage:sourceImage options:imageOptions];
    
    // For each face found, the bounding rectangle becomes the section of the image we save.
    for(CIFaceFeature* feature in features)
    {
        _drawRect = feature.bounds;
    }

    // Draw video feed
    [_videoPreviewView bindDrawable];
    
    
    // More OpenGL setup
    if (_eaglContext != [EAGLContext currentContext])
        [EAGLContext setCurrentContext:_eaglContext];
    
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    // Draw the new image
    if (filteredImage)
        [_ciContext drawImage:filteredImage inRect:_videoPreviewViewBounds fromRect:_drawRect];
    
    // Display the view
    [_videoPreviewView display];
    
}

-(void)_start
{
    // Find video devices facing front
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == position) {
            _videoDevice = device;
            break;
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
    if (!videoDeviceInput)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"Unable to obtain video device input, error: %@", error]);
        return;
    }
    
    NSString *preset = AVCaptureSessionPresetMedium;
    if (![_videoDevice supportsAVCaptureSessionPreset:preset])
    {
        NSLog(@"%@", [NSString stringWithFormat:@"Capture session preset not supported by video device: %@", preset]);
        return;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = preset;
    
    NSDictionary *outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
    
    // Create Video Data Output so that we can manage the camera feed
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    videoDataOutput.videoSettings = outputSettings;
    
    // Serial queue to handle frames in order
    _captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
    [videoDataOutput setSampleBufferDelegate:self queue:_captureSessionQueue];
    
    // Don't back up and get laggy
    videoDataOutput.alwaysDiscardsLateVideoFrames = YES;

    [_captureSession beginConfiguration];
    
    if (![_captureSession canAddOutput:videoDataOutput])
    {
        NSLog(@"Cannot add video data output");
        _captureSession = nil;
        return;
    }
    
    // Connect the inputs and outputs
    [_captureSession addInput:videoDeviceInput];
    [_captureSession addOutput:videoDataOutput];
    
    [_captureSession commitConfiguration];
    
    // Begin running session
    [_captureSession startRunning];
}

// Display facts about the current painting at the top of the camera view
- (void) displayPaintingInfo {
    _paintingArtistLabel.text = _paintingArtist;
    _paintingNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", _paintingName, _paintingYear];
    _paintingImageView.image = [UIImage imageNamed:_paintingImage];
}

// Set global constants associated with where the face should be for each painting
-(void) loadFaceSizeValues {
    if ([self.paintingName isEqualToString:@"The Mona Lisa"]) {
        _paintingFaceWidth = 75;
        _paintingFaceHeight = 90;
        _paintingFaceX = 138;
        _paintingFaceY = 195;
    } else if ([self.paintingName isEqualToString:@"Portrait of Henry VIII"]){
        _paintingFaceWidth = 75;
        _paintingFaceHeight = 80;
        _paintingFaceX = 149;
        _paintingFaceY = 195;
    } else if ([self.paintingName isEqualToString:@"Self Portrait"]){
        _paintingFaceWidth = 110;
        _paintingFaceHeight = 130;
        _paintingFaceX = 110;
        _paintingFaceY = 250;
    } else if ([self.paintingName isEqualToString:@"Girl with a Pearl Earring"]){
        _paintingFaceWidth = 100;
        _paintingFaceHeight = 130;
        _paintingFaceX = 83;
        _paintingFaceY = 265;
    } else if ([self.paintingName isEqualToString:@"The Laughing Cavalier"]){
        _paintingFaceWidth = 55;
        _paintingFaceHeight = 68;
        _paintingFaceX = 120;
        _paintingFaceY = 235;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
