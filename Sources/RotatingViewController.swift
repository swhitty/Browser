//
//  RotatingViewController.swift
//  Browser
//
//  Created by Simon Whitty on 4/4/19.
//  Copyright © 2019 Simon Whitty. All rights reserved.
//

import UIKit

final class RotatingViewController<T: UIViewController>: UIViewController {

    let child: T

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
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childOrientationDidChange(from: nil)
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
