//
//  KMHomeFaqViewController.swift
//  Kommunicate
//

import KommunicateCore_iOS_SDK
import UIKit

/// Hosts the help center (`FaqViewController`) inside the FAQ tab.
final class KMHomeFaqViewController: KMHomeBaseViewController {
    private var faqViewController: FaqViewController?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Created lazily, as `FaqViewController` publishes the FAQ click event when initialised.
        guard faqViewController == nil,
              let url = URLBuilder.faqURL(for: KMCoreUserDefaultsHandler.getApplicationKey(), hideChat: configuration.hideChatInHelpcenter).url
        else { return }
        let faqVC = FaqViewController(url: url, configuration: configuration)
        faqViewController = faqVC
        addChild(faqVC)
        faqVC.view.frame = view.bounds
        faqVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(faqVC.view)
        faqVC.didMove(toParent: self)
    }

    /// Goes back through the help center pages first, then closes the home screen.
    override func backTapped() {
        if let webView = faqViewController?.webView, webView.canGoBack {
            webView.goBack()
        } else {
            super.backTapped()
        }
    }
}
