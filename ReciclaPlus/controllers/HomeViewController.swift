//
//  HomeViewController.swift
//  ReciclaPlus
//
//  Created by MacOS on 20/08/25.
//

import UIKit
import WebKit



// Estructura para los productos reciclables
struct RecyclableProduct {
    let name: String
    let imageName: String
    var recycledCount: Int
    let environmentalImpact: [String]
    let recyclingTips: [String]
}

// Estructura para las categorías de reciclaje
struct RecyclingCategory {
    let id: Int
    let name: String
    let products: [RecyclableProduct]
    let description: String
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var topPlasticoImage: UIImageView!
    @IBOutlet weak var topMetalImage: UIImageView!
    @IBOutlet weak var topVidrioImage: UIImageView!
    @IBOutlet weak var masRecicladosCollectionView: UICollectionView!
    @IBOutlet weak var servicio_envios: UIImageView!
    @IBOutlet weak var servicio_empaquetado: UIImageView!
    
    // Referencia al overlay actual
    private var currentOverlay: OverlayView?
    
    // Array de categorías de reciclaje con sus productos
    private var recyclingCategories: [RecyclingCategory] = []
    
    // Array de productos más reciclados (se llenará en viewDidLoad)
    private var masReciclados: [RecyclableProduct] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAvatar()
        setupNotifications()
        setupCategoryImages()
        loadCategoriasFromAPI()
        loadProductosFromAPI()
        setupCollectionView()
        loadCollectionPoints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if masRecicladosCollectionView != nil {
        masRecicladosCollectionView?.reloadData()
        }
    }
    
    private func setupAvatar() {
        // Crear y configurar el avatar como botón de navegación
        let avatarBarButtonItem = UserManager.shared.createAvatarBarButtonItem(
            target: self,
            action: #selector(avatarButtonTapped(_:))
        )
        navigationItem.rightBarButtonItem = avatarBarButtonItem
    }
    
    private func setupNotifications() {
        // Escuchar cambios en el avatar del usuario
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar),
            name: NSNotification.Name("UserAvatarUpdated"),
            object: nil
        )
    }
    
    @objc private func updateAvatar() {
        if let avatarBarButtonItem = navigationItem.rightBarButtonItem {
            UserManager.shared.updateAvatarBarButtonItem(avatarBarButtonItem)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func avatarButtonTapped(_ sender: UIButton) {
        // Navegación modal hacia ViewPerfil
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewPerfil = storyboard.instantiateViewController(withIdentifier: "YID-Ks-zeR") as? PerfilViewController {
            viewPerfil.modalPresentationStyle = .pageSheet
            viewPerfil.modalTransitionStyle = .coverVertical
            present(viewPerfil, animated: true, completion: nil)
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupCategoryImages() {
        // Configurar gestos para las imágenes de categorías
        if let plasticoImage = topPlasticoImage {
            let tapPlastico = UITapGestureRecognizer(target: self, action: #selector(plasticoImageTapped))
            plasticoImage.isUserInteractionEnabled = true
            plasticoImage.addGestureRecognizer(tapPlastico)
        }
        
        if let metalImage = topMetalImage {
            let tapMetal = UITapGestureRecognizer(target: self, action: #selector(metalImageTapped))
            metalImage.isUserInteractionEnabled = true
            metalImage.addGestureRecognizer(tapMetal)
        }
        
        if let vidrioImage = topVidrioImage {
            let tapVidrio = UITapGestureRecognizer(target: self, action: #selector(vidrioImageTapped))
            vidrioImage.isUserInteractionEnabled = true
            vidrioImage.addGestureRecognizer(tapVidrio)
        }
        
        // Configurar tap gesture para servicio_envios
        if let servicioEnviosImage = servicio_envios {
            let tapServicioEnvios = UITapGestureRecognizer(target: self, action: #selector(servicioEnviosTapped))
            servicioEnviosImage.isUserInteractionEnabled = true
            servicioEnviosImage.addGestureRecognizer(tapServicioEnvios)
        }
        
        // Configurar tap gesture para servicio_empaquetado
        if let servicioEmpaquetadoImage = servicio_empaquetado {
            let tapServicioEmpaquetado = UITapGestureRecognizer(target: self, action: #selector(servicioEmpaquetadoTapped))
            servicioEmpaquetadoImage.isUserInteractionEnabled = true
            servicioEmpaquetadoImage.addGestureRecognizer(tapServicioEmpaquetado)
        }
    }
    
    private func setupMasReciclados() {
        // Obtener todos los productos de todas las categorías
        var allProducts: [RecyclableProduct] = []
        for category in recyclingCategories {
            allProducts.append(contentsOf: category.products)
        }
        
        // Ordenar productos por cantidad de reciclados (de mayor a menor)
        masReciclados = allProducts.sorted(by: { $0.recycledCount > $1.recycledCount })
    }
    
    private func setupCollectionView() {
        // Verificar que masRecicladosCollectionView no sea nil antes de configurarlo
        if let collectionView = masRecicladosCollectionView {
            collectionView.dataSource = self
            collectionView.delegate = self
            
            // Recargar datos del collection view
            collectionView.reloadData()
        }
    }
    
    // MARK: - Category Image Actions
    
    @objc private func plasticoImageTapped() {
        if !recyclingCategories.isEmpty {
            showCategoryOverlay(category: recyclingCategories[0]) // Plásticos
        }
    }
    
    @objc private func metalImageTapped() {
        if recyclingCategories.count > 3 {
            showCategoryOverlay(category: recyclingCategories[3]) // Metales
        }
    }
    
    @objc private func vidrioImageTapped() {
        if recyclingCategories.count > 2 {
            showCategoryOverlay(category: recyclingCategories[2]) // Vidrio
        }
    }
    
    @objc private func servicioEnviosTapped() {
        // Verificar si el usuario está autenticado
        if ShippingManager.shared.isUserAuthenticated() {
            showShippingStepsOverlay()
        } else {
            showAuthenticationRequiredOverlay()
        }
    }
    
    @objc private func servicioEmpaquetadoTapped() {
        showProximamenteOverlay()
    }
    
    // MARK: - Overlay Methods
    
    private func showProximamenteOverlay() {
        let contentView = createProximamenteView()
        currentOverlay = OverlayView.showWithContent(contentView, in: self.view, size: CGSize(width: 300, height: 200))
    }
    
    private func createProximamenteView() -> UIView {
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = "Próximamente"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
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
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return contentView
    }
    
    private func showCategoryOverlay(category: RecyclingCategory) {
        // Cerrar overlay anterior si existe
        currentOverlay?.dismiss()
        
        // Crear vista de contenido para el overlay
        let contentView = createCategoryDetailView(category: category)
        
        // Verificar que la vista del controlador esté disponible
        guard let parentView = self.view else {
            return
        }
        
        // Mostrar overlay con el contenido y guardar referencia
        currentOverlay = OverlayView.showWithContent(contentView, in: parentView, size: CGSize(width: 320, height: 400))
    }
    
    private func createCategoryDetailView(category: RecyclingCategory) -> UIView {
        let contentView = UIView()
        contentView.backgroundColor = .white
        
        // Título de la categoría
        let titleLabel = UILabel()
        titleLabel.text = category.name
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Descripción de la categoría
        let descriptionLabel = UILabel()
        descriptionLabel.text = category.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .justified
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // Productos de la categoría (título)
        let productsTitle = UILabel()
        productsTitle.text = "Productos reciclables:"
        productsTitle.font = UIFont.boldSystemFont(ofSize: 16)
        productsTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(productsTitle)
        
        // Lista de productos
        let productsLabel = UILabel()
        let productsList = category.products.map { "• " + $0.name }.joined(separator: "\n")
        productsLabel.text = productsList
        productsLabel.font = UIFont.systemFont(ofSize: 14)
        productsLabel.numberOfLines = 0
        productsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(productsLabel)
        
        // Botón de cerrar
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Cerrar", for: .normal)
        closeButton.backgroundColor = UIColor(red: 39/255.0, green: 159/255.0, blue: 245/255.0, alpha: 1.0)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 8
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeOverlay), for: .touchUpInside)
        contentView.addSubview(closeButton)
        
        // Restricciones de Auto Layout
        NSLayoutConstraint.activate([
            // Título
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Descripción
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Título de productos
            productsTitle.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            productsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            productsTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Lista de productos
            productsLabel.topAnchor.constraint(equalTo: productsTitle.bottomAnchor, constant: 8),
            productsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            productsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Botón de cerrar
            closeButton.topAnchor.constraint(equalTo: productsLabel.bottomAnchor, constant: 15),
            closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 35),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        return contentView
    }
    

    
    // MARK: - Product Detail Overlay
    private func showProductDetailOverlay(product: RecyclableProduct) {
        // Remover overlay existente si hay uno
        currentOverlay?.dismiss()
        
        // Crear vista de contenido
        let contentView = createProductDetailView(product: product)
        
        // Usar el método correcto de OverlayView para mostrar contenido
        let overlay = OverlayView.showWithContent(contentView, in: view, size: CGSize(width: 380, height: 575))
        currentOverlay = overlay
    }
    
    @objc private func closeOverlay() {
        currentOverlay?.dismiss()
        currentOverlay = nil
    }
    
    private func createProductDetailView(product: RecyclableProduct) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        
        // Crear scroll view para contenido largo
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.backgroundColor = .clear
        containerView.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white
        scrollView.addSubview(contentView)
        
        // Imagen del producto
        let productImageView = UIImageView()
        productImageView.image = UIImage(named: product.imageName) ?? UIImage(named: "ic_ph_cat")
        productImageView.contentMode = .scaleAspectFit
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(productImageView)
        
        // Título del producto
        let titleLabel = UILabel()
        titleLabel.text = product.name
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Cantidad reciclada
        let countLabel = UILabel()
        countLabel.text = "\(product.recycledCount) unidades recicladas"
        countLabel.font = UIFont.systemFont(ofSize: 18)
        countLabel.textColor = .darkGray
        countLabel.textAlignment = .center
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(countLabel)
        
        // Título impacto ambiental
        let impactTitleLabel = UILabel()
        impactTitleLabel.text = "Impacto ambiental:"
        impactTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        impactTitleLabel.textColor = .darkGray
        impactTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(impactTitleLabel)
        
        // Lista de impacto ambiental
        let impactStackView = UIStackView()
        impactStackView.axis = .vertical
        impactStackView.spacing = 4
        impactStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for impact in product.environmentalImpact {
            let impactLabel = UILabel()
            impactLabel.text = "• \(impact)"
            impactLabel.font = UIFont.systemFont(ofSize: 14)
            impactLabel.textColor = .black
            impactLabel.numberOfLines = 0
            impactStackView.addArrangedSubview(impactLabel)
        }
        contentView.addSubview(impactStackView)
        
        // Título tips
        let tipsTitleLabel = UILabel()
        tipsTitleLabel.text = "Tips para reciclar:"
        tipsTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        tipsTitleLabel.textColor = .darkGray
        tipsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tipsTitleLabel)
        
        // Lista de tips
        let tipsStackView = UIStackView()
        tipsStackView.axis = .vertical
        tipsStackView.spacing = 4
        tipsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for tip in product.recyclingTips {
            let tipLabel = UILabel()
            tipLabel.text = "• \(tip)"
            tipLabel.font = UIFont.systemFont(ofSize: 14)
            tipLabel.textColor = .black
            tipLabel.numberOfLines = 0
            tipLabel.translatesAutoresizingMaskIntoConstraints = false
            tipsStackView.addArrangedSubview(tipLabel)
        }
        contentView.addSubview(tipsStackView)
        
        // Botón de cerrar
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Cerrar", for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        closeButton.backgroundColor = UIColor(red: 39/255.0, green: 159/255.0, blue: 245/255.0, alpha: 1.0)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 12
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeOverlay), for: .touchUpInside)
        contentView.addSubview(closeButton)
        
        // Configurar constraints
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Imagen del producto
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            productImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Título
            titleLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Contador
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Título impacto
            impactTitleLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 20),
            impactTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            impactTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Lista impacto
            impactStackView.topAnchor.constraint(equalTo: impactTitleLabel.bottomAnchor, constant: 8),
            impactStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            impactStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Título tips
            tipsTitleLabel.topAnchor.constraint(equalTo: impactStackView.bottomAnchor, constant: 20),
            tipsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tipsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Lista tips
            tipsStackView.topAnchor.constraint(equalTo: tipsTitleLabel.bottomAnchor, constant: 8),
            tipsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tipsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Botón cerrar
            closeButton.topAnchor.constraint(equalTo: tipsStackView.bottomAnchor, constant: 30),
            closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 120),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        

        
        // Forzar layout antes de devolver
        containerView.layoutIfNeeded()
        
        return containerView
    }
    
    // MARK: - Shipping Methods
    
    private func showAuthenticationRequiredOverlay() {
        currentOverlay?.dismiss()
        
        let contentView = createAuthenticationRequiredView()
        currentOverlay = OverlayView.showWithContent(contentView, in: view, size: CGSize(width: 320, height: 200))
    }
    
    private func createAuthenticationRequiredView() -> UIView {
        let contentView = UIView()
        contentView.backgroundColor = .white
        
        let messageLabel = UILabel()
        messageLabel.text = "Debes iniciar sesión"
        messageLabel.font = UIFont.boldSystemFont(ofSize: 18)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)
        
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
            messageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -20),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 120),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return contentView
    }
    
    @objc private func loginButtonTapped() {
        // Aquí iría la lógica de autenticación con Google
        // Por ahora, simulamos que el usuario se autentica
        closeOverlay()
        
        // Mostrar mensaje de que debe implementarse la autenticación
        let alert = UIAlertController(title: "Funcionalidad Pendiente", message: "La autenticación con Google debe ser implementada.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showShippingStepsOverlay() {
        currentOverlay?.dismiss()
        
        let contentView = createShippingStepsView()
        currentOverlay = OverlayView.showWithContent(contentView, in: view, size: CGSize(width: 350, height: 500))
    }
    
    private func createShippingStepsView() -> UIView {
        let contentView = UIView()
        contentView.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "Pasos para registrar tu envío"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Crear los 3 pasos
        let step1Label = createStepLabel(number: "1", text: "Selección de ubicación\nElige el punto de reciclaje más cercano a tu ubicación. Todos nuestros puntos cuentan con personal capacitado.")
        let step2Label = createStepLabel(number: "2", text: "Confirma ubicación en el mapa\nVerifica la ubicación exacta en el mapa. Esto te ayudará a llegar sin problemas al punto de reciclaje seleccionado.")
        let step3Label = createStepLabel(number: "3", text: "Obtener código de envío\nTu código es único y tiene una validez de 2 días. Preséntalo en el centro de reciclaje seleccionado.")
        
        contentView.addSubview(step1Label)
        contentView.addSubview(step2Label)
        contentView.addSubview(step3Label)
        
        // ComboBox para puntos de recolección
        let comboLabel = UILabel()
        comboLabel.text = "Selecciona un punto de recolección:"
        comboLabel.font = UIFont.boldSystemFont(ofSize: 14)
        comboLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(comboLabel)
        
        let comboButton = UIButton(type: .system)
        comboButton.setTitle("Seleccionar punto de recolección", for: .normal)
        comboButton.backgroundColor = UIColor.systemGray6
        comboButton.setTitleColor(.black, for: .normal)
        comboButton.layer.borderColor = UIColor.systemGray4.cgColor
        comboButton.layer.borderWidth = 1
        comboButton.layer.cornerRadius = 8
        comboButton.contentHorizontalAlignment = .left
        comboButton.tag = 1000 // Tag para identificar el botón del combobox
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
            config.title = "Seleccionar punto de recolección"
            config.baseForegroundColor = .black
            config.background.backgroundColor = UIColor.systemGray6
            comboButton.configuration = config
        } else {
            comboButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        comboButton.translatesAutoresizingMaskIntoConstraints = false
        comboButton.addTarget(self, action: #selector(showCollectionPointsPicker), for: .touchUpInside)
        contentView.addSubview(comboButton)
        
        // Contenedor para información del envío (inicialmente oculto)
        let shippingInfoContainer = UIView()
        shippingInfoContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        shippingInfoContainer.layer.cornerRadius = 8
        shippingInfoContainer.isHidden = true
        shippingInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        shippingInfoContainer.tag = 999 // Para identificarlo después
        contentView.addSubview(shippingInfoContainer)
        
        let codeLabel = UILabel()
        codeLabel.text = "Código de envío: ENV-XXXXXX"
        codeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        codeLabel.tag = 1001
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        shippingInfoContainer.addSubview(codeLabel)
        
        let validityLabel = UILabel()
        validityLabel.text = "Válido hasta: --/--/---- --:--"
        validityLabel.font = UIFont.systemFont(ofSize: 12)
        validityLabel.textColor = .systemRed
        validityLabel.tag = 1002
        validityLabel.translatesAutoresizingMaskIntoConstraints = false
        shippingInfoContainer.addSubview(validityLabel)
        
        let continueButton = UIButton(type: .system)
        continueButton.setTitle("Continuar", for: .normal)
        continueButton.backgroundColor = UIColor(red: 39/255.0, green: 159/255.0, blue: 245/255.0, alpha: 1.0)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 8
        continueButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        continueButton.isEnabled = false
        continueButton.alpha = 0.5
        continueButton.tag = 1003
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueToMapView), for: .touchUpInside)
        shippingInfoContainer.addSubview(continueButton)
        
        // Botón cerrar eliminado según requerimiento
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            step1Label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            step1Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            step1Label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            step2Label.topAnchor.constraint(equalTo: step1Label.bottomAnchor, constant: 15),
            step2Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            step2Label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            step3Label.topAnchor.constraint(equalTo: step2Label.bottomAnchor, constant: 15),
            step3Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            step3Label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            comboLabel.topAnchor.constraint(equalTo: step3Label.bottomAnchor, constant: 20),
            comboLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            comboLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            comboButton.topAnchor.constraint(equalTo: comboLabel.bottomAnchor, constant: 8),
            comboButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            comboButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            comboButton.heightAnchor.constraint(equalToConstant: 44),
            
            shippingInfoContainer.topAnchor.constraint(equalTo: comboButton.bottomAnchor, constant: 15),
            shippingInfoContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            shippingInfoContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            shippingInfoContainer.heightAnchor.constraint(equalToConstant: 100),
            
            codeLabel.topAnchor.constraint(equalTo: shippingInfoContainer.topAnchor, constant: 10),
            codeLabel.leadingAnchor.constraint(equalTo: shippingInfoContainer.leadingAnchor, constant: 15),
            codeLabel.trailingAnchor.constraint(equalTo: shippingInfoContainer.trailingAnchor, constant: -15),
            
            validityLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 5),
            validityLabel.leadingAnchor.constraint(equalTo: shippingInfoContainer.leadingAnchor, constant: 15),
            validityLabel.trailingAnchor.constraint(equalTo: shippingInfoContainer.trailingAnchor, constant: -15),
            
            continueButton.topAnchor.constraint(equalTo: validityLabel.bottomAnchor, constant: 10),
            continueButton.centerXAnchor.constraint(equalTo: shippingInfoContainer.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 120),
            continueButton.heightAnchor.constraint(equalToConstant: 35),
            
            shippingInfoContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        return contentView
    }
    
    private func createStepLabel(number: String, text: String) -> UILabel {
        let label = UILabel()
        label.text = "\(number). \(text)"
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 5
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Establecer altura específica para permitir 5 líneas (aumentada para mejor visualización)
        label.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return label
    }
    
    @objc private func showCollectionPointsPicker() {
        let alert = UIAlertController(title: "Puntos de Recolección", message: "Selecciona un punto:", preferredStyle: .actionSheet)
        
        ShippingManager.shared.getCollectionPoints { collectionPoints in
            DispatchQueue.main.async {
                if collectionPoints.isEmpty {
                    let noPointsAction = UIAlertAction(title: "No hay puntos disponibles", style: .default, handler: nil)
                    alert.addAction(noPointsAction)
                } else {
                    for point in collectionPoints {
                        let action = UIAlertAction(title: point.name, style: .default) { _ in
                            self.selectCollectionPoint(point)
                        }
                        alert.addAction(action)
                    }
                }
                
                alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
                
                // Configuración para iPad
                if let popover = alert.popoverPresentationController {
                    popover.sourceView = self.view
                    popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                self.present(alert, animated: true)
            }
        }
    }
    
    private var selectedCollectionPoint: CollectionPoint?
    private var currentShippingCode: String?
    
    private func selectCollectionPoint(_ point: CollectionPoint) {
        selectedCollectionPoint = point
        currentShippingCode = Shipping.generateShippingCode()
        
        let validUntil = Calendar.current.date(byAdding: .hour, value: 48, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        DispatchQueue.main.async {
            
            // Si no hay overlay actual, mostrar el overlay de pasos de envío
            if self.currentOverlay == nil {
                self.showShippingStepsOverlay()
            }
            
            // Esperar un momento para que el overlay se configure completamente
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                guard let overlay = self.currentOverlay else { 
                    return 
                }
                
                // Buscar el containerView dentro del overlay (es el segundo subview)
                guard overlay.subviews.count >= 2,
                      let contentView = overlay.subviews[1].subviews.first else {
                    return
                }
            
                // Función auxiliar para búsqueda recursiva
                func findViewWithTag(_ tag: Int, in view: UIView) -> UIView? {
                    if view.tag == tag {
                        return view
                    }
                    for subview in view.subviews {
                        if let found = findViewWithTag(tag, in: subview) {
                            return found
                        }
                    }
                    return nil
                }
                
                // Buscar elementos con búsqueda recursiva
                if let comboButton = findViewWithTag(1000, in: contentView) as? UIButton {
                    comboButton.setTitle("\(point.name) ▼", for: .normal)
                    
                    if #available(iOS 15.0, *), var config = comboButton.configuration {
                        config.title = "\(point.name) ▼"
                        comboButton.configuration = config
                    }
                }
            
            if let shippingContainer = findViewWithTag(999, in: contentView) {
                let codeLabel = shippingContainer.viewWithTag(1001) as? UILabel
                let validityLabel = shippingContainer.viewWithTag(1002) as? UILabel
                let continueButton = shippingContainer.viewWithTag(1003) as? UIButton
                
                codeLabel?.text = "Código de envío: \(self.currentShippingCode!)"
                validityLabel?.text = "Válido hasta: \(formatter.string(from: validUntil))"
                
                shippingContainer.isHidden = false
                shippingContainer.alpha = 1.0
                continueButton?.isEnabled = true
                continueButton?.alpha = 1.0
                
                // Forzar actualización visual
                shippingContainer.setNeedsLayout()
                shippingContainer.layoutIfNeeded()
                contentView.setNeedsLayout()
                contentView.layoutIfNeeded()
            }
                }
            }
        }
    
    @objc private func continueToMapView() {
        guard let selectedPoint = selectedCollectionPoint else { return }
        
        currentOverlay?.dismiss()
        
        let contentView = createMapView(for: selectedPoint)
        currentOverlay = OverlayView.showWithContent(contentView, in: view, size: CGSize(width: 350, height: 450))
    }
    
    private func createMapView(for collectionPoint: CollectionPoint) -> UIView {
        let contentView = UIView()
        contentView.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = collectionPoint.name
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        let addressLabel = UILabel()
        addressLabel.text = collectionPoint.address
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 0
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addressLabel)
        
        // Google Maps iframe con WKWebView
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.layer.cornerRadius = 8
        webView.layer.borderColor = UIColor.systemGray4.cgColor
        webView.layer.borderWidth = 1
        contentView.addSubview(webView)
        
        // Crear HTML con iframe de Google Maps
        let encodedAddress = collectionPoint.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let mapHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { margin: 0; padding: 0; }
                iframe { width: 100%; height: 100%; border: none; }
            </style>
        </head>
        <body>
            <iframe src="https://maps.google.com/maps?q=\(encodedAddress)&output=embed" loading="lazy" referrerpolicy="no-referrer-when-downgrade" allowfullscreen></iframe>
        </body>
        </html>
        """
        
        webView.loadHTMLString(mapHTML, baseURL: nil)
        
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Confirmar envío", for: .normal)
        confirmButton.backgroundColor = UIColor(red: 39/255.0, green: 159/255.0, blue: 245/255.0, alpha: 1.0)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 8
        confirmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirmShipping), for: .touchUpInside)
        contentView.addSubview(confirmButton)
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("Volver", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backToSteps), for: .touchUpInside)
        contentView.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            addressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            webView.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 20),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            webView.heightAnchor.constraint(equalToConstant: 150),
            
            confirmButton.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
            confirmButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 150),
            confirmButton.heightAnchor.constraint(equalToConstant: 44),
            
            backButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 10),
            backButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        return contentView
    }
    
    @objc private func backToSteps() {
        showShippingStepsOverlay()
    }
    
    @objc private func confirmShipping() {
        guard let selectedPoint = selectedCollectionPoint else { return }
        
        let userId = UserManager.shared.getUserEmail()
        
        // Verificar si el usuario puede crear un nuevo envío
        if !ShippingManager.shared.canCreateNewShipping(for: userId) {
            ShippingManager.shared.showShippingLimitAlert(on: self)
            return
        }
        
        // Guardar el envío
        let shipping = ShippingManager.shared.createShipping(
            for: selectedPoint.id,
            userId: userId
        )
        
        showShippingConfirmationOverlay(shipping: shipping)
    }
    
    private func showShippingConfirmationOverlay(shipping: Shipping) {
        currentOverlay?.dismiss()
        
        let contentView = createShippingConfirmationView(shipping: shipping)
        currentOverlay = OverlayView.showWithContent(contentView, in: view, size: CGSize(width: 320, height: 300))
    }
    
    private func createShippingConfirmationView(shipping: Shipping) -> UIView {
        let contentView = UIView()
        contentView.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "¡Envío registrado!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .systemGreen
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        let codeLabel = UILabel()
        codeLabel.text = "Código de envío: \(shipping.code)"
        codeLabel.font = UIFont.boldSystemFont(ofSize: 16)
        codeLabel.textAlignment = .center
        codeLabel.textColor = .systemBlue
        codeLabel.numberOfLines = 3
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(codeLabel)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        let validityLabel = UILabel()
        validityLabel.text = "Válido hasta: \(formatter.string(from: shipping.validUntil))"
        validityLabel.font = UIFont.systemFont(ofSize: 14)
        validityLabel.textAlignment = .center
        validityLabel.textColor = .systemRed
        validityLabel.numberOfLines = 3
        validityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(validityLabel)
        
        let instructionLabel = UILabel()
        instructionLabel.text = "Presenta este código en el punto de recolección seleccionado antes de la fecha de validez."
        instructionLabel.font = UIFont.systemFont(ofSize: 12)
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = .systemGray
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(instructionLabel)
        
        let acceptButton = UIButton(type: .system)
        acceptButton.setTitle("Aceptar", for: .normal)
        acceptButton.backgroundColor = UIColor(red: 39/255.0, green: 159/255.0, blue: 245/255.0, alpha: 1.0)
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.layer.cornerRadius = 8
        acceptButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.addTarget(self, action: #selector(closeOverlay), for: .touchUpInside)
        contentView.addSubview(acceptButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            codeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            codeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            codeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            validityLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 15),
            validityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            validityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            instructionLabel.topAnchor.constraint(equalTo: validityLabel.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            acceptButton.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 30),
            acceptButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            acceptButton.widthAnchor.constraint(equalToConstant: 120),
            acceptButton.heightAnchor.constraint(equalToConstant: 44),
            acceptButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
        
        return contentView
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - API Methods
extension HomeViewController {
    
    private func loadCategoriasFromAPI() {
        APIManager.shared.getCategorias { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categorias):
                    // Las categorías de la API no incluyen productos anidados
                    // Los productos se cargan por separado
                    self?.recyclingCategories = categorias.map { categoria in
                        RecyclingCategory(
                            id: categoria.id,
                            name: categoria.nombre,
                            products: [], // Se llenará con productos filtrados por categoriaId
                            description: categoria.descripcion
                        )
                    }
                case .failure(_):
                    // Mantener array vacío en caso de error
                    break
                }
            }
        }
    }
    
    private func loadProductosFromAPI() {
        APIManager.shared.getProductos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let productos):
                    let recyclableProducts = productos.map { producto in
                        RecyclableProduct(
                            name: producto.nombre,
                            imageName: self?.convertAPIImagePathToLocalName(producto.imagen) ?? "ic_ph_cat",
                            recycledCount: producto.cantidadReciclada,
                            environmentalImpact: producto.impactoAmbiental,
                            recyclingTips: producto.tipsReciclaje
                        )
                    }
                    
                    // Asignar productos más reciclados ordenados por cantidad de reciclados (de mayor a menor)
                    self?.masReciclados = recyclableProducts.sorted(by: { $0.recycledCount > $1.recycledCount })
                    
                    // Asociar productos con sus categorías
                    self?.associateProductsWithCategories(productos: productos, recyclableProducts: recyclableProducts)
                    
                    self?.masRecicladosCollectionView.reloadData()
                case .failure(_):
                    // Mantener array vacío en caso de error
                    break
                }
            }
        }
    }
    
    private func loadCollectionPoints() {
        ShippingManager.shared.getCollectionPoints { collectionPoints in
            DispatchQueue.main.async {
                // Puntos de recolección cargados
            }
        }
    }
    
    private func associateProductsWithCategories(productos: [Producto], recyclableProducts: [RecyclableProduct]) {
         // Crear un diccionario para mapear productos por categoría
         var productsByCategory: [Int: [RecyclableProduct]] = [:]
         
         for (index, producto) in productos.enumerated() {
             if productsByCategory[producto.categoriaId] == nil {
                 productsByCategory[producto.categoriaId] = []
             }
             productsByCategory[producto.categoriaId]?.append(recyclableProducts[index])
         }
         
         // Actualizar las categorías con sus productos correspondientes
         for (index, category) in recyclingCategories.enumerated() {
             recyclingCategories[index] = RecyclingCategory(
                 id: category.id,
                 name: category.name,
                 products: productsByCategory[category.id] ?? [],
                 description: category.description
             )
         }
     }
     
     // MARK: - Image Helper Methods
     
     /// Convierte rutas de imágenes de la API a nombres de archivos locales
     private func convertAPIImagePathToLocalName(_ apiImagePath: String) -> String {
         // Remover la barra inicial si existe
         let cleanPath = apiImagePath.hasPrefix("/") ? String(apiImagePath.dropFirst()) : apiImagePath
         
         // Mapear rutas específicas a nombres de archivos locales
         switch cleanPath {
         // Productos
         case "productos/producto_general":
             return "producto_general"
         
         // Categorías
         case "categorias/plastico":
             return "plastico"
         case "categorias/papel_carton":
             return "papel_carton"
         case "categorias/vidrio":
             return "vidrio"
         case "categorias/metal":
             return "metal"
         case "categorias/electronico":
             return "electronico"
         case "categorias/peligrosos_especiales":
             return "peligrosos_especiales"
         
         // Tips
         case "tips/tip_general":
             return "tip_general"
         
         // Eventos
         case let path where path.hasPrefix("eventos/"):
             return String(path.dropFirst(8)) // Remover "eventos/"
         
         // Logros
         case let path where path.hasPrefix("logros/"):
             return String(path.dropFirst(7)) // Remover "logros/"
         
         // Onboarding
         case let path where path.hasPrefix("onboarding/"):
             return String(path.dropFirst(11)) // Remover "onboarding/"
         
         // Fallback: usar el nombre del archivo sin la ruta
         default:
             return cleanPath.components(separatedBy: "/").last ?? "ic_ph_cat"
         }
     }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(masReciclados.count, 10) // Mostrar máximo 10 productos
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogroCell", for: indexPath)
        
        // Verificar que el índice sea válido
        guard indexPath.item < masReciclados.count else {
            return cell
        }
        
        let producto = masReciclados[indexPath.item]
        
        // Configurar imagen
        for subview in cell.contentView.subviews {
            if let imageView = subview as? UIImageView {
                // Usar la imagen de la API convertida a nombre local, o imagen por defecto
                let imageName = convertAPIImagePathToLocalName(producto.imageName)
                imageView.image = UIImage(named: imageName) ?? UIImage(named: "ic_ph_cat")
                break // Solo hay una imagen por celda
            }
        }
        
        // Configurar labels por orden de aparición
        let labels = cell.contentView.subviews.compactMap { $0 as? UILabel }
        if labels.count >= 2 {
            // Primer label (nombre) - font más grande, siempre 2 líneas sin puntos suspensivos
            let nameLabel = labels.first { $0.font.pointSize > 14 } ?? labels[0]
            nameLabel.text = producto.name
            nameLabel.numberOfLines = 2
            nameLabel.lineBreakMode = .byWordWrapping
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.minimumScaleFactor = 0.8
            
            // Segundo label (contador) - font más pequeño, también 2 líneas
            let countLabel = labels.first { $0.font.pointSize <= 14 } ?? labels[1]
            countLabel.text = "\(producto.recycledCount) reciclados"
            countLabel.numberOfLines = 2
            countLabel.lineBreakMode = .byWordWrapping
        }
        
        // Agregar borde gris con redondeado de 4 puntos
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 4.0
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Verificar que el índice sea válido
        guard indexPath.item < masReciclados.count else {
            return
        }
        
        let product = masReciclados[indexPath.item]
        showProductDetailOverlay(product: product)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: 120, height: 185)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}