//
//  TDwnLDownloader.h
//  TestDownloader
//
//  Created by Andrey Karaban on 20/11/15.
//  Copyright © 2015 Andrey Karaban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDwnLDownloader : NSObject

@property (nonatomic, strong) NSString *fileTitle;

@property (nonatomic, strong) NSString *downloadSource;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong) NSData *taskResumeData;

@property (nonatomic) double downloadProgress;

@property (nonatomic) BOOL isDownloading;

@property (nonatomic) BOOL downloadComplete;

@property (nonatomic) unsigned long taskIdentifier;

-(id)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source;

@end
