//
//  LogrosViewController.swift
//  ReciclaPlus
//
//  Created by MacOS on 20/08/25.
//

import UIKit

// Estructura que define un logro con identificador, título, descripción, imagen y estado
struct LogroItem {
    let id: Int
    let titulo: String
    let descripcion: String
    let imageName: String
    let requisito: String
    var completado: Bool
    
    // Convertir a diccionario para almacenamiento
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "titulo": titulo,
            "descripcion": descripcion,
            "imageName": imageName,
            "requisito": requisito,
            "completado": completado
        ]
    }
    
    // Crear desde diccionario
    static func fromDictionary(_ dict: [String: Any]) -> LogroItem? {
        guard let id = dict["id"] as? Int,
              let titulo = dict["titulo"] as? String,
              let descripcion = dict["descripcion"] as? String,
              let imageName = dict["imageName"] as? String,
              let requisito = dict["requisito"] as? String,
              let completado = dict["completado"] as? Bool else {
            return nil
        }
        
        return LogroItem(id: id, titulo: titulo, descripcion: descripcion, 
                        imageName: imageName, requisito: requisito, completado: completado)
    }
}

class LogrosViewController: UIViewController {

    @IBOutlet var tableView: UITableView! {
        didSet {
    
        }
    }
    
    // Array de logros desde API
    private var logros: [LogroItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAvatar()
        setupNotifications()
        setupNavigationBar()
        
        // Cargar logros desde API
        loadLogrosFromAPI()
        
        // Verificar si el usuario está logueado con Google
        if !UserManager.shared.getIsLoggedIn() {
            // Si es invitado, mostrar la vista de perfil para iniciar sesión
            showLoginProfile()
        } else {
            // Cargar los logros completados del usuario actual
            loadUserAchievements()
        }
    }
    
