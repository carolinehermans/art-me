//
//  ViewController.h
//  ArtMe
//
//  Created by Caroline Hermans on 12/3/16.
//  Copyright © 2016 Caroline Hermans. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction) paintingTapped:(UIButton *)sender;

@property(nonatomic) NSString *paintingName;
@property (nonatomic) NSMutableDictionary *paintingInfo;
@property(nonatomic) NSMutableDictionary *currentPaintingDictionary;

@end

