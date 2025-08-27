//
//  EventosViewController.swift
//  ReciclaPlus
//
//  Created by MacOS on 20/08/25.
//

import UIKit

// Estructura que define un evento con identificador, título, descripción, fecha y estado
struct EventoItem {
    let id: Int
    let titulo: String
    let descripcion: String
    let fecha: String
    let estado: String // "Próximo", "Finalizado", etc.
    let imagen: String // Nombre de la imagen
}

class EventosViewController: UIViewController {

    // Declaración del tableView como una propiedad normal en lugar de un IBOutlet
    private var tableView: UITableView!
    
    // Array de eventos desde API
    private var eventos: [EventoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAvatar()
        setupNotifications()
        loadEventosFromAPI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Inicializar y configurar el tableView después de que la vista haya sido cargada completamente
        if tableView == nil {
            initializeTableView()
            ordenarEventosPorEstado() // Ordenar eventos antes de configurar la tabla
            setupTableView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Actualizar el orden de los eventos cada vez que la vista aparece
        ordenarEventosPorEstado()
        tableView?.reloadData()
    }
    
    // Método para ordenar los eventos según su estado (próximos primero, finalizados después)
    private func ordenarEventosPorEstado() {
        let fechaActual = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "es_ES")
        
        // Crear un diccionario para almacenar las fechas convertidas y evitar múltiples conversiones
        var fechasConvertidas: [Int: Date] = [:]
        
        // Convertir todas las fechas de texto a objetos Date para facilitar la comparación
        for i in 0..<eventos.count {
            if let fechaEvento = dateFormatter.date(from: eventos[i].fecha) {
                fechasConvertidas[eventos[i].id] = fechaEvento
                
                // Si la fecha del evento es anterior a la fecha actual, marcar como finalizado
                if fechaEvento < fechaActual {
                    eventos[i] = EventoItem(
                        id: eventos[i].id,
                        titulo: eventos[i].titulo,
                        descripcion: eventos[i].descripcion,
                        fecha: eventos[i].fecha,
                        estado: "Finalizado",
                        imagen: eventos[i].imagen
                    )
                } else {
                    // Si la fecha es futura, marcar como próximo
                    eventos[i] = EventoItem(
                        id: eventos[i].id,
                        titulo: eventos[i].titulo,
                        descripcion: eventos[i].descripcion,
                        fecha: eventos[i].fecha,
                        estado: "Próximo",
                        imagen: eventos[i].imagen
                    )
                }
            }
        }
        
        // Ordenar eventos: primero los próximos, luego los finalizados
        eventos.sort { (evento1, evento2) -> Bool in
            // Si uno es próximo y el otro finalizado, el próximo va primero
            if evento1.estado == "Próximo" && evento2.estado == "Finalizado" {
                return true
            } else if evento1.estado == "Finalizado" && evento2.estado == "Próximo" {
                return false
            } else {
                // Obtener las fechas convertidas del diccionario
                guard let fecha1 = fechasConvertidas[evento1.id] else {
                    // Si no se puede obtener la fecha, usar la conversión directa
                    let fechaDirecta1 = dateFormatter.date(from: evento1.fecha) ?? fechaActual
                    let fechaDirecta2 = dateFormatter.date(from: evento2.fecha) ?? fechaActual
                    
                    // Comparar según el estado
                    if evento1.estado == "Próximo" {
                        return fechaDirecta1 > fechaDirecta2 // Fechas más lejanas primero
                    } else {
                        return fechaDirecta1 > fechaDirecta2 // Fechas más recientes primero
                    }
                }
                
                guard let fecha2 = fechasConvertidas[evento2.id] else {
                    // Si no se puede obtener la fecha, usar la conversión directa
                    let fechaDirecta1 = dateFormatter.date(from: evento1.fecha) ?? fechaActual
                    let fechaDirecta2 = dateFormatter.date(from: evento2.fecha) ?? fechaActual
                    
                    // Comparar según el estado
                    if evento1.estado == "Próximo" {
                        return fechaDirecta1 > fechaDirecta2 // Fechas más lejanas primero
                    } else {
                        return fechaDirecta1 > fechaDirecta2 // Fechas más recientes primero
                    }
                }
                
                // Extraer componentes de año para verificar
                let calendar = Calendar.current
                let año1 = calendar.component(.year, from: fecha1)
                let año2 = calendar.component(.year, from: fecha2)
                
                // Comparar según el estado y considerando explícitamente el año
                if evento1.estado == "Próximo" {
                    // Para eventos próximos, primero ordenar por año y luego por fecha completa
                    if año1 != año2 {
                        return año1 > año2 // Años más lejanos primero (2026 antes que 2025)
                    } else {
                        return fecha1 > fecha2 // Mismos años, fechas más lejanas primero
                    }
                } else {
                    // Para eventos finalizados, ordenar por fecha descendente (más recientes primero)
                    if año1 != año2 {
                        return año1 > año2 // Años más recientes primero
                    } else {
                        return fecha1 > fecha2 // Mismos años, fechas más recientes primero
                    }
                }
            }
        }
    }
    
