//
//  TipsViewController.swift
//  ReciclaPlus
//
//  Created by MacOS on 20/08/25.
//  Controlador para mostrar consejos de reciclaje en un formato de cuadrícula
//

import UIKit

// Estructura que define un consejo de reciclaje con identificador, título, descripción e imagen
struct TipItem {
    let id: Int
    let title: String
    let description: String
    let imagen: String?
}

class TipsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Array de tips desde API
    private var tips: [TipItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inicializa los componentes principales de la interfaz
        setupAvatar()
        setupNotifications()
        setupCollectionView()
        loadTipsFromAPI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Forzar recarga si no hay datos
        if tips.isEmpty {
            loadTipsFromAPI()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Actualiza el diseño de la colección cuando cambia el tamaño de la vista
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let screenWidth = UIScreen.main.bounds.width
            let padding: CGFloat = 2  // Padding lateral reducido para permitir 4 columnas
            let spacing: CGFloat = -1  // Espaciado reducido para compensar el ancho adicional de las celdas
            let numberOfColumns: CGFloat = 4  // Configuración para mostrar 4 columnas
            
            let availableWidth = screenWidth - (padding * 3) - (spacing * (numberOfColumns - 1))
            let itemWidth = floor(availableWidth / numberOfColumns) // Usa floor para evitar problemas de redondeo
            
            layout.itemSize = CGSize(width: itemWidth, height: 130)
            layout.minimumInteritemSpacing = spacing  // Espaciado horizontal entre elementos (-1 puntos)
            layout.minimumLineSpacing = 10  // Espaciado vertical entre filas (10 puntos para mayor separación)
            layout.sectionInset = UIEdgeInsets(top: 8, left: padding, bottom: 8, right: padding)
            
            // Invalidar y forzar actualización
            collectionView?.collectionViewLayout.invalidateLayout()
            collectionView?.reloadData()
        }
    }
    
    private func setupAvatar() {
        // Configura el avatar del usuario como botón en la barra de navegación
        let avatarBarButtonItem = UserManager.shared.createAvatarBarButtonItem(
            target: self,
            action: #selector(avatarButtonTapped(_:))
        )
        navigationItem.rightBarButtonItem = avatarBarButtonItem
    }
    
    private func setupNotifications() {
        // Registra observadores para detectar cambios en el avatar del usuario
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
        // Presenta la vista de perfil del usuario en modo modal
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewPerfil = storyboard.instantiateViewController(withIdentifier: "YID-Ks-zeR") as? PerfilViewController {
            viewPerfil.modalPresentationStyle = .pageSheet
            viewPerfil.modalTransitionStyle = .coverVertical
            present(viewPerfil, animated: true, completion: nil)
        }
    }
    
    private func setupCollectionView() {
        guard let collectionView = collectionView else {
            return
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Configura el diseño para mostrar 4 columnas de consejos
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.main.bounds.width  // Usa UIScreen para obtener el ancho exacto de la pantalla
        let padding: CGFloat = 2  // Padding lateral reducido para permitir 4 columnas
        let spacing: CGFloat = -8  // Espaciado reducido para compensar el ancho adicional de las celdas
        let numberOfColumns: CGFloat = 4  // Configuración para mostrar 4 columnas
        
        // Calcula el ancho de cada elemento para distribuir uniformemente en 4 columnas
        let availableWidth = screenWidth - (padding * 3) - (spacing * (numberOfColumns - 1))
        let itemWidth = floor(availableWidth / numberOfColumns) + 10 // Aumentar ancho en 10 puntos más
        
        layout.itemSize = CGSize(width: itemWidth, height: 130)
        layout.minimumInteritemSpacing = spacing  // Espaciado horizontal entre elementos (-8 puntos)
        layout.minimumLineSpacing = 10  // Espaciado vertical entre filas (10 puntos para mayor separación)
        layout.sectionInset = UIEdgeInsets(top: 8, left: padding, bottom: 8, right: padding)
        layout.estimatedItemSize = .zero  // Deshabilitar tamaño estimado automático
        layout.scrollDirection = .vertical  // Asegurar dirección vertical
        
        // Aplica la configuración del diseño a la colección
        collectionView.collectionViewLayout = layout
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        // Recarga los datos y establece el color de fondo
        collectionView.reloadData()
        collectionView.backgroundColor = .systemBackground
    }
    
    private func showTipDetail(_ tip: TipItem) {
        // Crea la vista detallada del consejo seleccionado
        let contentView = createTipDetailView(tip: tip)
        
        // Muestra la vista superpuesta con los detalles del consejo
        _ = OverlayView.showWithContent(
            contentView,
            in: self.view,
            size: CGSize(width: 300, height: 280)
        )
    }
    
    private func createTipDetailView(tip: TipItem) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        // Imagen del consejo obtenida de la API
        let iconImageView = UIImageView()
        let imageName = convertAPIImagePathToLocalName(tip.imagen ?? "/tips/tip_general")
        iconImageView.image = UIImage(named: imageName)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Etiqueta para mostrar el título del consejo con formato destacado
        let titleLabel = UILabel()
        titleLabel.text = tip.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Etiqueta para mostrar la descripción detallada del consejo
        let descriptionLabel = UILabel()
        descriptionLabel.text = tip.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .darkGray
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Botón para cerrar la vista de detalle del consejo
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Cerrar", for: .normal)
        closeButton.backgroundColor = UIColor(red: 39/255.0, green: 159/255.0, blue: 245/255.0, alpha: 1.0)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 4
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.addTarget(self, action: #selector(closeOverlay), for: .touchUpInside)
        
        // Añade todos los elementos a la vista contenedora
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(closeButton)
        
        // Configura las restricciones de posicionamiento para todos los elementos
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            closeButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 15),
            closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 35),
            closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
        return containerView
    }
    
    @objc private func closeOverlay() {
        // Busca y cierra la vista superpuesta actual cuando se presiona el botón
        if let overlay = view.subviews.first(where: { $0 is OverlayView }) as? OverlayView {
            overlay.dismiss()
        }
    }
    
    // MARK: - Image Helper Methods
    
    /// Convierte rutas de imágenes de la API a nombres de archivos locales
    private func convertAPIImagePathToLocalName(_ apiImagePath: String) -> String {
        // Remover la barra inicial si existe
        let cleanPath = apiImagePath.hasPrefix("/") ? String(apiImagePath.dropFirst()) : apiImagePath
        
        // Mapear rutas específicas a nombres de archivos locales
        switch cleanPath {
        // Tips
        case let path where path.hasPrefix("tips/"):
            return String(path.dropFirst(5)) // Remover "tips/"
        
        // Fallback: usar el nombre del archivo sin la ruta
        default:
            return cleanPath.components(separatedBy: "/").last ?? "tip_general"
        }
    }
}

