//
//  SecondViewController.h
//  ArtMe
//
//  Created by Caroline Hermans on 12/3/16.
//  Copyright © 2016 Caroline Hermans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"
#import <CoreImage/CoreImage.h>
#import <GLKit/GLKit.h>


@interface SecondViewController : UIViewController

@property(nonatomic) NSString *paintingName;
@property(nonatomic) NSMutableDictionary *currentPaintingDictionary;
@property(nonatomic) NSString *paintingArtist;
@property(nonatomic) NSString *paintingYear;
@property(nonatomic) NSString *paintingImage;
@property (weak, nonatomic) IBOutlet UIImageView *paintingImageView;

@property (weak, nonatomic) IBOutlet UILabel *paintingNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *paintingArtistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property AVCaptureDevice *videoDevice;
@property AVCaptureSession *captureSession;
@property dispatch_queue_t captureSessionQueue;
@property GLKView *videoPreviewView;
@property CIContext *ciContext;
@property EAGLContext *eaglContext;
@property CGRect videoPreviewViewBounds;

@property CGFloat paintingFaceWidth;
@property CGFloat paintingFaceHeight;
@property CGFloat paintingFaceX;
@property CGFloat paintingFaceY;

@property CIDetector *detector;




@end
