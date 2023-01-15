//
//  SceneDelegate.swift
//  AnimatedVoiceBlob
//
//  Created by Konstantin Bezzemelnyi on 15.01.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else { return }

    self.window = UIWindow(frame: UIScreen.main.bounds) as UIWindow

    window?.windowScene = scene

    let rootController = ViewController(tintColor: .yellow)
    window?.makeKeyAndVisible()
    window?.rootViewController = rootController  }


}

