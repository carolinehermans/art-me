//
//  ViewController.m
//  ArtMe
//
//  Created by Caroline Hermans on 12/3/16.
//  Copyright © 2016 Caroline Hermans. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"


@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _paintingInfo = [NSMutableDictionary dictionary];
    [self populatePaintingInfoDictionary];
}


- (IBAction)paintingTapped:(UIButton *)sender {
    _paintingName = sender.currentTitle;
    _currentPaintingDictionary = [_paintingInfo valueForKeyPath:_paintingName];
    [self performSegueWithIdentifier:@"Next" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SecondViewController *controller = (SecondViewController *)segue.destinationViewController;
    controller.paintingName = self.paintingName;
    controller.currentPaintingDictionary = self.currentPaintingDictionary;
}

- (void) populatePaintingInfoDictionary {
    NSMutableDictionary *monaDictionary = [self populatePaintingDictionaryWithPainter:@"Leonardo Da Vinci" WithYear:@"1506" WithImage:@"mona.jpg"];
    NSMutableDictionary *kissDictionary = [self populatePaintingDictionaryWithPainter:@"Gustav Klimt" WithYear:@"1908" WithImage:@"kiss.jpg"];
    NSMutableDictionary *pearlDictionary = [self populatePaintingDictionaryWithPainter:@"Johannes Vermeer" WithYear:@"1665" WithImage:@"pearl.jpg"];
    
    [_paintingInfo setObject:monaDictionary forKey:@"The Mona Lisa"];
    [_paintingInfo setObject:kissDictionary forKey:@"The Kiss"];
    [_paintingInfo setObject:pearlDictionary forKey:@"Girl with a Pearl Earring"];
    
}

- (NSMutableDictionary*) populatePaintingDictionaryWithPainter:(NSString*)painter WithYear:(NSString*)year WithImage:(NSString*)img {
    NSMutableDictionary *painting = [NSMutableDictionary dictionary];
    [painting setValue:painter forKey:@"painter"];
    [painting setValue:year forKey:@"year"];
    [painting setValue:img forKey:@"img"];
    return painting;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
