//
//  ViewController.h
//  TestDownloader
//
//  Created by Andrey Karaban on 20/11/15.
//  Copyright © 2015 Andrey Karaban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDwnLMainController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblFiles;
@property (weak, nonatomic) IBOutlet UILabel *downLoadsCount;

@end

