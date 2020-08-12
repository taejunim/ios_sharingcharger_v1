//
//  ScreenAnimation.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/11.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class ScreenAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let container = transitionContext.containerView
        
        toViewController.view.alpha = 0.0
        container.addSubview(toViewController.view)
        
        UIView.animate(withDuration: 0.5, animations: {
            toViewController.view.alpha = 1.0
        }) { (isFinish) in
            fromViewController.view.removeFromSuperview()
            transitionContext.completeTransition(isFinish)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
}
