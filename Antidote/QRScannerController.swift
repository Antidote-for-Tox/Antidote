//
//  QRScannerController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 26/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerController: UIViewController {
    var didScanStringsBlock: ([String] -> Void)?
    var cancelBlock: (Void -> Void)?

    private let theme: Theme

    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var captureSession: AVCaptureSession!

    private var aimView: QRScannerAimView!

    var pauseScanning: Bool = false {
        didSet {
            pauseScanning ? captureSession.stopRunning() : captureSession.startRunning()

            if !pauseScanning {
                aimView.frame = CGRectZero
            }
        }
    }

    init(theme: Theme) {
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        createCaptureSession()
        createBarButtonItems()

        NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(QRScannerController.applicationDidEnterBackground),
                name: UIApplicationDidEnterBackgroundNotification,
                object: nil)

        NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(QRScannerController.applicationWillEnterForeground),
                name: UIApplicationWillEnterForegroundNotification,
                object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createViewsAndLayers()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        captureSession.startRunning()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        captureSession.stopRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        previewLayer.frame = view.bounds
    }
}

// MARK: Actions
extension QRScannerController {
    func cancelButtonPressed() {
        cancelBlock?()
    }
}

// MARK: Notifications
extension QRScannerController {
    func applicationDidEnterBackground() {
        captureSession.stopRunning()
    }

    func applicationWillEnterForeground() {
        if !pauseScanning {
            captureSession.startRunning()
        }
    }
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        let readableObjects = metadataObjects.filter {
            $0 is AVMetadataMachineReadableCodeObject
        }.map {
            previewLayer.transformedMetadataObjectForMetadataObject($0 as! AVMetadataObject) as! AVMetadataMachineReadableCodeObject
        }

        guard !readableObjects.isEmpty else {
            return
        }

        aimView.frame = readableObjects[0].bounds

        let strings = readableObjects.map {
            $0.stringValue!
        }

        didScanStringsBlock?(strings)
    }
}

private extension QRScannerController {
    func createCaptureSession() {
        captureSession = AVCaptureSession()

        let input = captureSessionInput()
        let output = AVCaptureMetadataOutput()

        if (input != nil) && captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)

            output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())

            if output.availableMetadataObjectTypes.contains({ $0 as! String == AVMetadataObjectTypeQRCode }) {
                output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            }
        }
    }

    func captureSessionInput() -> AVCaptureDeviceInput? {
        guard let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) else {
            return nil
        }

        if device.autoFocusRangeRestrictionSupported {
            do {
                try device.lockForConfiguration()
                device.autoFocusRangeRestriction = .Near
                device.unlockForConfiguration()
            }
            catch {
                // nop
            }
        }

        return try? AVCaptureDeviceInput(device: device)
    }

    func createBarButtonItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(QRScannerController.cancelButtonPressed))
    }

    func createViewsAndLayers() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)

        aimView = QRScannerAimView(theme: theme)
        view.addSubview(aimView)
        view.bringSubviewToFront(aimView)
    }
}