    // Método para mostrar la vista de perfil para iniciar sesión
    private func showLoginProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewPerfil = storyboard.instantiateViewController(withIdentifier: "YID-Ks-zeR") as? PerfilViewController {
            viewPerfil.modalPresentationStyle = .pageSheet
            viewPerfil.modalTransitionStyle = .coverVertical
            present(viewPerfil, animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Inicializar y configurar el tableView después de que la vista haya sido cargada completamente
        if tableView == nil {
            initializeTableView()
            if tableView != nil { // Verificar que tableView se haya inicializado correctamente
                setupTableView()
            }
        }
    }
    
    private func setupNavigationBar() {
        // Configurar título de la navegación
        title = ""
        
        // Agregar botón para simular activación de logro (solo para demostración)
        let simulateButton = UIBarButtonItem(title: "Simular", style: .plain, target: self, action: #selector(simulateAchievement))
        
        // Configurar el botón en la barra de navegación
        navigationItem.leftBarButtonItem = simulateButton
    }
    
    @objc private func simulateAchievement() {
        // Mostrar opciones para simular la activación de un logro
        let alertController = UIAlertController(title: "Simular Logro", message: "Selecciona un logro para activar", preferredStyle: .actionSheet)
        
        // Agregar una acción por cada logro disponible
        for (index, logro) in logros.enumerated() {
            let statusText = logro.completado ? "Desactivar" : "Activar"
            let actionTitle = "\(logro.titulo) - \(statusText)"
            let action = UIAlertAction(title: actionTitle, style: .default) { [weak self] _ in
                self?.toggleLogroStatus(at: index)
            }
            alertController.addAction(action)
        }
        
        // Agregar opción para probar la persistencia
        alertController.addAction(UIAlertAction(title: "Probar Persistencia", style: .default) { [weak self] _ in
            self?.testAchievementPersistence()
        })
        
        // Agregar opción para cancelar
        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        // Presentar el controlador de alerta
        present(alertController, animated: true, completion: nil)
    }
    
    // Método para probar la persistencia de logros entre diferentes usuarios
    @objc func testAchievementPersistence() {
        guard UserManager.shared.getIsLoggedIn() else {
    
            return
        }
        
        let email = UserManager.shared.getUserEmail()
        
        // Mostrar los logros completados del usuario actual
        let completedIds = AchievementManager.shared.getCompletedAchievementIds(forUser: email)
        
        // Verificar que los logros mostrados en la interfaz coincidan con los guardados
        var uiCompletedIds: [Int] = []
        for logro in logros where logro.completado {
            uiCompletedIds.append(logro.id)
        }
        
        // Verificar si coinciden
        _ = Set(completedIds) == Set(uiCompletedIds)
    }
    
    private func setupAvatar() {
        // Crear y configurar el avatar como botón de navegación
        let avatarBarButtonItem = UserManager.shared.createAvatarBarButtonItem(
            target: self,
            action: #selector(avatarButtonTapped(_:))
        )
        navigationItem.rightBarButtonItem = avatarBarButtonItem
    }
    
    private func initializeTableView() {
        // Buscar el tableView existente en el storyboard
        // Primero, buscar directamente en las subvistas
        for subview in view.subviews {
            if let table = subview as? UITableView {
                tableView = table
        
                return
            }
        }
        
        // Si no se encuentra, buscar recursivamente
        tableView = findTableViewRecursively(in: view)
        if tableView != nil {
    
            return
        }
        
        // Si aún no se encuentra, crear uno nuevo

        tableView = UITableView(frame: CGRect(x: 16, y: 162, width: view.bounds.width - 32, height: 550), style: .grouped)
        tableView.rowHeight = 150 // Altura fija para cada celda
        view.addSubview(tableView)
    }
    
    private func findTableViewRecursively(in view: UIView) -> UITableView? {
        // Buscar en las subvistas directas
        for subview in view.subviews {
            if let tableView = subview as? UITableView {
                return tableView
            }
            
            // Buscar recursivamente en las subvistas
            if let tableView = findTableViewRecursively(in: subview) {
                return tableView
            }
        }
        
        return nil
    }
    
    private func setupTableView() {
        // No registramos la celda porque ya está definida en el storyboard
        // tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TipCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        
        // Configurar estilo de la tabla para mostrar secciones
        // La propiedad style solo se puede establecer en el inicializador
        tableView.sectionHeaderHeight = 0.01 // Minimizar el header
        tableView.sectionFooterHeight = 10 // Espacio entre celdas
        
        // Añadir padding alrededor de la tabla
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        // Imprimir información de depuración


        
        // Forzar recarga de datos
        tableView.reloadData()
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
 }
 
 // MARK: - UITableViewDataSource
extension LogrosViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return logros.count // Cada logro en su propia sección
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Una fila por sección
    }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Crear una nueva celda cada vez para evitar problemas de reutilización
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TipCell")
        
        // Obtener el logro correspondiente a esta sección
        let logro = logros[indexPath.section] // Usar section en lugar de row

        
        // Calcular la altura de la celda para centrar verticalmente
        let cellHeight: CGFloat = 150 // Usar la altura fija de la celda
        let contentHeight: CGFloat = 120 // Altura aproximada del contenido (imagen + textos + barra)
        let verticalOffset = max(0, (cellHeight - contentHeight) / 2)
        
        // Crear y configurar la imagen
        let imageView = UIImageView(frame: CGRect(x: 10, y: verticalOffset + 10, width: 80, height: 80))
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.tag = 100
        
        // Usar achievement_success para logros completados, o la imagen original para pendientes
        let imageName = logro.completado ? "achievement_success" : logro.imageName
        imageView.image = UIImage(named: imageName)
        imageView.alpha = logro.completado ? 1.0 : 0.5
        cell.contentView.addSubview(imageView)
        
        // Crear y configurar el título
        let titleLabel = UILabel(frame: CGRect(x: 100, y: verticalOffset + 10, width: cell.contentView.bounds.width - 110, height: 30))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        titleLabel.text = logro.titulo
        titleLabel.tag = 101
        cell.contentView.addSubview(titleLabel)

        
        // Crear y configurar la descripción
        let descriptionLabel = UILabel(frame: CGRect(x: 100, y: verticalOffset + 45, width: cell.contentView.bounds.width - 110, height: 60))
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 3
        descriptionLabel.text = logro.descripcion
        descriptionLabel.tag = 102
        cell.contentView.addSubview(descriptionLabel)

        
        // Crear y configurar la barra de progreso
        let progressView = UIProgressView(frame: CGRect(x: 100, y: verticalOffset + 110, width: cell.contentView.bounds.width - 120, height: 10))
        progressView.progress = logro.completado ? 1.0 : 0.0
        progressView.progressTintColor = logro.completado ? UIColor.green : UIColor.blue
        progressView.tag = 103
        cell.contentView.addSubview(progressView)
        
        // Configurar la celda con un estilo personalizado
        cell.selectionStyle = .none
        
        // Agregar borde gris de 1 punto con bordes redondeados de 4 puntos
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.cornerRadius = 4.0
        cell.layer.masksToBounds = true
        
        // También aplicar borde al contentView para asegurar visibilidad
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.masksToBounds = true
        
        // Agregar un poco de margen interno para que el contenido no toque el borde
        cell.contentView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        // Establecer color de fondo según estado del logro
        if logro.completado {
            cell.contentView.backgroundColor = .white // Fondo blanco para logros completados
        } else {
            cell.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2) // Fondo gris para logros pendientes
        }
        
