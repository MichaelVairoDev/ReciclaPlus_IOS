//
//  SceneDelegate.swift
//  ReciclaPlus
//
//  Created by MacOS on 20/08/25.
//

import UIKit
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be configured and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Configurar navegación inicial basada en estado de sesión
        setupInitialNavigation(windowScene: windowScene)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
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
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        GIDSignIn.sharedInstance.handle(url)
    }
    
    // MARK: - Navigation Setup
    
    private func setupInitialNavigation(windowScene: UIWindowScene) {
        window = UIWindow(windowScene: windowScene)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Verificar si el usuario tiene sesión activa de Google
        if UserManager.shared.getIsLoggedIn() {
            // Usuario logueado con Google - ir directamente al TabBar (Home)
            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "5sl-xe-lN9") as? UITabBarController {
                window?.rootViewController = tabBarController
            }
        } else {
            // Usuario no logueado o invitado - mostrar onboarding
            if let onboardingController = storyboard.instantiateViewController(withIdentifier: "Y5W-Mt-CQB") as? OnboardingViewController {
                window?.rootViewController = onboardingController
            }
        }
        
        window?.makeKeyAndVisible()
    }

}