    private func initializeTableView() {
        // Buscar el tableView existente en el storyboard con ID "nP8-rH-0nl"
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
        tableView = UITableView(frame: CGRect(x: 16, y: 162, width: view.bounds.width - 32, height: 550), style: .grouped) // Cambiar a estilo grouped para mejor espaciado entre secciones
        tableView.rowHeight = 111 // Misma altura que en el storyboard
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
    
    private func setupTableView() {
        // Configurar la tabla de eventos
        tableView.delegate = self
        tableView.dataSource = self
        
        // Si estamos usando un tableView creado programáticamente, registrar la celda
        if tableView.dequeueReusableCell(withIdentifier: "HomeCell") == nil {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HomeCell")
        }
        
        // Configuración adicional
        tableView.separatorStyle = .none // Quitamos el separador predeterminado
        tableView.backgroundColor = .systemBackground
        
        // Eliminar el fondo de grupo predeterminado pero mantener el espaciado
        tableView.backgroundView = nil
        tableView.backgroundColor = .systemBackground
        
        // Configurar espaciado entre celdas reducido
        tableView.contentInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        
        // Configuración explícita para el espaciado entre secciones
        tableView.sectionFooterHeight = 1.0
        tableView.sectionHeaderHeight = 0.01
        
        // Recargar datos
        tableView.reloadData()
    }
    
    private func showEventoDetail(_ evento: EventoItem) {
        // Crear contenido para el overlay
        let contentView = createEventoDetailView(evento: evento)
        
        // Mostrar overlay con el contenido
        _ = OverlayView.showWithContent(
            contentView,
            in: self.view,
            size: CGSize(width: 360, height: 360)
        )
    }
    
    // Método para formatear la fecha de "10/12/2025" a "10 de diciembre, 2025"
    private func formatearFecha(_ fechaString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "es_ES")
        
        guard let fecha = dateFormatter.date(from: fechaString) else {
            return fechaString // Si hay error, devolver la fecha original
        }
        
        // Cambiar el formato para mostrar
        dateFormatter.dateFormat = "d 'de' MMMM, yyyy"
        return dateFormatter.string(from: fecha)
    }
    
    private func createEventoDetailView(evento: EventoItem) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        // Icono del evento
        let iconImageView = UIImageView()
        // Usar la imagen de la API convertida a nombre local, o imagen por defecto
        let imageName = convertAPIImagePathToLocalName(evento.imagen)
        iconImageView.image = UIImage(named: imageName) ?? UIImage(named: "evento_general")
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Título del evento
        let titleLabel = UILabel()
        titleLabel.text = evento.titulo
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Fecha del evento - Convertir al formato "10 de diciembre, 2025"
        let fechaLabel = UILabel()
        fechaLabel.text = formatearFecha(evento.fecha)
        fechaLabel.font = UIFont.systemFont(ofSize: 14)
        fechaLabel.textAlignment = .center
        fechaLabel.textColor = .systemBlue
        fechaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Estado del evento
        let estadoLabel = UILabel()
        estadoLabel.text = evento.estado
        estadoLabel.font = UIFont.boldSystemFont(ofSize: 14)
        estadoLabel.textAlignment = .center
        estadoLabel.textColor = evento.estado == "Próximo" ? .systemGreen : .systemRed
        estadoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Descripción del evento
        let descriptionLabel = UILabel()
        descriptionLabel.text = evento.descripcion
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 5 // Permitir hasta 5 líneas para la descripción
        descriptionLabel.textColor = .darkGray
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Botón cerrar
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Cerrar", for: .normal)
        closeButton.backgroundColor = UIColor(red: 39/255.0, green: 159/255.0, blue: 245/255.0, alpha: 1.0)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 4
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.addTarget(self, action: #selector(closeOverlay), for: .touchUpInside)
        
        // Añadir subvistas
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(fechaLabel)
        containerView.addSubview(estadoLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(closeButton)
        
        // Configurar constraints
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 152),
            iconImageView.heightAnchor.constraint(equalToConstant: 114),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            fechaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            fechaLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            fechaLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            estadoLabel.topAnchor.constraint(equalTo: fechaLabel.bottomAnchor, constant: 5),
            estadoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            estadoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: estadoLabel.bottomAnchor, constant: 10),
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
        // Buscar y cerrar el overlay actual
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
        // Eventos
        case let path where path.hasPrefix("eventos/"):
            return String(path.dropFirst(8)) // Remover "eventos/"
        
