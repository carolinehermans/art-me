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
    
    // Load in data about painters and paintings
    _paintingInfo = [NSMutableDictionary dictionary];
    [self populatePaintingInfoDictionary];
}

// Respond to painting selection
- (IBAction)paintingTapped:(UIButton *)sender {
    // Update information
    _paintingName = sender.currentTitle;
    _currentPaintingDictionary = [_paintingInfo valueForKeyPath:_paintingName];
    // Pass information on to next view controller
    [self performSegueWithIdentifier:@"Next" sender:self];
}

// Pass information on to next view controller
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SecondViewController *controller = (SecondViewController *)segue.destinationViewController;
    controller.paintingName = self.paintingName;
    controller.currentPaintingDictionary = self.currentPaintingDictionary;
}

// Load information about painters and paintings
- (void) populatePaintingInfoDictionary {
    NSMutableDictionary *monaDictionary = [self populatePaintingDictionaryWithPainter:@"Leonardo Da Vinci" WithYear:@"1506" WithImage:@"mona.png"];
    NSMutableDictionary *kissDictionary = [self populatePaintingDictionaryWithPainter:@"Gustav Klimt" WithYear:@"1908" WithImage:@"kiss.jpg"];
    NSMutableDictionary *pearlDictionary = [self populatePaintingDictionaryWithPainter:@"Johannes Vermeer" WithYear:@"1665" WithImage:@"pearl.jpg"];
    NSMutableDictionary *henryDictionary = [self populatePaintingDictionaryWithPainter:@"Hans Holbein" WithYear:@"1537" WithImage:@"henry.jpg"];
    NSMutableDictionary *selfDictionary = [self populatePaintingDictionaryWithPainter:@"Vincent Van Gogh" WithYear:@"1889" WithImage:@"self.jpg"];
    NSMutableDictionary *cavalierDictionary = [self populatePaintingDictionaryWithPainter:@"Frans Hals" WithYear:@"1624" WithImage:@"cavalier.jpg"];
    
    [_paintingInfo setObject:monaDictionary forKey:@"The Mona Lisa"];
    [_paintingInfo setObject:kissDictionary forKey:@"The Kiss"];
    [_paintingInfo setObject:pearlDictionary forKey:@"Girl with a Pearl Earring"];
    [_paintingInfo setObject:henryDictionary forKey:@"Portrait of Henry VIII"];
    [_paintingInfo setObject:selfDictionary forKey:@"Self Portrait"];
    [_paintingInfo setObject:cavalierDictionary forKey:@"The Laughing Cavalier"];
    
}

// Helper function for painting information load
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
