//
//  QRScannerController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 11.12.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "QRScannerController.h"
#import "UIViewController+Utilities.h"
#import "AppearanceManager.h"

@interface QRScannerController () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) NSMutableArray *codeObjects;

@property (copy, nonatomic) QRScannerControllerSuccessBlock successBlock;
@property (copy, nonatomic) QRScannerControllerCancelBlock cancelBlock;

@end

@implementation QRScannerController

#pragma mark -  Lifecycle

- (instancetype)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];

    if (self) {
        [self createCaptureSession];
        [self createBarButtonItems];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [self loadWhiteView];
    [self createLayers];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.previewLayer.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.captureSession startRunning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.captureSession stopRunning];
}

#pragma mark -  Properties

- (void)setPauseScanning:(BOOL)pause
{
    _pauseScanning = pause;

    if (pause) {
        [self.captureSession stopRunning];
    }
    else {
        [self.captureSession startRunning];
    }
}

#pragma mark -  Actions

- (void)cancelButtonPressed
{
    if (self.cancelBlock) {
        self.cancelBlock(self);
    }
}

#pragma mark -  Public

+ (UINavigationController *)navigationWithScannerControllerWithSuccess:(QRScannerControllerSuccessBlock)success
                                                           cancelBlock:(QRScannerControllerCancelBlock)cancel
{
    QRScannerController *sc = [QRScannerController new];
    sc.successBlock = success;
    sc.cancelBlock = cancel;

    return [[UINavigationController alloc] initWithRootViewController:sc];
}

#pragma mark -  Notificatoins

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self.captureSession stopRunning];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    if (! self.pauseScanning) {
        [self.captureSession startRunning];
    }
}

#pragma mark -  AVCaptureMetadataOutputObjectsDelegate

- (void)    captureOutput:(AVCaptureOutput *)captureOutput
 didOutputMetadataObjects:(NSArray *)metadataObjects
           fromConnection:(AVCaptureConnection *)connection
{
    if (! self.successBlock) {
        return;
    }

    NSMutableArray *stringValues = [NSMutableArray new];

    for (AVMetadataObject *object in metadataObjects) {
        if ([object isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)object;

            [stringValues addObject:readableObject.stringValue];
        }
    }

    self.successBlock(self, [stringValues copy]);
}

#pragma mark -  Private

- (void)createCaptureSession
{
    self.captureSession = [AVCaptureSession new];

    AVCaptureDeviceInput *input = [self captureSessionInput];
    AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];

    if (input && [self.captureSession canAddInput:input]) {
        [self.captureSession addInput:input];
    }

    if ([self.captureSession canAddOutput:output]) {
        [self.captureSession addOutput:output];

        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

        if ([[output availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode]) {
            output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        }
    }
}

- (void)createBarButtonItems
{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton.titleLabel setTextColor:[UIColor yellowColor]];
    [cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    [cancelButton setTitleColor:[AppearanceManager textMainColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
}

- (AVCaptureDeviceInput *)captureSessionInput
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    if (device.isAutoFocusRangeRestrictionSupported && [device lockForConfiguration:nil]) {
        device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;

        [device unlockForConfiguration];
    }

    return [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
}

- (void)createLayers
{
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
}

@end
