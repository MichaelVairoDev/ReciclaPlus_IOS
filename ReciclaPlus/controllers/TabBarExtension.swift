//
//  TabBarExtension.swift
//  ReciclaPlus
//
//  Created by MacOS on 20/08/25.
//

import UIKit

// MARK: - TabBarDelegate Helper Class
class TabBarDelegate: NSObject, UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Índice de la pestaña que el usuario está intentando seleccionar
        guard let index = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return true
        }
        
        // Índice de la pestaña de logros (es la cuarta pestaña, índice 3)
        let logrosTabIndex = 3
        
        // Si el usuario intenta acceder a la pestaña de logros y es invitado
        if index == logrosTabIndex && !UserManager.shared.getIsLoggedIn() {
            // Mostrar la vista de perfil para que pueda iniciar sesión
            showLoginProfile(from: tabBarController)
            return false // No permitir la selección de la pestaña
        }
        
        return true // Permitir la selección para otras pestañas o usuarios logueados
    }
    
    // Método para mostrar la vista de perfil
    private func showLoginProfile(from tabBarController: UITabBarController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewPerfil = storyboard.instantiateViewController(withIdentifier: "YID-Ks-zeR") as? PerfilViewController {
            viewPerfil.modalPresentationStyle = .pageSheet
            viewPerfil.modalTransitionStyle = .coverVertical
            tabBarController.present(viewPerfil, animated: true, completion: nil)
        }
    }
}

extension UITabBarController {
    
    private static var tabBarDelegateKey: UInt8 = 0
    
    private var tabBarDelegate: TabBarDelegate? {
        get {
            return objc_getAssociatedObject(self, &UITabBarController.tabBarDelegateKey) as? TabBarDelegate
        }
        set {
            objc_setAssociatedObject(self, &UITabBarController.tabBarDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // Configurar las pestañas según el tipo de usuario (invitado o con cuenta de Google)
    func configureTabsForUserType() {
        // Verificar si el usuario está logueado con Google
        let isLoggedIn = UserManager.shared.getIsLoggedIn()
        
        // Índice de la pestaña de logros (es la cuarta pestaña, índice 3)
        let logrosTabIndex = 3
        
        // Si hay viewControllers configurados
        if let viewControllers = self.viewControllers {
            // Si el usuario es invitado, configurar el delegado para interceptar los toques en la pestaña de logros
            if !isLoggedIn && viewControllers.count > logrosTabIndex {
                // Crear y configurar el delegado personalizado
                let customDelegate = TabBarDelegate()
                self.tabBarDelegate = customDelegate
                self.delegate = customDelegate
            }
        }
    }
}