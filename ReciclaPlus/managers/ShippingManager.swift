//
//  ShippingManager.swift
//  ReciclaPlus
//
//  Created by Assistant on 2025-01-13.
//

import Foundation
import UIKit

class ShippingManager {
    static let shared = ShippingManager()
    
    private let userDefaults = UserDefaults.standard
    private let shippingsKey = "user_shippings"
    
    private init() {}
    
    // MARK: - Puntos de Recolección desde API
    private var cachedCollectionPoints: [CollectionPoint] = []
    
    func getCollectionPoints(completion: @escaping ([CollectionPoint]) -> Void) {
        // Si ya tenemos datos en caché, devolverlos inmediatamente
        if !cachedCollectionPoints.isEmpty {
            completion(cachedCollectionPoints)
            return
        }
        
        // Cargar desde API
        APIManager.shared.getPuntosRecoleccion { [weak self] result in
            switch result {
            case .success(let puntosAPI):
                let collectionPoints = puntosAPI.map { punto in
                    CollectionPoint(
                        id: punto.id,
                        name: punto.nombre,
                        address: punto.direccion,
                        latitude: punto.latitud,
                        longitude: punto.longitud
                    )
                }
                self?.cachedCollectionPoints = collectionPoints
                completion(collectionPoints)
            case .failure(_):
                // En caso de error, devolver array vacío
                completion([])
            }
        }
    }
    
    // Método síncrono para compatibilidad con código existente
    func getCollectionPoints() -> [CollectionPoint] {
        return cachedCollectionPoints
    }
    
    // MARK: - Gestión de Envíos
    func createShipping(for collectionPointId: String, userId: String) -> Shipping {
        let shipping = Shipping(collectionPointId: collectionPointId, userId: userId)
        saveShipping(shipping)
        return shipping
    }
    
    func saveShipping(_ shipping: Shipping) {
        var shippings = getUserShippings(for: shipping.userId)
        shippings.append(shipping)
        
        if let encoded = try? JSONEncoder().encode(shippings) {
            userDefaults.set(encoded, forKey: "\(shippingsKey)_\(shipping.userId)")
        }
    }
    
    func getUserShippings(userId: String) -> [Shipping] {
        return getUserShippings(for: userId)
    }
    
    // Método de conveniencia para obtener envíos del usuario actual logueado
    func getCurrentUserShippings() -> [Shipping] {
        let userId = UserManager.shared.getUserEmail()
        return getUserShippings(for: userId)
    }
    
    // Método de conveniencia para verificar si el usuario actual puede crear envíos
    func canCurrentUserCreateNewShipping() -> Bool {
        let userId = UserManager.shared.getUserEmail()
        return canCreateNewShipping(for: userId)
    }
    
    // Método de conveniencia para obtener envíos activos del usuario actual
    func getCurrentUserActiveShippingsCount() -> Int {
        let userId = UserManager.shared.getUserEmail()
        return getActiveShippingsCount(for: userId)
    }
    
    func getUserShippings(for userId: String) -> [Shipping] {
        guard let data = userDefaults.data(forKey: "\(shippingsKey)_\(userId)"),
              let shippings = try? JSONDecoder().decode([Shipping].self, from: data) else {
            return []
        }
        
        // Actualizar estados basados en fecha actual
        var updatedShippings = shippings
        for i in 0..<updatedShippings.count {
            updatedShippings[i].updateStatus()
        }
        
        // Guardar estados actualizados
        if let encoded = try? JSONEncoder().encode(updatedShippings) {
            userDefaults.set(encoded, forKey: "\(shippingsKey)_\(userId)")
        }
        
        return updatedShippings.sorted { $0.createdAt > $1.createdAt }
    }
    
    func updateShippingStatus(_ shipping: inout Shipping, to status: ShippingStatus) {
        shipping.status = status
        saveUpdatedShipping(shipping)
    }
    
    private func saveUpdatedShipping(_ updatedShipping: Shipping) {
        var shippings = getUserShippings(for: updatedShipping.userId)
        
        if let index = shippings.firstIndex(where: { $0.id == updatedShipping.id }) {
            shippings[index] = updatedShipping
            
            if let encoded = try? JSONEncoder().encode(shippings) {
                userDefaults.set(encoded, forKey: "\(shippingsKey)_\(updatedShipping.userId)")
            }
        }
    }
    
    // MARK: - Utilidades
    func getCollectionPoint(by id: String) -> CollectionPoint? {
        return getCollectionPoints().first { $0.id == id }
    }
    
    func getCollectionPoint(by id: String, completion: @escaping (CollectionPoint?) -> Void) {
        getCollectionPoints { collectionPoints in
            let collectionPoint = collectionPoints.first { $0.id == id }
            completion(collectionPoint)
        }
    }
    
    func hasActiveShippings(for userId: String) -> Bool {
        let shippings = getUserShippings(for: userId)
        return shippings.contains { $0.status == .pending }
    }
    
    func getActiveShippingsCount(for userId: String) -> Int {
        let shippings = getUserShippings(for: userId)
        return shippings.filter { $0.status == .pending }.count
    }
    
    // MARK: - Validaciones
    func canCreateNewShipping(for userId: String) -> Bool {
        let activeCount = getActiveShippingsCount(for: userId)
        return activeCount < 3 // Límite de 3 envíos activos por usuario
    }
    
    func isUserAuthenticated() -> Bool {
        // Verificar si el usuario está autenticado con Google
        return UserManager.shared.getIsLoggedIn()
    }
    
    func validateShippingCode(_ code: String, for userId: String) -> Shipping? {
        let shippings = getUserShippings(for: userId)
        return shippings.first { $0.code == code }
    }
    
    func deleteShipping(_ code: String, for userId: String) {
        // Obtener todos los envíos del usuario especificado
        var shippings = getUserShippings(for: userId)
        
        // Filtrar para eliminar el envío con el código especificado
        shippings.removeAll { $0.code == code }
        
        // Guardar la lista actualizada
        if let encoded = try? JSONEncoder().encode(shippings) {
            userDefaults.set(encoded, forKey: "\(shippingsKey)_\(userId)")
        }
    }
}

// MARK: - Extensiones para UI
extension ShippingManager {
    func showShippingLimitAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Límite alcanzado",
            message: "Ya tienes el máximo de envíos activos permitidos (3). Espera a que venzan o sean entregados para crear nuevos envíos.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        viewController.present(alert, animated: true)
    }
    
    func showAuthenticationRequiredAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Autenticación requerida",
            message: "Debes iniciar sesión con Google para acceder al servicio de envíos.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Iniciar sesión", style: .default) { _ in
            // Aquí se puede implementar la lógica de autenticación
            // Por ahora, redirigir al perfil
            if let tabBarController = viewController.tabBarController {
                tabBarController.selectedIndex = 3 // Índice del perfil
            }
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        viewController.present(alert, animated: true)
    }
}