//
//  ViewController.h
//  PhotoDownloader
//
//  Created by Anand Patel on 21/12/12.
//  Copyright (c) 2012 Anand Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ViewController : UIViewController{
    AppDelegate *delegate;
    serverAPIClass *serverAPI;
}

@end
