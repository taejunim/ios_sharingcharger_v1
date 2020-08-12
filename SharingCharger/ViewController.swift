//
//  ViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/07/27.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
//    @IBAction func goJoinViewController(_ sender: UIButton) {
////        if let joinScreen = self.storyboard?.instantiateViewController(withIdentifier: "Join"){
////
////            joinScreen.modalTransitionStyle = .coverVertical
////
////            self.present(joinScreen, animated: true, completion: nil)
////
////        }
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "Join") as! JoinViewController
//        //vc.dataReceived = joinButton.currentTitle
//        self.present(vc, animated: true, completion: nil)
//
//
//    }
//    @IBAction func presentJoin(_ sender: Any) {
//
//        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "Join") else {return}
//
//        self.present(nextVC, animated: true)
//    }
//    
//    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
//        viewControllerToPresent.modalPresentationStyle = .fullScreen
//        super.present(viewControllerToPresent, animated: flag, completion: completion)
//    }
//
    
    override func viewDidLayoutSubviews() {
        //loginEmail.borderStyle = .none
        
//        let frameY: CGFloat = loginEmail.frame.size.height-1
//        let frameWidth: CGFloat = loginEmail.frame.width
//
//        border1.frame = CGRect(x: 0, y: frameY, width: frameWidth, height: 1)
//        border2.frame = CGRect(x: 0, y: frameY, width: frameWidth, height: 1)
//        border1.backgroundColor = UIColor.test.cgColor
//        border2.backgroundColor = UIColor.placeholderText.cgColor
//        loginEmail.layer.addSublayer(border1)
//        loginPassword.layer.addSublayer(border2)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.isNavigationBarHidden = true

    }
}

extension ViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ScreenAnimation()
    }
}
