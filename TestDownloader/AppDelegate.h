//
//  AppDelegate.h
//  TestDownloader
//
//  Created by Andrey Karaban on 20/11/15.
//  Copyright © 2015 Andrey Karaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) void(^backgroundTransferCompletionHandler)();

@end

