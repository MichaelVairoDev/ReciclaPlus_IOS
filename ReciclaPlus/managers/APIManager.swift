//
//  APIManager.swift
//  ReciclaPlus
//
//  Created by MacOS on 26/08/25.
//

import Foundation

// MARK: - Data Models
struct APIResponse<T: Codable>: Codable {
    let message: String
    let totalDocuments: Int
    let documents: [T]
    let timestamp: String
}

struct Categoria: Codable {
    let id: Int
    let nombre: String
    let imagen: String
    let descripcion: String
}

struct Evento: Codable {
    let id: Int
    let titulo: String
    let descripcion: String
    let fecha: String
    let estado: String
    let imagen: String
}

struct Logro: Codable {
    let id: Int
    let titulo: String
    let descripcion: String
    let imagen: String
    let requisito: String
    let completado: Bool
}

struct OnboardingSlideAPI: Codable {
    let id: Int
    let titulo: String
    let descripcion: String
    let imagen: String
}

struct Producto: Codable {
    let id: Int
    let categoriaId: Int
    let nombre: String
    let descripcion: String
    let imagen: String
    let cantidadReciclada: Int
    let impactoAmbiental: [String]
    let tipsReciclaje: [String]
}

struct PuntoRecoleccion: Codable {
    let id: String
    let nombre: String
    let direccion: String
    let latitud: Double
    let longitud: Double
    let telefono: String?
    let horarios: String?
    let tiposAceptados: [String]?
}

struct Tip: Codable {
    let id: Int
    let titulo: String
    let descripcion: String
    let imagen: String?
}

// MARK: - API Manager
class APIManager {
    static let shared = APIManager()
    private let baseURL = "http://localhost:3000/api"
    
    private init() {}
    
    // MARK: - Generic API Call Method
    private func performRequest<T: Codable>(
        endpoint: String,
        responseType: T.Type,
        completion: @escaping (Result<APIResponse<T>, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.noData))
                }
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(apiResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - API Methods
    func getCategorias(completion: @escaping (Result<[Categoria], Error>) -> Void) {
        performRequest(endpoint: "categorias", responseType: Categoria.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.documents))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getEventos(completion: @escaping (Result<[Evento], Error>) -> Void) {
        performRequest(endpoint: "eventos", responseType: Evento.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.documents))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getLogros(completion: @escaping (Result<[Logro], Error>) -> Void) {
        performRequest(endpoint: "logros", responseType: Logro.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.documents))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getOnboarding(completion: @escaping (Result<[OnboardingSlideAPI], Error>) -> Void) {
        performRequest(endpoint: "onboarding", responseType: OnboardingSlideAPI.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.documents))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getProductos(completion: @escaping (Result<[Producto], Error>) -> Void) {
        performRequest(endpoint: "productos", responseType: Producto.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.documents))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getPuntosRecoleccion(completion: @escaping (Result<[PuntoRecoleccion], Error>) -> Void) {
        performRequest(endpoint: "puntosderecolecion", responseType: PuntoRecoleccion.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.documents))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getTips(completion: @escaping (Result<[Tip], Error>) -> Void) {
        performRequest(endpoint: "/tips", responseType: Tip.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.documents))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - API Errors
enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "No se recibieron datos"
        case .decodingError:
            return "Error al procesar los datos"
        }
    }
}