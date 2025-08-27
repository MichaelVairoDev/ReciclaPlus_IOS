//
//  UserManager.swift
//  ReciclaPlus
//
//  Created by MacOS on 20/08/25.
//

import UIKit

class UserManager {
    static let shared = UserManager()
    
    private init() {
        // Cargar estado de sesión guardado
        loadUserSession()
    }
    
    // MARK: - User Properties
    private var isLoggedIn: Bool = false
    private var userEmail: String?
    private var userName: String?
    private var userImageURL: String?
    private var userImage: UIImage?
    
    // MARK: - Public Methods
    
    /// Configura el usuario como invitado
    func setGuestUser() {
        isLoggedIn = false
        userEmail = "invitado@reciclaplus.com"
        userImageURL = nil
        userImage = UIImage(named: "ic_placeholder_avatar_anonimo")
    }
    
    /// Configura el usuario logueado con Google
    func setGoogleUser(email: String, name: String? = nil, imageURL: String? = nil, image: UIImage? = nil) {
        isLoggedIn = true
        userEmail = email
        userName = name
        userImageURL = imageURL
        userImage = image ?? UIImage(named: "ic_placeholder_avatar")
        
        // Guardar estado de sesión
        saveUserSession()
        
        // Si hay URL de imagen, descargarla
        if let urlString = imageURL, let url = URL(string: urlString) {
            downloadUserImage(from: url)
        }
    }
    
    /// Cierra la sesión del usuario
    func logout() {
        isLoggedIn = false
        userEmail = nil
        userName = nil
        userImageURL = nil
        userImage = nil
        
        // Limpiar estado guardado
        clearUserSession()
        
        // Volver a configurar como usuario invitado
        setGuestUser()
    }
    
    // MARK: - Getters
    
    func getUserEmail() -> String {
        return userEmail ?? "invitado@reciclaplus.com"
    }
    
    func getUserImage() -> UIImage {
        // Primero intentar usar la imagen del usuario si existe
        if let userImg = userImage {
            return userImg
        }
        
        // Si no hay imagen del usuario, usar placeholder según el tipo de usuario
        let placeholderName = isLoggedIn ? "ic_placeholder_avatar" : "ic_placeholder_avatar_anonimo"
        if let placeholderImg = UIImage(named: placeholderName) {
            return placeholderImg
        }
        
        // Como último recurso, crear una imagen de color sólido
        let size = CGSize(width: 36, height: 36)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.systemGray4.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let fallbackImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return fallbackImage
    }
    
    func getIsLoggedIn() -> Bool {
        return isLoggedIn
    }
    
    func getUserImageURL() -> String? {
        return userImageURL
    }
    
    func getUserName() -> String {
        return userName ?? "Invitado"
    }
    
    // MARK: - Avatar Configuration
    
    /// Configura un UIImageView con la imagen del usuario actual
    func configureAvatarImageView(_ imageView: UIImageView) {
        imageView.image = getUserImage()
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    
    /// Crea y configura un botón de avatar redondeado para la barra de navegación
    func createAvatarBarButtonItem(target: Any?, action: Selector) -> UIBarButtonItem {
        // Crear un contenedor view para el botón
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        containerView.backgroundColor = UIColor.clear
        
        // Crear un UIImageView en lugar de un botón para mejor control de la imagen
        let avatarImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        
        // Obtener la imagen y asegurar que se cargue
        let userImg = getUserImage()
        avatarImageView.image = userImg
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        
        // Hacer la imagen redonda
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.systemGray4.cgColor
        avatarImageView.layer.masksToBounds = true
        
        // Crear un botón invisible para manejar los toques
        let tapButton = UIButton(type: .custom)
        tapButton.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        tapButton.backgroundColor = UIColor.clear
        tapButton.addTarget(target, action: action, for: .touchUpInside)
        
        // Agregar ambos al contenedor
        containerView.addSubview(avatarImageView)
        containerView.addSubview(tapButton)
        
        // Crear el bar button item
        let barButtonItem = UIBarButtonItem(customView: containerView)
        
        return barButtonItem
    }
    
    /// Actualiza la imagen de un avatar específico en la barra de navegación
    func updateAvatarBarButtonItem(_ barButtonItem: UIBarButtonItem) {
        if let containerView = barButtonItem.customView,
           let avatarImageView = containerView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            avatarImageView.image = getUserImage()
        }
    }
    
    /// Actualiza todos los avatares en las vistas del TabBar
    func updateAllAvatars() {
        // Esta función se puede llamar cuando el usuario cambie su imagen
        NotificationCenter.default.post(name: NSNotification.Name("UserAvatarUpdated"), object: nil)
    }
    
    /// Descarga la imagen de perfil del usuario desde una URL
    private func downloadUserImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.userImage = image
                self?.updateAllAvatars()
            }
        }.resume()
    }
    
    // MARK: - Session Persistence
    
    /// Guarda el estado de sesión en UserDefaults
    private func saveUserSession() {
        UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userImageURL, forKey: "userImageURL")
        UserDefaults.standard.synchronize()
    }
    
    /// Carga el estado de sesión desde UserDefaults
    private func loadUserSession() {
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        if isLoggedIn {
            userEmail = UserDefaults.standard.string(forKey: "userEmail")
            userName = UserDefaults.standard.string(forKey: "userName")
            userImageURL = UserDefaults.standard.string(forKey: "userImageURL")
            userImage = UIImage(named: "ic_placeholder_avatar")
            
            // Si hay URL de imagen, descargarla
            if let urlString = userImageURL, let url = URL(string: urlString) {
                downloadUserImage(from: url)
            }
        } else {
            setGuestUser()
        }
    }
    
    /// Limpia el estado de sesión guardado
    private func clearUserSession() {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userImageURL")
        UserDefaults.standard.synchronize()
    }
}