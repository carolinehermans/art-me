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
    }
    
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _videoPreviewView = [[GLKView alloc] initWithFrame:CGRectMake(_paintingFaceX, _paintingFaceY, _paintingFaceHeight, _paintingFaceWidth) context:_eaglContext];
    _videoPreviewView.enableSetNeedsDisplay = NO;
        
    _videoPreviewView.backgroundColor = [UIColor clearColor];
    _paintingImageView.backgroundColor = [UIColor clearColor];



    
    _videoPreviewView.transform = CGAffineTransformMakeRotation(M_PI_2);
    
 
    [self.view addSubview:_videoPreviewView];
    [self.view bringSubviewToFront:_videoPreviewView];
    
    [self.view bringSubviewToFront:_paintingImageView];
    
    // bind the frame buffer to get the frame buffer width and height;
    // the bounds used by CIContext when drawing to a GLKView are in pixels (not points),
    // hence the need to read from the frame buffer's width and height;
    // in addition, since we will be accessing the bounds in another queue (_captureSessionQueue),
    // we want to obtain this piece of information so that we won't be
    // accessing _videoPreviewView's properties from another thread/queue
    [_videoPreviewView bindDrawable];
    _videoPreviewViewBounds = CGRectZero;
    _videoPreviewViewBounds.size.width = _videoPreviewView.drawableWidth;
    _videoPreviewViewBounds.size.height = _videoPreviewView.drawableHeight;

    
    
    // create the CIContext instance, note that this must be done after _videoPreviewView is properly set up
    _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
    
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 0)
    {
        
        [self _start];
    }
    else
    {
        NSLog(@"No device with AVMediaTypeVideo");
    }
    
    // face detect
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"CIDetectorAccuracy", @"CIDetectorAccuracyLow", nil];
    
    
    _detector =  [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
    
    _paintingArtist = [_currentPaintingDictionary objectForKey:@"painter"];
    _paintingYear = [_currentPaintingDictionary objectForKey:@"year"];
    _paintingImage = [_currentPaintingDictionary objectForKey:@"img"];
    
    _drawRect = CGRectMake(_paintingFaceX, _paintingFaceY, _paintingFaceHeight, _paintingFaceWidth);
    
    [self displayPaintingInfo];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];

    CGRect sourceExtent = sourceImage.extent;
    
    sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeScale(1, -1)];
    sourceImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeTranslation(0, sourceExtent.size.height)];
    
    // Image processing

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
    

    
    CGFloat sourceAspect = sourceExtent.size.width / sourceExtent.size.height;
    CGFloat previewAspect = _videoPreviewViewBounds.size.width  / _videoPreviewViewBounds.size.height;
    
    NSDictionary* imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6] forKey:CIDetectorImageOrientation];

    
    NSArray *features = [_detector featuresInImage:sourceImage options:imageOptions];
//    NSLog(@"no of face detected: %d", [features count]);
    
    
    for(CIFaceFeature* feature in features)
    {
        _drawRect = feature.bounds;
    }

    
    [_videoPreviewView bindDrawable];
    
    if (_eaglContext != [EAGLContext currentContext])
        [EAGLContext setCurrentContext:_eaglContext];
    
    // clear eagl view to grey
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // set the blend mode to "source over" so that CI will use that
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    if (filteredImage)
        [_ciContext drawImage:filteredImage inRect:_videoPreviewViewBounds fromRect:_drawRect];
    
    [_videoPreviewView display];
    
}

-(void)_start
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
    
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == position) {
            _videoDevice = device;
            break;
        }
    }
    
    // obtain device input
    NSError *error = nil;
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
    if (!videoDeviceInput)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"Unable to obtain video device input, error: %@", error]);
        return;
    }
    
    // obtain the preset and validate the preset
    NSString *preset = AVCaptureSessionPresetMedium;
    if (![_videoDevice supportsAVCaptureSessionPreset:preset])
    {
        NSLog(@"%@", [NSString stringWithFormat:@"Capture session preset not supported by video device: %@", preset]);
        return;
    }
    
    // create the capture session
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = preset;
    
    // CoreImage wants BGRA pixel format
    NSDictionary *outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
    // create and configure video data output
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    videoDataOutput.videoSettings = outputSettings;
    
    // create the dispatch queue for handling capture session delegate method calls
    _captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
    [videoDataOutput setSampleBufferDelegate:self queue:_captureSessionQueue];
    
    videoDataOutput.alwaysDiscardsLateVideoFrames = YES;

    // begin configure capture session
    [_captureSession beginConfiguration];
    
    if (![_captureSession canAddOutput:videoDataOutput])
    {
        NSLog(@"Cannot add video data output");
        _captureSession = nil;
        return;
    }
    
    // connect the video device input and video data and still image outputs
    [_captureSession addInput:videoDeviceInput];
    [_captureSession addOutput:videoDataOutput];
    
    [_captureSession commitConfiguration];
    
    // then start everything
    [_captureSession startRunning];
}

- (void) displayPaintingInfo {
    _paintingArtistLabel.text = _paintingArtist;
    _paintingNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", _paintingName, _paintingYear];
    _paintingImageView.image = [UIImage imageNamed:_paintingImage];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
