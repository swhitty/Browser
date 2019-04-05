//
//  ViewController.swift
//  Browser
//
//  Created by Simon Whitty on 3/4/19.
//  Copyright © 2019 Simon Whitty. All rights reserved.
//

import UIKit
import WebKit

final class ViewController: UIViewController {

    var webViewController: WebViewController {
        didSet { webViewControllerDidChange(from: oldValue) }
    }

    init() {
        self.webViewController = WebViewController()
        super.init(nibName: nil, bundle: nil)
        webViewControllerDidChange(from: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var btnRotate = UIBarButtonItem(barButtonSystemItem: .refresh,
                                       target: self,
                                       action: #selector(rotate))

    lazy var btnSync = UIBarButtonItem(image: UIImage(named: "airplay"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(sync))

    lazy var btnAddress = UIBarButtonItem(title: "URL",
                                          style: .plain,
                                          target: self,
                                          action: #selector(inputURL))

    lazy var btnRefresh = UIBarButtonItem(title: "Refresh",
                                          style: .plain,
                                          target: self,
                                          action: #selector(refresh))

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webViewController.view)
        webViewController.view.transform = .identity
        webViewController.view.frame = view.bounds
        webViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webViewController.loadURL(URL(string: "https://www.google.com")!)

        updateAirplay()
        toolbarItems = [btnRotate, .flexibleSpace, btnSync]

        navigationItem.rightBarButtonItem = btnAddress
        navigationItem.leftBarButtonItem = btnRefresh

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateAirplay),
                                               name: UIScreen.didConnectNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateAirplay),
                                               name: UIScreen.didDisconnectNotification,
                                               object: nil)
    }

    @objc
    func refresh() {
        webViewController.url.map {
            webViewController.loadURL($0)
        }
    }
    @objc
    func inputURL() {
        let alert = UIAlertController(title: nil, message: "Enter URL", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .URL
        }

        let goAction: UIAlertAction = UIAlertAction(title: "Go", style: .default) { _ in
            self.browse(to: alert.textFields?.first?.text)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(goAction)

        present(alert, animated: true)
    }

    @objc
    func rotate() {
        guard let rotating = self.other?.root else { return }
        let newOrientation = rotating.childOrientation.rotate()
        rotating.setChildOrientation(newOrientation, animated: true)
    }

    @objc
    private func updateAirplay() {
        if UIScreen.otherScreen == nil {
            btnSync.isEnabled = false
            other = nil
        } else {
            btnSync.isEnabled = true
            btnRotate.isEnabled = other != nil
        }
    }

    var other: BrowserWindow? {
        didSet { btnRotate.isEnabled = other != nil }
    }

    @objc
    func sync() {
        guard let otherScreen = UIScreen.otherScreen else {
            other = nil
            return
        }

        if let other = self.other {
            let otherWebViewController = other.root.child
            let thisWebViewController = webViewController
            let tmpWebViewController = WebViewController()
            webViewController = tmpWebViewController
            other.root.child = thisWebViewController
            webViewController = otherWebViewController
        } else {
            let thisWebViewController = webViewController
            webViewController = WebViewController()
            let other = BrowserWindow(screen: otherScreen)
            other.root.child = thisWebViewController
            self.other = other
        }
    }

    func browse(to text: String?) {
        guard let text = text else { return }

        if (text.hasPrefix("http://") || text.hasPrefix("https://")), let url = URL(string: text) {
            webViewController.loadURL(url)
        } else if let url = URL(string: "https://\(text)") {
            webViewController.loadURL(url)
        }
    }

    private func webViewControllerDidChange(from previous: WebViewController?) {
        guard webViewController != previous else { return }

        previous.map {
            $0.willMove(toParent: nil)
            $0.viewIfLoaded?.removeFromSuperview()
            $0.removeFromParent()
        }

        addChild(webViewController)
        if let view = viewIfLoaded {
            view.addSubview(webViewController.view)
            webViewController.view.transform = .identity
            webViewController.view.frame = view.bounds
            webViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            let fade = CATransition()
            fade.type = .fade
            fade.duration = 0.2
            view.layer.add(fade, forKey: "fade")
        }
        webViewController.didMove(toParent: self)
    }
}

final class BrowserWindow {

    let window: UIWindow
    let root: RotatingViewController<WebViewController>

    init(screen: UIScreen) {
        root = RotatingViewController(WebViewController())
        window = UIWindow(frame: screen.bounds)
        window.screen = screen
        window.rootViewController = root
        window.makeKeyAndVisible()
    }
}

private extension UIBarButtonItem {

    static var flexibleSpace: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
}

private extension UIScreen {

    static var otherScreen: UIScreen? {
        return UIScreen.screens.first { $0 !== UIScreen.main }
    }
}

private extension UIInterfaceOrientation {

    func rotate() -> UIInterfaceOrientation  {
        switch self {
        case .portrait:
            return .landscapeLeft
        case .landscapeLeft:
            return .portraitUpsideDown
        case .portraitUpsideDown:
            return .landscapeRight
        case .landscapeRight, .unknown:
            return .portrait
        @unknown default:
            return .portrait
        }
    }
}
