//
//  ViewController.swift
//  Browser
//
//  Created by Simon Whitty on 3/4/19.
//  Copyright © 2019 Simon Whitty. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    lazy var webViewController: WebViewController = {
        let vc = WebViewController()
        addChild(vc)
        vc.didMove(toParent: self)
        return vc
    }()

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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webViewController.view)
        webViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webViewController.loadURL(URL(string: "https://www.google.com")!)

        updateAirplay()
        toolbarItems = [btnRotate, .flexibleSpace, btnSync]

        navigationItem.rightBarButtonItem = btnAddress

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

        guard let url = webViewController.url else { return }

        if let other = self.other {
            other.root.child.loadURL(url)
        } else {
            let other = BrowserWindow(screen: otherScreen)
            other.root.child.loadURL(url)
            self.other = other
        }
    }

    func browse(to text: String?) {
        guard let text = text else { return }

        if (text.hasPrefix("http://") || text.hasPrefix("https://")), let url = URL(string: text) {
            webViewController.loadURL(url)
        } else if let url = URL(string: "http://\(text)") {
            webViewController.loadURL(url)
        }
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
