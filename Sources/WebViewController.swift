//
//  Browser.swift
//  Browser
//
//  Created by Simon Whitty on 4/4/19.
//  Copyright © 2019 Simon Whitty. All rights reserved.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {

    private lazy var webView = WKWebView(frame: UIScreen.main.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    var url: URL? {
        return webView.url
    }

    func loadURL(_ url: URL) {
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
}
