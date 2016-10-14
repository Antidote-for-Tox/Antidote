// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import WebKit
import SnapKit

private struct Constants {
    static let FAQURL = "https://github.com/Antidote-for-Tox/Antidote/blob/master/FAQ/en.md"
}

class FAQController: UIViewController {
    private let theme: Theme

    private var webView: WKWebView!
    private var spinner: UIActivityIndicatorView!

    init(theme: Theme) {
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
        title = String(localized: "settings_faq")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createViews()
        installConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = NSURLRequest(URL: NSURL(string: Constants.FAQURL)!)
        webView.loadRequest(request)
    }
}

extension FAQController: WKNavigationDelegate {
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        spinner.startAnimating()
    }

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        spinner.stopAnimating()
    }
}

private extension FAQController {
    func createViews() {
        let configuration = WKWebViewConfiguration()

        webView = WKWebView(frame: CGRectZero, configuration: configuration)
        webView.navigationDelegate = self
        view.addSubview(webView)

        spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
    }

    func installConstraints() {
        webView.snp_makeConstraints {
            $0.edges.equalTo(view)
        }

        spinner.snp_makeConstraints {
            $0.center.equalTo(view)
        }
    }
}
