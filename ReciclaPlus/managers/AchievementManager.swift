//
//  AchievementManager.swift
//  ReciclaPlus
//
//  Created by MacOS on 20/08/25.
//

import Foundation

// Estructura para almacenar el estado de un logro
struct AchievementStatus: Codable {
    let id: Int
    var completado: Bool
    
    init(id: Int, completado: Bool) {
        self.id = id
        self.completado = completado
    }
}

// Clase para gestionar la persistencia de los logros por usuario
class AchievementManager {
    static let shared = AchievementManager()
    
    private init() {}
    
    // Clave base para UserDefaults
    private let achievementsKey = "user_achievements"
    
    // Obtener la clave específica para un usuario
    private func getKeyForUser(_ email: String) -> String {
        return "\(achievementsKey)_\(email)"
    }
    
    // Guardar el estado de los logros para un usuario específico
    func saveAchievements(achievements: [AchievementStatus], forUser email: String) {
        do {
            let data = try JSONEncoder().encode(achievements)
            UserDefaults.standard.set(data, forKey: getKeyForUser(email))
        } catch {
            // Error al guardar los logros
        }
    }
    
    // Cargar los logros de un usuario específico
    func loadAchievements(forUser email: String) -> [AchievementStatus] {
        guard let data = UserDefaults.standard.data(forKey: getKeyForUser(email)) else {
            return [] // Si no hay datos guardados, devolver un array vacío
        }
        
        do {
            let achievements = try JSONDecoder().decode([AchievementStatus].self, from: data)
            return achievements
        } catch {
            // Error al cargar los logros
            return []
        }
    }
    
    // Actualizar el estado de un logro específico para un usuario
    func updateAchievement(id: Int, completed: Bool, forUser email: String) {
        var achievements = loadAchievements(forUser: email)
        
        // Buscar si ya existe el logro
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].completado = completed
        } else {
            // Si no existe, añadirlo
            achievements.append(AchievementStatus(id: id, completado: completed))
        }
        
        // Guardar los cambios
        saveAchievements(achievements: achievements, forUser: email)
    }
    
    // Verificar si un logro está completado para un usuario
    func isAchievementCompleted(id: Int, forUser email: String) -> Bool {
        let achievements = loadAchievements(forUser: email)
        return achievements.first(where: { $0.id == id })?.completado ?? false
    }
    
    // Obtener todos los IDs de logros completados para un usuario
    func getCompletedAchievementIds(forUser email: String) -> [Int] {
        let achievements = loadAchievements(forUser: email)
        return achievements.filter { $0.completado }.map { $0.id }
    }
}