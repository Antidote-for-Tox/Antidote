// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

protocol QRViewerControllerDelegate: class {
    func qrViewerControllerDidFinishPresenting()
}

class QRViewerController: UIViewController {
    weak var delegate: QRViewerControllerDelegate?

    fileprivate let theme: Theme
    fileprivate let text: String

    fileprivate var previousBrightness: CGFloat = 1.0

    fileprivate var closeButton: UIButton!
    fileprivate var imageView: UIImageView!

    init(theme: Theme, text: String) {
        self.theme = theme
        self.text = text

        super.init(nibName: nil, bundle: nil)

        edgesForExtendedLayout = UIRectEdge()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        previousBrightness = UIScreen.main.brightness
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIScreen.main.brightness = previousBrightness
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
                barButtonSystemItem: .done,
                target: self,
                action: #selector(QRViewerController.closeButtonPressed))
    }

    func createViews() {
        imageView = UIImageView(image: qrImageFromText())
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
    }

    func installConstraints() {
        imageView.snp.makeConstraints {
            $0.center.equalTo(view)
            $0.width.lessThanOrEqualTo(view.snp.width)
            $0.width.lessThanOrEqualTo(view.snp.height)
            $0.width.equalTo(imageView.snp.height)
        }
    }

    func qrImageFromText() -> UIImage {
        let filter = CIFilter(name:"CIQRCodeGenerator")!
        filter.setDefaults()
        filter.setValue(text.data(using: String.Encoding.utf8), forKey: "inputMessage")

        let ciImage = filter.outputImage!
        let screenBounds = UIScreen.main.bounds

        let scale = min(screenBounds.size.width / ciImage.extent.size.width, screenBounds.size.height / ciImage.extent.size.height)
        let transformedImage = ciImage.applying(CGAffineTransform(scaleX: scale, y: scale))

        return UIImage(ciImage: transformedImage)
    }
}
