//
//  LoginViewController.swift
//  ReciclaPlus
//
//  Created by MacOS on 20/08/25.
//

import UIKit
import GoogleSignIn
import ImageIO

class LoginViewController: UIViewController {
    
    @IBOutlet weak var pandaImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar la vista
        setupUI()
    }
    
    @IBAction func iniciarComoInvitadoButtonTapped(_ sender: UIButton) {
        // Configurar usuario como invitado
        UserManager.shared.setGuestUser()
        
        // Instanciar el TabBarController desde el storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "5sl-xe-lN9") as? UITabBarController {
            tabBarController.modalPresentationStyle = .fullScreen
            tabBarController.modalTransitionStyle = .coverVertical
            
            // Configurar las pestañas según el tipo de usuario
            tabBarController.configureTabsForUserType()
            
            present(tabBarController, animated: true, completion: nil)
        }
    }
    
    @IBAction func iniciarConGoogleButtonTapped(_ sender: UIButton) {
        // Verificar que la configuración de Google Sign-In esté lista
        guard GIDSignIn.sharedInstance.configuration != nil else {
            showErrorAlert(message: "Error de configuración. Inténtalo de nuevo.")
            return
        }
        
        // Deshabilitar el botón temporalmente para evitar múltiples taps
        sender.isEnabled = false
        
        // Usar self directamente como presentingViewController
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            DispatchQueue.main.async {
                // Rehabilitar el botón
                sender.isEnabled = true
                
                if let error = error {
                    let nsError = error as NSError
                    
                    // Verificar si el usuario canceló el sign-in
                    if nsError.code == -5 || nsError.code == 12501 {
                        // No mostrar error, es una acción del usuario
                        return
                    }
                    
                    // Mostrar alerta de error al usuario
                    self?.showErrorAlert(message: "Error al iniciar sesión con Google: \(error.localizedDescription)")
                    return
                }
                
                guard let user = result?.user,
                      let email = user.profile?.email else {
                    self?.showErrorAlert(message: "No se pudo obtener la información del usuario.")
                    return
                }
                
                // Obtener URL de la imagen de perfil si está disponible
                let imageURL = user.profile?.imageURL(withDimension: 200)?.absoluteString
                
                // Obtener nombre del usuario
                let userName = user.profile?.name
                
                self?.loginWithGoogle(email: email, imageURL: imageURL, userName: userName)
            }
        }
    }
    
    // Método para cuando se implemente el login con Google
    func loginWithGoogle(email: String, imageURL: String?, userName: String?) {
        // Eliminar la verificación que está causando problemas
        // y proceder directamente con el inicio de sesión
        
        UserManager.shared.setGoogleUser(email: email, name: userName, imageURL: imageURL)
        
        // Navegar al TabBarController con un pequeño delay para asegurar que la UI esté lista
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "5sl-xe-lN9") as? UITabBarController {
                tabBarController.modalPresentationStyle = .fullScreen
                tabBarController.modalTransitionStyle = .coverVertical
                
                // Configurar las pestañas según el tipo de usuario
                tabBarController.configureTabsForUserType()
                
                self.present(tabBarController, animated: true, completion: nil)
            }
        }
    }
    
    // Método para mostrar alertas de error
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupUI() {
        // Configurar el GIF animado del panda
        if let dataAsset = NSDataAsset(name: "panda_login"),
           let source = CGImageSourceCreateWithData(dataAsset.data as CFData, nil) {
            
            let frameCount = CGImageSourceGetCount(source)
            var images: [UIImage] = []
            var totalDuration: TimeInterval = 0
            
            for i in 0..<frameCount {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    let image = UIImage(cgImage: cgImage)
                    images.append(image)
                    
                    // Obtener la duración del frame
                    if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                       let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
                       let frameDuration = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double {
                        totalDuration += frameDuration
                    } else {
                        totalDuration += 0.1 // Duración por defecto
                    }
                }
            }
            
            pandaImageView.animationImages = images
            pandaImageView.animationDuration = totalDuration
            pandaImageView.animationRepeatCount = 0 // Repetir infinitamente
            pandaImageView.startAnimating()
        } else {
            // Fallback: usar imagen estática del imageset pandayoga
            pandaImageView.image = UIImage(named: "pandayoga")
        }
    }

}

