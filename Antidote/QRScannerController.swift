// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import AVFoundation

class QRScannerController: UIViewController {
    var didScanStringsBlock: (([String]) -> Void)?
    var cancelBlock: (() -> Void)?

    fileprivate let theme: Theme

    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    fileprivate var captureSession: AVCaptureSession!

    fileprivate var aimView: QRScannerAimView!

    var pauseScanning: Bool = false {
        didSet {
            pauseScanning ? captureSession.stopRunning() : captureSession.startRunning()

            if !pauseScanning {
                aimView.frame = CGRect.zero
            }
        }
    }

    init(theme: Theme) {
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        createCaptureSession()
        createBarButtonItems()

        NotificationCenter.default.addObserver(
                self,
                selector: #selector(QRScannerController.applicationDidEnterBackground),
                name: NSNotification.Name.UIApplicationDidEnterBackground,
                object: nil)

        NotificationCenter.default.addObserver(
                self,
                selector: #selector(QRScannerController.applicationWillEnterForeground),
                name: NSNotification.Name.UIApplicationWillEnterForeground,
                object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createViewsAndLayers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        captureSession.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
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
    @objc func cancelButtonPressed() {
        cancelBlock?()
    }
}

// MARK: Notifications
extension QRScannerController {
    @objc func applicationDidEnterBackground() {
        captureSession.stopRunning()
    }

    @objc func applicationWillEnterForeground() {
        if !pauseScanning {
            captureSession.startRunning()
        }
    }
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        let readableObjects = metadataObjects.filter {
            $0 is AVMetadataMachineReadableCodeObject
        }.map {
            previewLayer.transformedMetadataObject(for: $0 ) as! AVMetadataMachineReadableCodeObject
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

        if (input != nil) && captureSession.canAddInput(input!) {
            captureSession.addInput(input!)
        }

        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)

            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

            if output.availableMetadataObjectTypes.contains({ AVMetadataObject.ObjectType.qr }()) {
                output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            }
        }
    }

    func captureSessionInput() -> AVCaptureDeviceInput? {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return nil
        }

        if device.isAutoFocusRangeRestrictionSupported {
            do {
                try device.lockForConfiguration()
                device.autoFocusRangeRestriction = .near
                device.unlockForConfiguration()
            }
            catch {
                // nop
            }
        }

        return try? AVCaptureDeviceInput(device: device)
    }

    func createBarButtonItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(QRScannerController.cancelButtonPressed))
    }

    func createViewsAndLayers() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)

        aimView = QRScannerAimView(theme: theme)
        view.addSubview(aimView)
        view.bringSubview(toFront: aimView)
    }
}
