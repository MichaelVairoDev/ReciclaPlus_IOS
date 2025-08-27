//
//  PerfilViewController.swift
//  ReciclaPlus
//
//  Created by MacOS on 20/08/25.
//

import UIKit

class PerfilViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var greetingLabel: UILabel?
    
    // Label de saludo creado programáticamente
    private var programmaticGreetingLabel: UILabel!
    
    // Botón para ver envíos (solo para usuarios de Google)
    private var viewShipmentsButton: UIButton!
    
    // Overlay para mostrar lista de envíos
    private var overlayView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    private func setupGreetingLabel() {
        // Crear el label de saludo
        programmaticGreetingLabel = UILabel()
        programmaticGreetingLabel.textAlignment = .center
        programmaticGreetingLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        programmaticGreetingLabel.textColor = .label
        programmaticGreetingLabel.numberOfLines = 0
        programmaticGreetingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Agregar a la vista
        view.addSubview(programmaticGreetingLabel)
        
        // Configurar constraints para posicionarlo debajo del avatar
        NSLayoutConstraint.activate([
            programmaticGreetingLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            programmaticGreetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            programmaticGreetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            programmaticGreetingLabel.bottomAnchor.constraint(lessThanOrEqualTo: emailLabel.topAnchor, constant: -8)
        ])
    }
    
    private func setupUI() {
        // Configurar la imagen del avatar con esquinas redondeadas
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
        
        // Crear label de saludo programáticamente
        setupGreetingLabel()
        
        // Crear botón de ver envíos
        setupViewShipmentsButton()
        
        // Configurar el botón según el tipo de usuario
        setupButtonForUserType()
    }
    
    private func loadUserData() {
        // Usar UserManager para obtener los datos del usuario
        UserManager.shared.configureAvatarImageView(avatarImageView)
        
        // Configurar elementos según el tipo de usuario
        if UserManager.shared.getIsLoggedIn() {
            // Usuario logueado con Google - mostrar email y saludo
            emailLabel.text = UserManager.shared.getUserEmail()
            emailLabel.isHidden = false
            
            let userName = UserManager.shared.getUserName()
            programmaticGreetingLabel.text = "👋 ¡Hola, \(userName)!"
            programmaticGreetingLabel.isHidden = false
            
            // Mostrar botón de ver envíos
            viewShipmentsButton.isHidden = false
        } else {
            // Usuario invitado - ocultar email, saludo y botón de envíos
            emailLabel.isHidden = true
            programmaticGreetingLabel.isHidden = true
            viewShipmentsButton.isHidden = true
        }
    }
    
    private func setupButtonForUserType() {
        // Usar el botón tal como fue diseñado en el storyboard
        logoutButton.layer.cornerRadius = 8
        
        if UserManager.shared.getIsLoggedIn() {
            // Usuario logueado - mostrar botón de logout
            logoutButton.setTitle("Cerrar Sesión", for: .normal)
            logoutButton.backgroundColor = UIColor.systemRed
            logoutButton.setTitleColor(.white, for: .normal)
        } else {
            // Usuario invitado - mostrar botón para iniciar sesión
            logoutButton.setTitle("Iniciar Sesión", for: .normal)
            logoutButton.backgroundColor = UIColor.systemBlue
            logoutButton.setTitleColor(.white, for: .normal)
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        if UserManager.shared.getIsLoggedIn() {
            // Cerrar sesión usando UserManager
            UserManager.shared.logout()
            
            // Actualizar la interfaz
            loadUserData()
            setupButtonForUserType()
            
            // Regresar al login
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginViewController = storyboard.instantiateViewController(withIdentifier: "BYZ-38-t0r") as? LoginViewController {
                loginViewController.modalPresentationStyle = .fullScreen
                loginViewController.modalTransitionStyle = .coverVertical
                
                // Presentar el login desde la ventana principal
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = loginViewController
                    window.makeKeyAndVisible()
                }
            }
        } else {
            // Iniciar sesión con Google
            dismiss(animated: true) {
                // Regresar a la pantalla de login para iniciar sesión con Google
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let loginViewController = storyboard.instantiateViewController(withIdentifier: "BYZ-38-t0r") as? LoginViewController {
                    loginViewController.modalPresentationStyle = .fullScreen
                    loginViewController.modalTransitionStyle = .coverVertical
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = loginViewController
                        window.makeKeyAndVisible()
                    }
                }
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        // Cerrar la vista modal
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View Shipments Button Setup
    
    private func setupViewShipmentsButton() {
        viewShipmentsButton = UIButton(type: .system)
        viewShipmentsButton.setTitle("📦 Mis envíos", for: .normal)
        viewShipmentsButton.setTitleColor(.white, for: .normal)
        viewShipmentsButton.backgroundColor = UIColor(red: 39/255.0, green: 159/255.0, blue: 245/255.0, alpha: 1.0)
        viewShipmentsButton.layer.cornerRadius = 4
        viewShipmentsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        viewShipmentsButton.translatesAutoresizingMaskIntoConstraints = false
        viewShipmentsButton.addTarget(self, action: #selector(viewShipmentsButtonTapped), for: .touchUpInside)
        
        view.addSubview(viewShipmentsButton)
        
        // Configurar constraints para posicionarlo entre el email y el botón de logout
        NSLayoutConstraint.activate([
            viewShipmentsButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 25),
            viewShipmentsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewShipmentsButton.widthAnchor.constraint(equalToConstant: 190),
            viewShipmentsButton.heightAnchor.constraint(equalToConstant: 50),
            viewShipmentsButton.bottomAnchor.constraint(lessThanOrEqualTo: logoutButton.topAnchor, constant: -25)
        ])
    }
    
    @objc private func viewShipmentsButtonTapped() {
        showMyShipmentsOverlay()
    }
    
    // MARK: - My Shipments Overlay
    
    private func showMyShipmentsOverlay() {
        let contentView = createMyShipmentsView()
        showOverlay(contentView: contentView, size: CGSize(width: 350, height: 500))
    }
    
    private func createMyShipmentsView() -> UIView {
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = "Mis Envíos"
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Obtener envíos del usuario
        let userId = UserManager.shared.getUserEmail()
        let userShipments = ShippingManager.shared.getUserShippings(for: userId)
        
        if userShipments.isEmpty {
            // Mostrar mensaje cuando no hay envíos
            let noShipmentsLabel = UILabel()
            noShipmentsLabel.text = "No tienes envíos registrados aún.\n\n¡Registra tu primer envío desde la pantalla principal!"
            noShipmentsLabel.font = UIFont.systemFont(ofSize: 16)
            noShipmentsLabel.textAlignment = .center
            noShipmentsLabel.numberOfLines = 0
            noShipmentsLabel.textColor = .systemGray
            noShipmentsLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(noShipmentsLabel)
            
            let closeButton = UIButton(type: .system)
            closeButton.setTitle("Cerrar", for: .normal)
            closeButton.backgroundColor = UIColor(red: 39/255.0, green: 159/255.0, blue: 245/255.0, alpha: 1.0)
            closeButton.setTitleColor(.white, for: .normal)
            closeButton.layer.cornerRadius = 8
            closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.addTarget(self, action: #selector(closeOverlay), for: .touchUpInside)
            contentView.addSubview(closeButton)
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                
                noShipmentsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                noShipmentsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                noShipmentsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
                noShipmentsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
                
                closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
                closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: 100),
                closeButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        } else {
            // Crear tabla con envíos
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(scrollView)
            
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(stackView)
            
            // Agregar cada envío como una tarjeta
            for shipping in userShipments {
                let shipmentCard = createShipmentCard(shipping: shipping)
                stackView.addArrangedSubview(shipmentCard)
            }
            
            let closeButton = UIButton(type: .system)
            closeButton.setTitle("Cerrar", for: .normal)
            closeButton.backgroundColor = UIColor(red: 39/255.0, green: 159/255.0, blue: 245/255.0, alpha: 1.0)
            closeButton.setTitleColor(.white, for: .normal)
            closeButton.layer.cornerRadius = 8
            closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.addTarget(self, action: #selector(closeOverlay), for: .touchUpInside)
            contentView.addSubview(closeButton)
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                
                scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
                scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                scrollView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20),
                
                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                
                closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
                closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: 100),
                closeButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        return contentView
    }
    
    private func createShipmentCard(shipping: Shipping) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor.systemGray6
        cardView.layer.cornerRadius = 8
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray4.cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let codeLabel = UILabel()
        codeLabel.text = "Código: \(shipping.code)"
        codeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        codeLabel.textColor = .systemBlue
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(codeLabel)
        
        let locationLabel = UILabel()
        locationLabel.text = "Cargando..."
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        locationLabel.numberOfLines = 0
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(locationLabel)
        
        let addressLabel = UILabel()
        addressLabel.text = "Cargando dirección..."
        addressLabel.font = UIFont.systemFont(ofSize: 10)
        addressLabel.textColor = .systemGray
        
        // Obtener información del punto de recolección de forma asíncrona
        ShippingManager.shared.getCollectionPoints { collectionPoints in
            DispatchQueue.main.async {
                let collectionPoint = collectionPoints.first { $0.id == shipping.collectionPointId }
                locationLabel.text = collectionPoint?.name ?? "Punto desconocido"
                addressLabel.text = collectionPoint?.address ?? "Dirección no disponible"
            }
        }
        addressLabel.numberOfLines = 0
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(addressLabel)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        let registeredLabel = UILabel()
        registeredLabel.text = "Registrado: \(formatter.string(from: shipping.createdAt))"
        registeredLabel.font = UIFont.systemFont(ofSize: 10)
        registeredLabel.textColor = .systemGray2
        registeredLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(registeredLabel)
        
        let validityLabel = UILabel()
        validityLabel.text = "Válido hasta: \(formatter.string(from: shipping.validUntil))"
        validityLabel.font = UIFont.systemFont(ofSize: 10)
        validityLabel.textColor = .systemRed
        validityLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(validityLabel)
        
        // Calcular estado
        let now = Date()
        let status: String
        let statusColor: UIColor
        
        if now > shipping.validUntil {
            status = "Expirado"
            statusColor = .systemRed
        } else if shipping.status == .completed {
            status = "Completado"
            statusColor = .systemGreen
        } else {
            status = "Vigente"
            statusColor = .systemGreen
        }
        
        let statusLabel = UILabel()
        statusLabel.text = "Estado: \(status)"
        statusLabel.font = UIFont.boldSystemFont(ofSize: 12)
        statusLabel.textColor = statusColor
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(statusLabel)
        
        // Botón de eliminar
        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(named: "icon-trash"), for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteShipmentTapped(_:)), for: .touchUpInside)
        deleteButton.tag = shipping.code.hashValue // Usar hash del código como identificador
        cardView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 120),
            
            codeLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            codeLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            codeLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            
            locationLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            locationLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            
            addressLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 2),
            addressLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            addressLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            
            registeredLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 4),
            registeredLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
            validityLabel.topAnchor.constraint(equalTo: registeredLabel.bottomAnchor, constant: 2),
            validityLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
            statusLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 4),
            statusLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            
            deleteButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            deleteButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            deleteButton.widthAnchor.constraint(equalToConstant: 12),
            deleteButton.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        return cardView
    }
    
    @objc private func deleteShipmentTapped(_ sender: UIButton) {
        // Buscar el envío por el tag del botón
        let buttonTag = sender.tag
        let userId = UserManager.shared.getUserEmail()
        let userShipments = ShippingManager.shared.getUserShippings(for: userId)
        
        // Encontrar el envío correspondiente
        guard let shippingToDelete = userShipments.first(where: { $0.code.hashValue == buttonTag }) else {
            return
        }
        
        // Mostrar confirmación
        let alert = UIAlertController(
            title: "Eliminar envío",
            message: "¿Estás seguro de que deseas eliminar el envío \(shippingToDelete.code)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive) { _ in
            // Eliminar el envío
            let userId = UserManager.shared.getUserEmail()
            ShippingManager.shared.deleteShipping(shippingToDelete.code, for: userId)
            
            // Cerrar el overlay actual y volver a mostrarlo actualizado
            self.closeOverlay()
            
            // Mostrar el overlay actualizado después de un breve delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showMyShipmentsOverlay()
            }
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Overlay Management
    
    private func showOverlay(contentView: UIView, size: CGSize) {
        // Crear overlay de fondo
        overlayView = UIView(frame: view.bounds)
        overlayView!.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView!.alpha = 0
        
        // Agregar gesto para cerrar al tocar fuera
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeOverlay))
        overlayView!.addGestureRecognizer(tapGesture)
        
        view.addSubview(overlayView!)
        
        // Configurar vista de contenido
        contentView.translatesAutoresizingMaskIntoConstraints = false
        overlayView!.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: overlayView!.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: overlayView!.centerYAnchor),
            contentView.widthAnchor.constraint(equalToConstant: size.width),
            contentView.heightAnchor.constraint(equalToConstant: size.height)
        ])
        
        // Animar aparición
        UIView.animate(withDuration: 0.3) {
            self.overlayView!.alpha = 1
        }
    }
    
    @objc private func closeOverlay() {
        guard let overlay = overlayView else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            overlay.alpha = 0
        }) { _ in
            overlay.removeFromSuperview()
            self.overlayView = nil
        }
    }
}