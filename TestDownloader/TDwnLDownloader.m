//
//  TDwnLDownloader.m
//  TestDownloader
//
//  Created by Andrey Karaban on 20/11/15.
//  Copyright © 2015 Andrey Karaban. All rights reserved.
//

#import "TDwnLDownloader.h"

@implementation TDwnLDownloader

-(id)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source
{
    if (self == [super init])
    {
        self.fileTitle = title;
        self.downloadSource = source;
        self.downloadProgress = 0.0;
        self.isDownloading = NO;
        self.downloadComplete = NO;
        self.taskIdentifier = -1;
    }
    
    return self;
}


@end