        // Fallback: usar el nombre del archivo sin la ruta
        default:
            return cleanPath.components(separatedBy: "/").last ?? "evento_general"
        }
    }
}

// MARK: - UITableViewDataSource

extension EventosViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return eventos.count // Cada evento tendrá su propia sección
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Una celda por sección
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath)
        
        // Configurar la celda con el evento
        let evento = eventos[indexPath.section] // Usar section en lugar de row
        
        // Aplicar estilo a la celda: borde gris, esquinas redondeadas
        cell.contentView.backgroundColor = .white
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor
        cell.contentView.layer.cornerRadius = 5.0 // Cambio a radio de 5 puntos
        cell.contentView.clipsToBounds = true
        
        // Agregar margen a la celda para que se vea el espaciado
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cell.contentView.frame = cell.contentView.frame.inset(by: margins)
        cell.selectionStyle = .none
        
        // Convertir la fecha de formato "10/12/2025" a "10 de diciembre, 2025"
        let fechaFormateada = formatearFecha(evento.fecha)
        
        // Configurar los elementos de la celda de manera más robusta
        // Primero, asegurarnos de que la celda tenga contenido
        guard cell.contentView.subviews.count >= 3 else {
            // Si la celda no tiene suficientes subvistas, crear una celda básica
            cell.textLabel?.text = evento.titulo
            cell.detailTextLabel?.text = fechaFormateada
            return cell
        }
        
        // Configurar imagen
        let imageViews = cell.contentView.subviews.compactMap { $0 as? UIImageView }
        if let imageView = imageViews.first {
            // Usar la imagen de la API convertida a nombre local, o imagen por defecto
            let imageName = convertAPIImagePathToLocalName(evento.imagen)
            imageView.image = UIImage(named: imageName) ?? UIImage(named: "evento_general")
            imageView.contentMode = .scaleAspectFit
            // Asegurar que la imagen no se sobreponga con el texto
            imageView.clipsToBounds = true
            // Ajustar el tamaño de la imagen si es necesario
            if imageView.frame.width > 80 {
                let newFrame = CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y, 
                                     width: 80, height: imageView.frame.height)
                imageView.frame = newFrame
            }
        }
        
        // Configurar etiquetas - Buscar todas las etiquetas en la celda
        let labels = cell.contentView.subviews.compactMap { $0 as? UILabel }
        
        // Asegurarse de que tenemos suficientes etiquetas
        if labels.count >= 2 {
            // Intercambiamos el orden: la primera etiqueta es para la fecha
            labels[0].text = fechaFormateada
            labels[0].font = UIFont.systemFont(ofSize: 14)
            labels[0].numberOfLines = 1 // Limitar a una línea
            labels[0].lineBreakMode = .byTruncatingTail // Puntos suspensivos al final
            
            // La segunda etiqueta es para el título
            labels[1].text = evento.titulo
            labels[1].font = UIFont.boldSystemFont(ofSize: 16)
            labels[1].numberOfLines = 2 // Permitir hasta 2 líneas
            labels[1].lineBreakMode = .byTruncatingTail // Puntos suspensivos al final
            labels[1].textAlignment = .left // Alineación a la izquierda
        }
        
        // Estado (generalmente la etiqueta con fondo de color)
        if let statusLabel = labels.first(where: { $0.backgroundColor != nil && $0.backgroundColor != .clear }) {
            statusLabel.text = evento.estado
            statusLabel.backgroundColor = evento.estado == "Próximo" ? .systemGreen : .systemRed
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension EventosViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedEvento = eventos[indexPath.section] // Usar section en lugar de row
        showEventoDetail(selectedEvento)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0 // Altura fija de 110 puntos para cada celda
    }
    
    // Espacio vertical entre celdas similar a TipsViewController (10 puntos)
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    // Método para agregar espacio entre celdas
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.0 // Espacio vertical de 2 puntos entre celdas
    }
    
    // Asegurar que no haya espacio en el header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01 // Prácticamente sin espacio para el header
    }
}

// MARK: - API Methods
extension EventosViewController {
    private func loadEventosFromAPI() {
        APIManager.shared.getEventos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let apiEventos):
                    // Convertir Evento de API a EventoItem local
                    self?.eventos = apiEventos.map { evento in
                        EventoItem(id: evento.id, titulo: evento.titulo, descripcion: evento.descripcion, fecha: evento.fecha, estado: evento.estado, imagen: self?.convertAPIImagePathToLocalName(evento.imagen) ?? "ic_eventos_600_400")
                    }
                    self?.ordenarEventosPorEstado()
                    self?.tableView?.reloadData()
                case .failure(_):
                    // Mantener array vacío en caso de error
                    self?.eventos = []
                }
            }
        }
    }
}
