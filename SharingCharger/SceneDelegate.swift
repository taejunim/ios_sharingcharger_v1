//
//  SceneDelegate.swift
//  SharingCharger
//
//  Created by tjlim on 2020/07/27.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let mode: String = "Login"
    //let mode: String = "Main"

    //추후 로그인 API 연동후 로그인 정보가 있으면 "메인" 화면으로 이동, 로그인 정보가 없으면 "로그인" 화면으로 이동하게 처리
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        //guard let _ = (scene as? UIWindowScene) else { return }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }

        self.window = UIWindow(windowScene: windowScene)
        self.window!.overrideUserInterfaceStyle = UIUserInterfaceStyle.light;   //다크모드 지원 안함
        
        var storyboard: UIStoryboard?
        var rootViewController: UIViewController?
        
        if mode == "Login" {
        
            storyboard = UIStoryboard(name: "Login", bundle: nil)
            rootViewController = storyboard?.instantiateViewController(identifier: "Login") as? LoginViewController
            
        } else if mode == "Main" {
            
            storyboard = UIStoryboard(name: "Main", bundle: nil)
            rootViewController = storyboard?.instantiateViewController(identifier: "Main") as? MainViewController
        }
        
        let rootNavigationController = UINavigationController(rootViewController: rootViewController!)
        
        self.window?.rootViewController = rootNavigationController
        self.window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

