//
//  SecondViewController.m
//  ArtMe
//
//  Created by Caroline Hermans on 12/3/16.
//  Copyright © 2016 Caroline Hermans. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _paintingArtist = [_currentPaintingDictionary objectForKey:@"painter"];
    _paintingYear = [_currentPaintingDictionary objectForKey:@"year"];
    _paintingImage = [_currentPaintingDictionary objectForKey:@"img"];
    
    [self displayPaintingInfo];
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