        return cell
     }
 }
 
 // MARK: - UITableViewDelegate
  extension LogrosViewController: UITableViewDelegate {
      func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150 // Aumentar altura fija para cada celda
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Crear un espacio vacío para separación vertical
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10 // Altura del espacio de separación
    }
      
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Mostrar detalles del logro en un overlay
        let logro = logros[indexPath.section] // Usar section en lugar de row
        showLogroDetails(logro: logro)
    }
      
      private func showLogroDetails(logro: LogroItem) {
          // Crear un overlay para mostrar detalles del logro
          let overlayView = OverlayView(frame: view.bounds)
          
          // Crear el contenido del overlay
          let contentView = createLogroDetailView(logro: logro)
          
          // Ajustar el tamaño del contenedor para acomodar el contenido adicional
          overlayView.updateContainerSize(width: 320, height: 550)
          
          // Agregar el contenido al overlay
          overlayView.addContentView(contentView)
          
          // Mostrar el overlay con animación
          overlayView.show(in: view)
      }
      
      private func createLogroDetailView(logro: LogroItem) -> UIView {
          // Crear un contenedor para el detalle del logro
          let containerView = UIView()
          containerView.backgroundColor = .white
          containerView.translatesAutoresizingMaskIntoConstraints = false
          
          // Agregar borde y esquinas redondeadas al contenedor
          containerView.layer.borderWidth = 1.0
          containerView.layer.borderColor = UIColor.lightGray.cgColor
          containerView.layer.cornerRadius = 8.0
          containerView.layer.masksToBounds = true
          
          // Crear imagen del logro
          let imageView = UIImageView()
          // Usar achievement_success para logros completados, o la imagen original para pendientes
          let imageName = logro.completado ? "achievement_success" : logro.imageName
          imageView.image = UIImage(named: imageName)
          imageView.contentMode = .scaleAspectFit
          imageView.translatesAutoresizingMaskIntoConstraints = false
          imageView.alpha = logro.completado ? 1.0 : 0.5
          containerView.addSubview(imageView)
          
          // Crear título del logro
          let titleLabel = UILabel()
          titleLabel.text = logro.titulo
          titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
          titleLabel.textColor = logro.completado ? UIColor.blue : UIColor.gray
          titleLabel.textAlignment = .center
          titleLabel.translatesAutoresizingMaskIntoConstraints = false
          containerView.addSubview(titleLabel)
          
          // Crear descripción del logro con al menos 3 líneas
          let descriptionLabel = UILabel()
          descriptionLabel.text = logro.descripcion
          descriptionLabel.font = UIFont.systemFont(ofSize: 16)
          descriptionLabel.textColor = .darkGray
          descriptionLabel.textAlignment = .center
          descriptionLabel.numberOfLines = 0 // Permitir múltiples líneas
          descriptionLabel.lineBreakMode = .byWordWrapping
          descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
          containerView.addSubview(descriptionLabel)
          
          // Crear un contenedor para la descripción detallada
          let detailDescriptionView = UIView()
          detailDescriptionView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
          detailDescriptionView.layer.cornerRadius = 4.0
          detailDescriptionView.translatesAutoresizingMaskIntoConstraints = false
          containerView.addSubview(detailDescriptionView)
          
          // Crear etiqueta para la descripción detallada
          let detailDescriptionLabel = UILabel()
          detailDescriptionLabel.text = "Para obtener este logro debes: \n\n" + logro.requisito
          detailDescriptionLabel.font = UIFont.systemFont(ofSize: 14)
          detailDescriptionLabel.textColor = .darkGray
          detailDescriptionLabel.textAlignment = .left
          detailDescriptionLabel.numberOfLines = 5 // Permitir al menos 5 líneas
          detailDescriptionLabel.lineBreakMode = .byWordWrapping
          detailDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
          detailDescriptionView.addSubview(detailDescriptionLabel)
          
          // Crear etiqueta de requisito
          let requisitoLabel = UILabel()
          requisitoLabel.text = "Requisito: " + logro.requisito
          requisitoLabel.font = UIFont.systemFont(ofSize: 14, weight: logro.completado ? .bold : .medium)
          requisitoLabel.textColor = logro.completado ? UIColor.green : UIColor.gray
          requisitoLabel.textAlignment = .center
          requisitoLabel.numberOfLines = 8 // Permitir al menos 5 líneas
          requisitoLabel.translatesAutoresizingMaskIntoConstraints = false
          containerView.addSubview(requisitoLabel)
          
          // Crear etiqueta de estado
          let estadoLabel = UILabel()
          estadoLabel.text = logro.completado ? "Estado: Completado" : "Estado: Pendiente"
          estadoLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
          estadoLabel.textColor = logro.completado ? UIColor.green : UIColor.orange
          estadoLabel.textAlignment = .center
          estadoLabel.translatesAutoresizingMaskIntoConstraints = false
          containerView.addSubview(estadoLabel)
          
          // Crear botón para cerrar
          let closeButton = UIButton(type: .system)
          closeButton.setTitle("Cerrar", for: .normal)
          closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
          closeButton.backgroundColor = UIColor(red: 39/255.0, green: 159/255.0, blue: 245/255.0, alpha: 1.0)
          closeButton.setTitleColor(.white, for: .normal)
          closeButton.layer.cornerRadius = 8
          closeButton.translatesAutoresizingMaskIntoConstraints = false
          closeButton.addTarget(self, action: #selector(dismissOverlay(_:)), for: .touchUpInside)
          containerView.addSubview(closeButton)
          

          
          // Configurar restricciones
          NSLayoutConstraint.activate([
              imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
              imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
              imageView.widthAnchor.constraint(equalToConstant: 100),
              imageView.heightAnchor.constraint(equalToConstant: 100),
              
              titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
              titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
              titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
              
              descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
              descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
              descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
              
              detailDescriptionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
              detailDescriptionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
              detailDescriptionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
              
              detailDescriptionLabel.topAnchor.constraint(equalTo: detailDescriptionView.topAnchor, constant: 12),
              detailDescriptionLabel.leadingAnchor.constraint(equalTo: detailDescriptionView.leadingAnchor, constant: 12),
              detailDescriptionLabel.trailingAnchor.constraint(equalTo: detailDescriptionView.trailingAnchor, constant: -12),
              detailDescriptionLabel.bottomAnchor.constraint(equalTo: detailDescriptionView.bottomAnchor, constant: -12),
              
              requisitoLabel.topAnchor.constraint(equalTo: detailDescriptionView.bottomAnchor, constant: 16),
              requisitoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
              requisitoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
              requisitoLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
              
              estadoLabel.topAnchor.constraint(equalTo: requisitoLabel.bottomAnchor, constant: 8),
              estadoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
              estadoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
              
              closeButton.topAnchor.constraint(equalTo: estadoLabel.bottomAnchor, constant: 24),
              closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
              closeButton.widthAnchor.constraint(equalToConstant: 200),
              closeButton.heightAnchor.constraint(equalToConstant: 44),
              closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
          ])
          
          return containerView
      }
      
      @objc private func dismissOverlay(_ sender: UIButton) {
          // Buscar y cerrar el overlay
          for subview in view.subviews {
              if let overlay = subview as? OverlayView {
                  overlay.dismiss()
                  break
              }
          }
      }
      
      // Método para actualizar el estado de un logro y guardarlo en persistencia
      func toggleLogroStatus(at index: Int) {
          var logro = logros[index]
          logro.completado = !logro.completado
          logros[index] = logro
          
          // Guardar el cambio en la persistencia si el usuario está logueado
          if UserManager.shared.getIsLoggedIn() {
              let email = UserManager.shared.getUserEmail()
              AchievementManager.shared.updateAchievement(
                  id: logro.id,
                  completed: logro.completado,
                  forUser: email
              )
          }
          
          tableView?.reloadSections(IndexSet(integer: index), with: .automatic)
      }
      
      // Método para cargar logros desde API
       private func loadLogrosFromAPI() {
           APIManager.shared.getLogros { [weak self] result in
               DispatchQueue.main.async {
                   switch result {
                   case .success(let logrosFromAPI):
                       // Convertir Logro de API a LogroItem local
                       self?.logros = logrosFromAPI.map { logro in
                           LogroItem(id: logro.id, titulo: logro.titulo, descripcion: logro.descripcion, imageName: self?.convertAPIImagePathToLocalName(logro.imagen) ?? "logro_success", requisito: logro.requisito, completado: logro.completado)
                       }
                       self?.loadUserAchievements()
                   case .failure(_):
                       // Mantener array vacío en caso de error
                       self?.logros = []
                   }
               }
           }
       }
      

      
      // MARK: - Image Helper Methods
      
      /// Convierte rutas de imágenes de la API a nombres de archivos locales
      private func convertAPIImagePathToLocalName(_ apiImagePath: String) -> String {
          // Remover la barra inicial si existe
          let cleanPath = apiImagePath.hasPrefix("/") ? String(apiImagePath.dropFirst()) : apiImagePath
          
          // Mapear rutas específicas a nombres de archivos locales
          switch cleanPath {
          // Logros
          case let path where path.hasPrefix("logros/"):
              return String(path.dropFirst(7)) // Remover "logros/"
          
          // Fallback: usar el nombre del archivo sin la ruta
          default:
              return cleanPath.components(separatedBy: "/").last ?? "logro_success"
          }
      }
      
      // Método para cargar los logros completados del usuario actual
      private func loadUserAchievements() {
          if UserManager.shared.getIsLoggedIn() {
              let email = UserManager.shared.getUserEmail()
              let completedIds = AchievementManager.shared.getCompletedAchievementIds(forUser: email)
              
              // Actualizar el estado de los logros según los IDs completados
              for (index, var logro) in logros.enumerated() {
                  logro.completado = completedIds.contains(logro.id)
                  logros[index] = logro
              }
          }
          
          // Recargar la tabla para mostrar los cambios
          tableView?.reloadData()
      }
  }
