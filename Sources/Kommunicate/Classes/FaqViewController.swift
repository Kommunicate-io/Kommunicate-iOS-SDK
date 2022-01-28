//
//  FaqViewController.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 07/05/19.
//

import KommunicateChatUI_iOS_SDK
import WebKit

public class FaqViewController: UIViewController, Localizable {
    var webView: WKWebView = .init()
    let url: URL
    let configuration: ALKConfiguration

    public init(url: URL, configuration: ALKConfiguration) {
        self.url = url
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        KMCustomEventHandler.shared.publish(triggeredEvent: CustomEvent.faqClick, data: ["UserSelection": ["FaqUrl": url]])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        view = webView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: url))
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var backImage = UIImage(named: "icon_back", in: Bundle.kommunicate, compatibleWith: nil)
        backImage = backImage?.imageFlippedForRightToLeftLayoutDirection()
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backTapped))
        backButton.accessibilityIdentifier = "BackButton"
        navigationItem.leftBarButtonItem = backButton
        navigationItem.title = localizedString(forKey: "FaqTitle", fileName: configuration.localizedStringFileName)
    }

    @objc func backTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension FaqViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard navigationAction.navigationType == .linkActivated else {
            decisionHandler(.allow)
            return
        }
        webView.load(navigationAction.request)
        decisionHandler(.cancel)
    }
}