// MARK: - UICollectionViewDataSource
// Implementación del protocolo para proporcionar datos a la colección

extension TipsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TipCell", for: indexPath)
        
        // Configura la celda con la información del consejo seleccionado
        let tip = tips[indexPath.item]
        
        // Limpia cualquier estilo previo aplicado a la celda
        cell.backgroundColor = .clear
        cell.tintColor = nil
        cell.layer.borderWidth = 0
        cell.layer.borderColor = UIColor.clear.cgColor
        
        // Aplica un borde gris oscuro al contenido de la celda para destacarlo
        cell.contentView.backgroundColor = .white
        cell.contentView.layer.borderWidth = 1.0  // Borde más grueso para mayor visibilidad
        cell.contentView.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor  // Gris oscuro definido explícitamente
        cell.contentView.layer.cornerRadius = 4.0  // Esquinas redondeadas
        cell.contentView.clipsToBounds = true
        
        // Localiza los elementos de la interfaz en la celda mediante sus identificadores de tag
        if let imageView = cell.contentView.viewWithTag(100) as? UIImageView {
            // Usar siempre lightbulb.fill como imagen por defecto en las celdas
            imageView.image = UIImage(systemName: "lightbulb.fill")
            imageView.tintColor = .gray
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .clear
        }
        
        if let titleLabel = cell.contentView.viewWithTag(101) as? UILabel {
            titleLabel.text = tip.title
            titleLabel.font = UIFont.boldSystemFont(ofSize: 11)
            titleLabel.textColor = .darkGray
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 4  // Permitir hasta 4 líneas
            titleLabel.lineBreakMode = .byWordWrapping  // Ajustar por palabras sin puntos suspensivos
            titleLabel.adjustsFontSizeToFitWidth = true  // Ajustar tamaño de fuente si es necesario
            titleLabel.minimumScaleFactor = 0.8  // Escala mínima para el texto
        }
        
        // No se aplican estilos adicionales a la celda principal, solo al contentView
        // Esto previene que se sobrescriban las configuraciones de estilo anteriores
        

        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
// Implementación del protocolo para manejar interacciones con la colección

extension TipsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTip = tips[indexPath.item]
        showTipDetail(selectedTip)
    }
}

// MARK: - API Methods
extension TipsViewController {

    
    private func loadTipsFromAPI() {
        APIManager.shared.getTips { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let apiTips):
                    // Convertir Tip de API a TipItem local
                    self?.tips = apiTips.map { tip in
                        return TipItem(id: tip.id, title: tip.titulo, description: tip.descripcion, imagen: tip.imagen)
                    }
                    self?.collectionView?.reloadData()
                case .failure(_):
                    // Mantener array vacío en caso de error
                    self?.tips = []
                    self?.collectionView?.reloadData()
                }
            }
        }
    }
}
