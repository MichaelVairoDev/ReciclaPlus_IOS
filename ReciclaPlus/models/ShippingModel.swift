//
//  ShippingModel.swift
//  ReciclaPlus
//
//  Created by Assistant on 2025-01-13.
//

import Foundation
import UIKit

// MARK: - Punto de Recolección
struct CollectionPoint: Codable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let isActive: Bool
    
    init(id: String, name: String, address: String, latitude: Double, longitude: Double, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.isActive = isActive
    }
}

// MARK: - Estado del Envío
enum ShippingStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case completed = "completed"
    case expired = "expired"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Vigente"
        case .completed:
            return "Completado"
        case .expired:
            return "Expirado"
        }
    }
    
    var color: UIColor {
        switch self {
        case .pending:
            return .systemGreen
        case .expired:
            return .systemRed
        case .completed:
            return .systemBlue
        }
    }
}

// MARK: - Modelo de Envío
struct Shipping: Codable {
    let id: String
    let code: String
    let collectionPointId: String
    let createdAt: Date
    let validUntil: Date
    let userId: String
    var status: ShippingStatus
    
    init(collectionPointId: String, userId: String) {
        self.id = UUID().uuidString
        self.code = Shipping.generateShippingCode()
        self.collectionPointId = collectionPointId
        self.createdAt = Date()
        self.validUntil = Calendar.current.date(byAdding: .hour, value: 48, to: Date()) ?? Date()
        self.userId = userId
        self.status = .pending
    }
    
    // Generar código de envío con formato ENV-XXXXXX
    static func generateShippingCode() -> String {
        let randomNumber = Int.random(in: 1000...9999)
        let timestamp = Int(Date().timeIntervalSince1970) % 10000
        return "ENV-\(randomNumber)-\(timestamp)"
    }
    
    // Calcular estado actual basado en fecha
    mutating func updateStatus() {
        let now = Date()
        if now > validUntil {
            status = .expired
        } else if status != .completed {
            status = .pending
        }
    }
    
    // Formatear fecha de validez
    var formattedValidUntil: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: validUntil)
    }
    
    // Formatear fecha de registro
    var formattedRegistrationDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: createdAt)
    }
}