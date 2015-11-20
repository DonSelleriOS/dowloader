//
//  ViewController.m
//  TestDownloader
//
//  Created by Andrey Karaban on 20/11/15.
//  Copyright © 2015 Andrey Karaban. All rights reserved.
//

#import "TDwnLMainController.h"
#import "TDwnLDownloader.h"
#import "AppDelegate.h"

#define CellLabelTagValue               10
#define CellProgressBarTagValue         20
#define CellLabelReadyTagValue          30

@interface TDwnLMainController ()

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSMutableArray *arrFileDownloadData;

@property (nonatomic, strong) NSURL *docDirectoryURL;

-(void)initializeFileDownloadDataArray;
-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier;

@end

@implementation TDwnLMainController

{
    int countOfDownLoads;
}


@synthesize arrFileDownloadData, docDirectoryURL, tblFiles, downLoadsCount;
@synthesize session;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeFileDownloadDataArray];
    
    downLoadsCount.text = @"Number of current downloads: 0";
    
    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    docDirectoryURL = [URLs objectAtIndex:0];
    
    tblFiles.delegate = self;
    tblFiles.dataSource = self;
    
    tblFiles.scrollEnabled = YES;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.TestDownloader"];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 8;
    
    session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
    countOfDownLoads = 0;
    
    [self startAllDownloads];
}

-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier{
    int index = 0;
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        TDwnLDownloader *dwn = [self.arrFileDownloadData objectAtIndex:i];
        if (dwn.taskIdentifier == taskIdentifier) {
            index = i;
            break;
        }
    }
    return index;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom initialization methods

-(void)initializeFileDownloadDataArray
{
    if (arrFileDownloadData != nil)
        [arrFileDownloadData removeAllObjects];
    
    arrFileDownloadData = [NSMutableArray new];
    
    for (int i = 0; i < 8; i++)
    {
        [arrFileDownloadData addObject:[[TDwnLDownloader alloc] initWithFileTitle:@"Downloading file" andDownloadSource:@"https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/NetworkingOverview.pdf"]];
    }
}

#pragma mark - TableViewDelegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrFileDownloadData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"idCell"];
    }
    
    TDwnLDownloader *fdi = [self.arrFileDownloadData objectAtIndex:indexPath.row];
    
    // Get all cell's subviews.
    UILabel *displayedTitle = (UILabel *)[cell viewWithTag:CellLabelTagValue];
    UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:CellProgressBarTagValue];
    UILabel *readyLabel = (UILabel *)[cell viewWithTag:CellLabelReadyTagValue];
    
    displayedTitle.text = fdi.fileTitle;
    
    if (!fdi.isDownloading) {
        progressView.hidden = YES;
        BOOL hideControls = (fdi.downloadComplete) ? YES : NO;
        readyLabel.hidden = !hideControls;
    }
    else{
        progressView.hidden = NO;
        progressView.progress = fdi.downloadProgress;
    }
    
    return cell;
}

#pragma mark - customActions

- (void)startDownloadingSingleFile:(id)sender {
    if ([[[[sender superview] superview] superview] isKindOfClass:[UITableViewCell class]]) {
        
        UITableViewCell *containerCell = (UITableViewCell *)[[[sender superview] superview] superview];
        
        NSIndexPath *cellIndexPath = [self.tblFiles indexPathForCell:containerCell];
        int cellIndex = cellIndexPath.row;
        
        TDwnLDownloader *dwn = [arrFileDownloadData objectAtIndex:cellIndex];
        
        if (!dwn.isDownloading) {
            if (dwn.taskIdentifier == -1) {
                dwn.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:dwn.downloadSource]];
                
                dwn.taskIdentifier = dwn.downloadTask.taskIdentifier;
                
                [dwn.downloadTask resume];
            }
            else{
                dwn.downloadTask = [self.session downloadTaskWithResumeData:dwn.taskResumeData];
                [dwn.downloadTask resume];
                
                dwn.taskIdentifier = dwn.downloadTask.taskIdentifier;
            }
        }
        
        dwn.isDownloading = !dwn.isDownloading;
        
        [self.tblFiles reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}
- (void) startAllDownloads
{
     for (int i=0; i<[self.arrFileDownloadData count]; i++)
     {
        TDwnLDownloader *dwn = [self.arrFileDownloadData objectAtIndex:i];
        
        if (!dwn.isDownloading) {
            if (dwn.taskIdentifier == -1) {
                dwn.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:dwn.downloadSource]];
            }
            else{
                dwn.downloadTask = [self.session downloadTaskWithResumeData:dwn.taskResumeData];
            }
            
             dwn.taskIdentifier = dwn.downloadTask.taskIdentifier;
            
             [dwn.downloadTask resume];
            
            dwn.isDownloading = YES;
        }
    }
    
    [self.tblFiles reloadData];
}

#pragma mark - NSURLSession Delegate method implementation

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *destinationFilename = downloadTask.originalRequest.URL.lastPathComponent;
    NSURL *destinationURL = [self.docDirectoryURL URLByAppendingPathComponent:destinationFilename];
    
    if ([fileManager fileExistsAtPath:[destinationURL path]]) {
        [fileManager removeItemAtURL:destinationURL error:nil];
    }
    
    BOOL success = [fileManager copyItemAtURL:location
                                        toURL:destinationURL
                                        error:&error];
    
    if (success) {
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        TDwnLDownloader *dwn = [self.arrFileDownloadData objectAtIndex:index];
        
        dwn.isDownloading = NO;
        dwn.downloadComplete = YES;
        dwn.taskIdentifier = -1;
        dwn.taskResumeData = nil;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tblFiles reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                 withRowAnimation:UITableViewRowAnimationNone];
            
        }];
        
    }
    else{
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error != nil) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    else{
        countOfDownLoads ++;
        
        downLoadsCount.text = [NSString stringWithFormat:@"Number of current downloads: %d", countOfDownLoads];

        [arrFileDownloadData addObject:[[TDwnLDownloader alloc] initWithFileTitle:@"Downloading file" andDownloadSource:@"https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/NetworkingOverview.pdf"]];
        [tblFiles reloadData];
        
        if (countOfDownLoads == 100)
            [self stopAllDownloads];
    }
}



-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
    }
    else{
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        TDwnLDownloader *dwn = [self.arrFileDownloadData objectAtIndex:index];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            dwn.downloadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
            
            UITableViewCell *cell = [self.tblFiles cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:CellProgressBarTagValue];
            progressView.progress = dwn.downloadProgress;
        }];
    }
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        if ([downloadTasks count] == 0) {
            if (appDelegate.backgroundTransferCompletionHandler != nil) {
                void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;

                appDelegate.backgroundTransferCompletionHandler = nil;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     completionHandler();
                    
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"All files have been downloaded!";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                }];
            }
        }
    }];
}

- (void)stopAllDownloads
{
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        TDwnLDownloader *fdi = [self.arrFileDownloadData objectAtIndex:i];
        
        if (fdi.isDownloading) {
            [fdi.downloadTask cancel];
            
            fdi.isDownloading = NO;
            fdi.taskIdentifier = -1;
            fdi.downloadProgress = 0.0;
            fdi.downloadTask = nil;
        }
    }
    
    [self.tblFiles reloadData];
}

@end


