//
//  SegueFromLeft.m
//  ArtMe
//
//  Created by Caroline Hermans on 12/4/16.
//  Copyright © 2016 Caroline Hermans. All rights reserved.
//

#import "SegueFromLeft.h"

@implementation SegueFromLeft

class SegueFromLeft: UIStoryboardSegue
override func perform() {
    let sourceViewController = self.sourceViewController
    let destinationViewController = self.destinationViewController
    // Creates a screenshot of the old viewcontroller
    let duplicatedSourceView: UIView = sourceViewController.view.snapshotViewAfterScreenUpdates(false)
    
    // the screenshot is added above the destinationViewController
    destinationViewController.view.addSubview(duplicatedSourceView)
    
    sourceViewController.presentViewController(destinationViewController, animated: false, completion: {
        // it is added above the destinationViewController
        destinationViewController.view.addSubview(duplicatedSourceView)
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            // slides the sourceViewController to the right
            duplicatedSourceView.transform = CGAffineTransformMakeTranslation(sourceViewController.view.frame.size.width, 0)
        }) { (finished: Bool) -> Void in
            duplicatedSourceView.removeFromSuperview()
        }
    })
    
}

@end
