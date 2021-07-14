//
//  SceneDelegate.swift
//  Focus
//
//  Created by donghyun on 2021/05/30.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        print("will connect to session")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("scene did disconnect")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("scene did become active")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("scene will resign active")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("scene will enter foreground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("scene did enter background")
    }
}

