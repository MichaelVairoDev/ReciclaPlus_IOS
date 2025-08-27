# ReciclaPlus iOS - Documentación Técnica para Exposición 🎯

## 📋 Índice de Contenidos

1. [Visión General del Proyecto](#1-visión-general-del-proyecto)
2. [Arquitectura del Sistema](#2-arquitectura-del-sistema)
3. [Análisis Detallado de Componentes](#3-análisis-detallado-de-componentes)
4. [Flujo de Datos y Comunicación](#4-flujo-de-datos-y-comunicación)
5. [Patrones de Diseño Implementados](#5-patrones-de-diseño-implementados)
6. [Gestión de Estado y Persistencia](#6-gestión-de-estado-y-persistencia)
7. [Integración con Servicios Externos](#7-integración-con-servicios-externos)
8. [Consideraciones de Rendimiento](#8-consideraciones-de-rendimiento)
9. [Seguridad y Mejores Prácticas](#9-seguridad-y-mejores-prácticas)
10. [Escalabilidad y Mantenimiento](#10-escalabilidad-y-mantenimiento)

---

## 1. Visión General del Proyecto

### 🎯 Propósito y Objetivos

ReciclaPlus es una aplicación iOS nativa desarrollada en Swift que tiene como objetivo principal **promover la conciencia ambiental y facilitar las prácticas de reciclaje** a través de:

- **Gamificación**: Sistema de logros y recompensas
- **Educación**: Tips y consejos sobre reciclaje
- **Servicios**: Sistema de recolección de materiales
- **Comunidad**: Eventos y actividades ambientales

### 📊 Métricas del Proyecto

- **Líneas de código**: ~3,500 líneas
- **Archivos Swift**: 15 archivos principales
- **Controladores**: 7 view controllers
- **Managers**: 4 gestores de servicios
- **Modelos**: 15+ estructuras de datos
- **Compatibilidad**: iOS 13.0+

---

## 2. Arquitectura del Sistema

### 🏗️ Patrón Arquitectónico: MVC Mejorado

La aplicación implementa el patrón **Model-View-Controller (MVC)** con capas adicionales de abstracción:

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                   │
│  ┌─────────────────┐  ┌───────────────────┐             │
│  │View Controllers │  │   Storyboards     │             │
│  │  - LoginVC      │  │ - Main.storyboard │             │
│  │  - HomeVC       │  │ - LaunchScreen    │             │
│  │  - EventosVC    │  └───────────────────┘             │
│  │  - LogrosVC     │                                    │
│  │  - TipsVC       │                                    │
│  │  - PerfilVC     │                                    │
│  │  - OnboardingVC │                                    │
│  └─────────────────┘                                    │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│                    BUSINESS LAYER                       │
│  ┌──────────────────┐  ┌──────────────────┐             │
│  │    Managers      │  │     Models       │             │
│  │  - UserManager   │  │  - ShippingModel │             │
│  │  - APIManager    │  │  - EventoItem    │             │
│  │  - ShippingMgr   │  │  - LogroItem     │             │
│  │  - AchievementMgr│  │  - TipItem       │             │
│  └──────────────────┘  └──────────────────┘             │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│                     DATA LAYER                          │
│  ┌─────────────────┐  ┌─────────────────┐               │
│  │   Local Storage │  │   Remote API    │               │
│  │  - UserDefaults │  │  - REST API     │               │
│  │  - Keychain     │  │  - JSON Data    │               │
│  └─────────────────┘  └─────────────────┘               │
└─────────────────────────────────────────────────────────┘
```

### 🔄 Flujo de Navegación

```
App Launch → SceneDelegate → OnboardingVC → LoginVC → TabBarController
                                                           │
                    ┌──────────────────────────────────────┼──────────────────────────────────────┐
                    │                                      │                                      │
                    ▼                                      ▼                                      ▼
                 HomeVC                                EventosVC                              LogrosVC
                    │                                      │                                      │
                    ▼                                      ▼                                      ▼
              TipsVC ←→ PerfilVC                    (Event Details)                      (Achievement Details)
```

---

## 3. Análisis Detallado de Componentes

### 🎮 Controllers (Controladores de Vista)

#### 3.1 `AppDelegate.swift`
**Propósito**: Punto de entrada de la aplicación y configuración global.

```swift
// Responsabilidades principales:
- Configuración de Google Sign-In
- Inicialización de servicios globales
- Gestión del ciclo de vida de la aplicación
```

**Características técnicas**:
- Implementa `UIApplicationDelegate`
- Configura `GIDConfiguration` con CLIENT_ID desde GoogleService-Info.plist
- Maneja errores de configuración con `fatalError` para debugging

#### 3.2 `SceneDelegate.swift`
**Propósito**: Gestión de escenas y navegación inicial.

```swift
// Funcionalidades clave:
- Configuración de ventana principal
- Navegación inicial basada en estado de sesión
- Manejo de URLs de Google Sign-In
- Gestión de estados de aplicación (foreground/background)
```

#### 3.3 `LoginViewController.swift`
**Propósito**: Autenticación de usuarios con múltiples opciones.

**Características técnicas**:
- **Autenticación dual**: Google Sign-In + Modo invitado
- **Manejo de errores**: Validación de configuración y respuestas de API
- **UI responsiva**: Deshabilitación temporal de botones durante autenticación
- **Navegación programática**: Instanciación de TabBarController

```swift
// Flujo de autenticación:
1. Usuario selecciona método de login
2. Validación de configuración (Google)
3. Llamada a GIDSignIn.sharedInstance.signIn()
4. Procesamiento de respuesta
5. Configuración de UserManager
6. Navegación a pantalla principal
```

#### 3.4 `OnboardingViewController.swift`
**Propósito**: Introducción interactiva para nuevos usuarios.

**Arquitectura técnica**:
- **UICollectionView horizontal** con paginación
- **Indicadores de página** (dots) dinámicos
- **Carga de datos desde API** con fallback local
- **Navegación condicional** basada en página actual

```swift
// Componentes principales:
- collectionView: UICollectionView (scroll horizontal)
- stackViewDots: UIStackView (indicadores)
- comencemosButton: UIButton (navegación)
- onboardingData: [OnboardingSlide] (datos)
```

**Implementación de paginación**:
```swift
func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
    currentPage = Int(pageIndex)
    updateDots()
    updateButtonVisibility()
}
```

#### 3.5 `HomeViewController.swift` (Controlador Principal)
**Propósito**: Hub central de la aplicación con múltiples funcionalidades.

**Complejidad**: Es el controlador más complejo con 1,286 líneas de código.

**Funcionalidades principales**:

1. **Gestión de categorías de reciclaje**:
   ```swift
   struct RecyclingCategory {
       let id: Int
       let name: String
       let products: [RecyclableProduct]
       let description: String
   }
   ```

2. **Sistema de overlays modales**:
   - Detalles de categorías
   - Detalles de productos
   - Pasos de envío
   - Confirmación de envíos
   - Mapas de puntos de recolección

3. **Integración con servicios**:
   - APIManager para datos remotos
   - ShippingManager para gestión de envíos
   - UserManager para autenticación

**Patrón de overlay implementado**:
```swift
private func showOverlay(contentView: UIView, size: CGSize) {
    // Crear overlay con fondo semitransparente
    // Agregar animaciones de entrada
    // Configurar gestos de cierre
}
```

#### 3.6 `EventosViewController.swift`
**Propósito**: Gestión y visualización de eventos ambientales.

**Características técnicas**:
- **UITableView programático**: Creado dinámicamente en `viewDidLayoutSubviews`
- **Ordenamiento inteligente**: Eventos próximos vs. finalizados
- **Formateo de fechas**: Conversión y comparación de fechas
- **Búsqueda recursiva**: Localización de TableView en jerarquía de vistas

```swift
// Algoritmo de ordenamiento:
private func ordenarEventosPorEstado() {
    let fechaActual = Date()
    // Conversión de fechas string a Date
    // Clasificación automática: "Próximo" vs "Finalizado"
    // Ordenamiento por fecha dentro de cada categoría
}
```

#### 3.7 `LogrosViewController.swift`
**Propósito**: Sistema de gamificación y logros.

**Funcionalidades avanzadas**:
- **Persistencia por usuario**: Logros específicos por email
- **Simulación de logros**: Para testing y debugging
- **Autenticación requerida**: Redirección a perfil para invitados
- **Sincronización con API**: Carga de logros desde servidor

```swift
// Estructura de logro:
struct LogroItem {
    let id: Int
    let titulo: String
    let descripcion: String
    let imageName: String
    let requisito: String
    var completado: Bool
}
```

#### 3.8 `TipsViewController.swift`
**Propósito**: Educación ambiental a través de consejos.

**Diseño de interfaz**:
- **Grid layout**: 4 columnas en dispositivos estándar
- **Responsive design**: Adaptación automática a diferentes tamaños
- **Cálculo dinámico de celdas**: Basado en ancho de pantalla

```swift
// Cálculo de layout:
let numberOfColumns: CGFloat = 4
let availableWidth = screenWidth - (padding * 3) - (spacing * (numberOfColumns - 1))
let itemWidth = floor(availableWidth / numberOfColumns)
```

#### 3.9 `PerfilViewController.swift`
**Propósito**: Gestión de perfil de usuario y envíos.

**Funcionalidades diferenciadas**:
- **UI adaptativa**: Diferente para usuarios autenticados vs. invitados
- **Gestión de envíos**: Solo para usuarios de Google
- **Logout seguro**: Limpieza de datos y redirección

---

### 🔧 Managers (Gestores de Servicios)

#### 4.1 `UserManager.swift` (Singleton)
**Propósito**: Gestión centralizada de estado de usuario.

**Patrón Singleton implementado**:
```swift
class UserManager {
    static let shared = UserManager()
    private init() { loadUserSession() }
}
```

**Funcionalidades principales**:
- **Gestión de sesión**: Login/logout con persistencia
- **Configuración de avatar**: Creación de UIBarButtonItem personalizado
- **Descarga de imágenes**: Async download de avatares de Google
- **Notificaciones**: Sistema de observadores para cambios de avatar

#### 4.2 `APIManager.swift`
**Propósito**: Comunicación con backend REST API.

**Arquitectura de red**:
```swift
// Estructura genérica de respuesta:
struct APIResponse<T: Codable>: Codable {
    let message: String
    let totalDocuments: Int
    let documents: [T]
    let timestamp: String
}
```

**Endpoints implementados**:
- `GET /categorias` → Categorías de reciclaje
- `GET /eventos` → Eventos ambientales
- `GET /logros` → Sistema de logros
- `GET /onboarding` → Slides de introducción
- `GET /productos` → Productos reciclables
- `GET /puntos-recoleccion` → Ubicaciones de centros
- `GET /tips` → Consejos educativos

**Manejo de errores**:
```swift
enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
}
```

#### 4.3 `ShippingManager.swift`
**Propósito**: Gestión completa del sistema de envíos.

**Funcionalidades avanzadas**:
- **Generación de códigos**: Formato ENV-XXXXXX único
- **Validación temporal**: Envíos válidos por 48 horas
- **Límites por usuario**: Máximo 3 envíos activos
- **Persistencia local**: Almacenamiento en UserDefaults
- **Integración con mapas**: Puntos de recolección con coordenadas

```swift
// Modelo de envío:
struct Shipping: Codable {
    let id: String
    let code: String
    let collectionPointId: String
    let createdAt: Date
    let validUntil: Date
    let userId: String
    var status: ShippingStatus
}
```

#### 4.4 `AchievementManager.swift`
**Propósito**: Persistencia de logros por usuario.

**Características técnicas**:
- **Almacenamiento por usuario**: Clave única por email
- **Serialización JSON**: Codable para persistencia
- **Operaciones CRUD**: Create, Read, Update para logros
- **Thread-safe**: Operaciones síncronas en UserDefaults

---

### 📊 Models (Modelos de Datos)

#### 5.1 Modelos de API
```swift
// Modelos principales del servidor:
struct Categoria: Codable { /* Categorías de reciclaje */ }
struct Evento: Codable { /* Eventos ambientales */ }
struct Logro: Codable { /* Sistema de logros */ }
struct Producto: Codable { /* Productos reciclables */ }
struct PuntoRecoleccion: Codable { /* Centros de recolección */ }
struct Tip: Codable { /* Consejos educativos */ }
```

#### 5.2 Modelos Locales
```swift
// Modelos para UI y lógica local:
struct RecyclableProduct { /* Productos con estado local */ }
struct EventoItem { /* Eventos con formateo */ }
struct LogroItem { /* Logros con persistencia */ }
struct TipItem { /* Tips con imágenes locales */ }
```

#### 5.3 `ShippingModel.swift`
**Modelos especializados para envíos**:

```swift
// Punto de recolección:
struct CollectionPoint: Codable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let isActive: Bool
}

// Estados de envío:
enum ShippingStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case completed = "completed"
    case expired = "expired"
}
```

---

## 4. Flujo de Datos y Comunicación

### 🔄 Arquitectura de Datos

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   View Controller│───▶│    Manager      │───▶│   API/Storage   │
│                 │    │                 │    │                 │
│ - UI Updates    │◀───│ - Business Logic│◀───│ - Data Source   │
│ - User Input    │    │ - Data Transform│    │ - Persistence   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 📡 Comunicación Asíncrona

**Patrón de completion handlers**:
```swift
func loadData(completion: @escaping (Result<[Model], Error>) -> Void) {
    // Operación asíncrona
    DispatchQueue.main.async {
        completion(.success(data))
    }
}
```

**Sistema de notificaciones**:
```swift
// UserManager notifica cambios de avatar
NotificationCenter.default.post(
    name: NSNotification.Name("AvatarUpdated"),
    object: nil
)
```

---

## 5. Patrones de Diseño Implementados

### 🎯 Singleton Pattern
**Implementado en**:
- `UserManager.shared`
- `APIManager.shared`
- `ShippingManager.shared`
- `AchievementManager.shared`

**Ventajas**:
- Estado global consistente
- Fácil acceso desde cualquier punto
- Gestión centralizada de recursos

### 🔄 Observer Pattern
**Implementado con NotificationCenter**:
```swift
// Registro de observador
NotificationCenter.default.addObserver(
    self,
    selector: #selector(updateAvatar),
    name: NSNotification.Name("AvatarUpdated"),
    object: nil
)
```

### 🏭 Factory Pattern
**Para creación de overlays**:
```swift
private func createOverlay(type: OverlayType) -> UIView {
    switch type {
    case .productDetail: return createProductDetailView()
    case .categoryDetail: return createCategoryDetailView()
    case .shippingSteps: return createShippingStepsView()
    }
}
```

### 📋 Delegate Pattern
**UITableView y UICollectionView**:
```swift
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // Implementación de métodos delegate
}
```

---

## 6. Gestión de Estado y Persistencia

### 💾 Estrategias de Almacenamiento

#### UserDefaults
```swift
// Para preferencias y datos simples:
- Estado de sesión de usuario
- Logros completados por usuario
- Envíos activos
- Configuraciones de app
```

#### Memoria (Runtime)
```swift
// Para datos temporales:
- Cache de imágenes de usuario
- Datos de API en sesión actual
- Estado de UI (overlays, navegación)
```

### 🔄 Sincronización de Estado

**Entre ViewControllers**:
```swift
// Uso de NotificationCenter para sincronización
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // Recargar datos si es necesario
    tableView?.reloadData()
}
```

---

## 7. Integración con Servicios Externos

### 🔐 Google Sign-In

**Configuración**:
```swift
// En AppDelegate:
GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)

// En SceneDelegate:
GIDSignIn.sharedInstance.handle(url)
```

**Flujo de autenticación**:
1. Usuario toca botón de Google Sign-In
2. Se abre webview de Google
3. Usuario autoriza la aplicación
4. Callback con token y datos de usuario
5. Almacenamiento local de sesión

### 🌐 REST API Backend

**Configuración de red**:
```swift
private let baseURL = "http://localhost:3000/api"

// Headers estándar:
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
```

**Manejo de respuestas**:
```swift
struct APIResponse<T: Codable>: Codable {
    let message: String
    let totalDocuments: Int
    let documents: [T]
    let timestamp: String
}
```

---

## 8. Consideraciones de Rendimiento

### ⚡ Optimizaciones Implementadas

#### Lazy Loading
```swift
// Carga diferida de datos:
override func viewDidAppear(_ animated: Bool) {
    if tips.isEmpty {
        loadTipsFromAPI()
    }
}
```

#### Image Caching
```swift
// Cache de avatares de usuario:
private func downloadUserImage(from url: URL) {
    // Descarga asíncrona con cache en memoria
}
```

#### Reuso de Celdas
```swift
// TableView y CollectionView:
let cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
```

### 📱 Gestión de Memoria

**Weak References**:
```swift
GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
    // Evita retain cycles
}
```

**Cleanup en deinit**:
```swift
deinit {
    NotificationCenter.default.removeObserver(self)
}
```

---

## 9. Seguridad y Mejores Prácticas

### 🔒 Medidas de Seguridad

#### Validación de Datos
```swift
// Validación de respuestas de API:
guard let data = data else {
    completion(.failure(APIError.noData))
    return
}
```

#### Manejo Seguro de URLs
```swift
// Validación de URLs antes de requests:
guard let url = URL(string: endpoint) else {
    completion(.failure(APIError.invalidURL))
    return
}
```

#### Configuración Segura
```swift
// GoogleService-Info.plist no incluido en repositorio
// CLIENT_ID cargado dinámicamente
guard let clientId = plist["CLIENT_ID"] as? String else {
    fatalError("No se pudo encontrar CLIENT_ID")
}
```

### ✅ Mejores Prácticas

#### Error Handling
```swift
// Manejo consistente de errores:
do {
    let result = try JSONDecoder().decode(APIResponse<T>.self, from: data)
    completion(.success(result))
} catch {
    completion(.failure(APIError.decodingError))
}
```

#### Code Organization
```swift
// Extensiones para organizar código:
extension HomeViewController: UICollectionViewDataSource {
    // Métodos de data source
}

extension HomeViewController: UICollectionViewDelegate {
    // Métodos de delegate
}
```

---

## 10. Escalabilidad y Mantenimiento

### 🚀 Arquitectura Escalable

#### Modularidad
- **Managers independientes**: Cada servicio en su propio manager
- **Protocolos**: Para definir contratos entre componentes
- **Dependency Injection**: Managers como singletons inyectables

#### Extensibilidad
```swift
// Fácil adición de nuevos endpoints:
func getNewFeature(completion: @escaping (Result<[NewModel], Error>) -> Void) {
    performRequest(endpoint: "/new-feature", responseType: NewModel.self, completion: completion)
}
```

### 🔧 Mantenibilidad

#### Documentación en Código
```swift
/// Gestiona la autenticación y estado del usuario
/// - Singleton pattern para acceso global
/// - Persistencia automática de sesión
class UserManager {
    // Implementación
}
```

#### Testing Preparado
```swift
// Managers como protocolos para testing:
protocol UserManagerProtocol {
    func getUserEmail() -> String
    func getIsLoggedIn() -> Bool
}
```

### 📈 Métricas de Calidad

- **Cohesión alta**: Cada clase tiene una responsabilidad clara
- **Acoplamiento bajo**: Comunicación a través de protocolos y managers
- **Reutilización**: Componentes reutilizables (overlays, células)
- **Mantenibilidad**: Código organizado en extensiones y categorías

---

## 🎯 Conclusiones Técnicas

### Fortalezas del Proyecto

1. **Arquitectura sólida**: MVC bien implementado con separación clara
2. **Gestión de estado**: Centralizada y consistente
3. **Integración externa**: Google Sign-In y API REST bien implementadas
4. **UI/UX**: Interfaz intuitiva con navegación fluida
5. **Escalabilidad**: Estructura preparada para crecimiento

### Áreas de Mejora Potencial

1. **Testing**: Implementar unit tests y UI tests
2. **Offline support**: Cache local para funcionalidad sin conexión
3. **Performance**: Implementar paginación en listas grandes
4. **Accessibility**: Mejorar soporte para VoiceOver
5. **Analytics**: Integrar tracking de eventos de usuario

### Tecnologías Futuras

- **SwiftUI**: Migración gradual de UIKit
- **Combine**: Para programación reactiva
- **Core Data**: Para persistencia compleja
- **CloudKit**: Para sincronización entre dispositivos

---

**Esta documentación técnica proporciona una visión completa de la arquitectura, implementación y consideraciones de diseño del proyecto ReciclaPlus iOS, preparada para una exposición técnica de 20 minutos que cubra todos los aspectos importantes del desarrollo.**
