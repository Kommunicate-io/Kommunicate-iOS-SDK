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
        KMCustomEventHandler.shared.publish(triggeredEvent: CustomEvent.faqClick, data: ["faqUrl": url])
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
        webView.configuration.userContentController.addUserScript(self.getZoomDisableScript())
        view = webView
    }
    

    private func getZoomDisableScript() -> WKUserScript {
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: url))
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = getBackArrowButton(target: self, action: #selector(backTapped))
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
