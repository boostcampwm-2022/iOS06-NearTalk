//
//  SceneDelegate.swift
//  MyNetfilx
//
//  Created by lymchgmk on 2022/10/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        window?.rootViewController = navigationController
        
        appCoordinator = AppCoordinator(navigationController: navigationController)
        appCoordinator?.start()

        window?.makeKeyAndVisible()
        window?.initTheme()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}

extension UIWindow {
    func initTheme() {
        if let themeRawValue = UserDefaults.standard.string(forKey: AppTheme.keyName),
           let theme = AppTheme(rawValue: themeRawValue) {
            self.applyTheme(theme: theme)
        } else {
            self.applyTheme(theme: .system)
        }
        
    }
    
    func applyTheme(theme: AppTheme) {
        switch theme {
        case .system:
            self.overrideUserInterfaceStyle = .unspecified
        case .dark:
            self.overrideUserInterfaceStyle = .dark
        case .light:
            self.overrideUserInterfaceStyle = .light
        }
    }
}
