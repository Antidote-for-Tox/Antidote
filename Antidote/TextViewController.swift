//
//  TextViewController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 26/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let Offset = 10.0
    static let TitleColorKey = "TITLE_COLOR"
    static let TextColorKey = "TEXT_COLOR"
}

class TextViewController: UIViewController {
    private let resourceName: String
    private let backgroundColor: UIColor
    private let titleColor: UIColor
    private let textColor: UIColor

    private var textView: UITextView!

    init(resourceName: String, backgroundColor: UIColor, titleColor: UIColor, textColor: UIColor) {
        self.resourceName = resourceName
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.textColor = textColor

        super.init(nibName: nil, bundle: nil)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(backgroundColor)

        createTextView()
        installConstraints()

        loadHtml()
    }
}

private extension TextViewController {
    func createTextView() {
        textView = UITextView()
        textView.editable = false
        textView.backgroundColor = .clearColor()
        view.addSubview(textView)
    }

    func installConstraints() {
        textView.snp_makeConstraints {
            $0.leading.top.equalTo(view).offset(Constants.Offset)
            $0.trailing.bottom.equalTo(view).offset(-Constants.Offset)
        }
    }

    func loadHtml() {
        do {
            struct FakeError: ErrorType {}
            guard let htmlFilePath = NSBundle.mainBundle().pathForResource(resourceName, ofType: "html") else {
                throw FakeError()
            }

            var htmlString = try NSString(contentsOfFile: htmlFilePath, encoding: NSUTF8StringEncoding)
            htmlString = htmlString.stringByReplacingOccurrencesOfString(Constants.TitleColorKey, withString: titleColor.hexString())
            htmlString = htmlString.stringByReplacingOccurrencesOfString(Constants.TextColorKey, withString: textColor.hexString())

            guard let data = htmlString.dataUsingEncoding(NSUnicodeStringEncoding) else {
                throw FakeError()
            }
            let options = [ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType ]

            try textView.attributedText = NSAttributedString(data: data, options: options, documentAttributes: nil)
        }
        catch {
            handleErrorWithType(.CannotLoadHTML)
        }
    }
}
