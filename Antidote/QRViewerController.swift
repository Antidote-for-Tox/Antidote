//
//  QRViewerController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 13/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

protocol QRViewerControllerDelegate: class {
    func qrViewerControllerDidFinishPresenting()
}

class QRViewerController: UIViewController {
    weak var delegate: QRViewerControllerDelegate?

    private let theme: Theme
    private let text: String

    private var previousBrightness: CGFloat = 1.0

    private var closeButton: UIButton!
    private var imageView: UIImageView!

    init(theme: Theme, text: String) {
        self.theme = theme
        self.text = text

        super.init(nibName: nil, bundle: nil)

        edgesForExtendedLayout = .None
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        installNavigationItems()
        createViews()
        installConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        previousBrightness = UIScreen.mainScreen().brightness
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        UIScreen.mainScreen().brightness = previousBrightness
    }
}

extension QRViewerController {
    func closeButtonPressed() {
        delegate?.qrViewerControllerDidFinishPresenting()
    }
}

private extension QRViewerController {
    func installNavigationItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .Done,
                target: self,
                action: #selector(QRViewerController.closeButtonPressed))
    }

    func createViews() {
        imageView = UIImageView(image: qrImageFromText())
        imageView.contentMode = .ScaleAspectFit
        view.addSubview(imageView)
    }

    func installConstraints() {
        imageView.snp_makeConstraints {
            $0.center.equalTo(view)
            $0.width.lessThanOrEqualTo(view.snp_width)
            $0.width.lessThanOrEqualTo(view.snp_height)
            $0.width.equalTo(imageView.snp_height)
        }
    }

    func qrImageFromText() -> UIImage {
        let filter = CIFilter(name:"CIQRCodeGenerator")!
        filter.setDefaults()
        filter.setValue(text.dataUsingEncoding(NSUTF8StringEncoding), forKey: "inputMessage")

        let ciImage = filter.outputImage!
        let screenBounds = UIScreen.mainScreen().bounds

        let scale = min(screenBounds.size.width / ciImage.extent.size.width, screenBounds.size.height / ciImage.extent.size.height)
        let transformedImage = ciImage.imageByApplyingTransform(CGAffineTransformMakeScale(scale, scale))

        return UIImage(CIImage: transformedImage)
    }
}
