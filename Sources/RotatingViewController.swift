//
//  RotatingViewController.swift
//  Browser
//
//  Created by Simon Whitty on 4/4/19.
//  Copyright © 2019 Simon Whitty. All rights reserved.
//

import UIKit

final class RotatingViewController<T: UIViewController>: UIViewController {

    var child: T {
        didSet { childDidChange(from: oldValue) }
    }

    init(_ child: T) {
        self.child = child
        super.init(nibName: nil, bundle: nil)

        addChild(child)
        child.didMove(toParent: self)
    }

    var childOrientation: UIInterfaceOrientation = .portrait {
        didSet { childOrientationDidChange(from: oldValue) }
    }

    func setChildOrientation(_ orientation: UIInterfaceOrientation, animated: Bool) {
        guard isViewLoaded else {
            childOrientation = orientation
            return
        }

        UIView.animate(withDuration: animated ? 0.2 : 0,
                       delay: 0,
                       options: [.beginFromCurrentState, .curveEaseInOut],
                       animations: {
                        self.childOrientation = orientation
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(child.view)
        child.view.frame = view.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childOrientationDidChange(from: nil)
    }

    private func childDidChange(from previous: T?) {
        guard child != previous else { return }

        previous.map {
            $0.willMove(toParent: nil)
            $0.viewIfLoaded?.removeFromSuperview()
            $0.removeFromParent()
        }

        addChild(child)
        if let view = viewIfLoaded {
            view.addSubview(child.view)
            child.view.frame = view.bounds
            child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            childOrientationDidChange(from: nil)
            let fade = CATransition()
            fade.type = .fade
            fade.duration = 0.2
            view.layer.add(fade, forKey: "fade")
        }
        child.didMove(toParent: self)
    }

    private func childOrientationDidChange(from previous: UIInterfaceOrientation?) {
        guard childOrientation != previous else { return }

        child.view.transform = childOrientation.transform
        child.view.frame = view.bounds
    }
}

private extension UIInterfaceOrientation {

    var transform: CGAffineTransform {
        switch self {
        case .portrait:
            return .identity
        case .landscapeLeft:
            return CGAffineTransform(rotationDegrees: 90)
        case .portraitUpsideDown:
            return CGAffineTransform(rotationDegrees: 180)
        case .landscapeRight, .unknown:
            return CGAffineTransform(rotationDegrees: 270)
        @unknown default:
            return .identity
        }
    }
}

private extension CGAffineTransform {
    init(rotationDegrees degrees: CGFloat) {
        self.init(rotationAngle: degrees * CGFloat.pi / 180.0)
    }
}
