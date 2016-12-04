//
//  SecondViewController.h
//  ArtMe
//
//  Created by Caroline Hermans on 12/3/16.
//  Copyright © 2016 Caroline Hermans. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController

@property(nonatomic) NSString *paintingName;
@property(nonatomic) NSMutableDictionary *currentPaintingDictionary;
@property(nonatomic) NSString *paintingArtist;
@property(nonatomic) NSString *paintingYear;
@property(nonatomic) NSString *paintingImage;

@property (weak, nonatomic) IBOutlet UILabel *paintingNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *paintingArtistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *paintingImageView;


@end
