# ReciclaPlus iOS ♻️

<div align="center">
  **Una aplicación iOS innovadora para promover el reciclaje y la conciencia ambiental**
  
  [![iOS](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)
  [![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
  [![Xcode](https://img.shields.io/badge/Xcode-12.0+-blue.svg)](https://developer.apple.com/xcode/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 📱 Descripción

ReciclaPlus es una aplicación móvil diseñada para educar y motivar a los usuarios a adoptar prácticas de reciclaje responsables. La app combina gamificación, educación ambiental y servicios de recolección para crear una experiencia completa de reciclaje.

### ✨ Características Principales

- **🎯 Sistema de Logros**: Gamificación con logros desbloqueables
- **📚 Tips Educativos**: Consejos prácticos sobre reciclaje
- **📅 Eventos Ambientales**: Calendario de eventos relacionados con el medio ambiente
- **🚚 Servicio de Recolección**: Sistema de envíos para materiales reciclables
- **👤 Perfiles de Usuario**: Autenticación con Google y modo invitado
- **🗺️ Puntos de Recolección**: Mapa interactivo con ubicaciones de centros de reciclaje
- **📊 Seguimiento de Progreso**: Estadísticas personales de reciclaje

## 🏗️ Arquitectura

La aplicación sigue el patrón **MVC (Model-View-Controller)** con una arquitectura modular:

```
ReciclaPlus/
├── 📱 Controllers/          # Controladores de vista
├── 🔧 Managers/            # Gestores de servicios
├── 📊 Models/              # Modelos de datos
├── 🎨 Assets.xcassets/     # Recursos visuales
├── 📋 Base.lproj/          # Storyboards e interfaces
└── ⚙️ Configuration/       # Archivos de configuración
```

## 🚀 Instalación

### Prerrequisitos

- **Xcode 12.0+**
- **iOS 13.0 o Superior**
- **Swift 5.0+**
- **Cuenta de desarrollador de Apple** (para ejecutar en dispositivo físico)

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/ReciclaPlus_IOS.git
   cd ReciclaPlus_IOS
   ```

2. **Abrir el proyecto en Xcode**
   ```bash
   open ReciclaPlus.xcodeproj
   ```

3. **Configurar Google Sign-In**
   - Obtén tu archivo `GoogleService-Info.plist` desde [Firebase Console](https://console.firebase.google.com/)
   - Arrastra el archivo al proyecto en Xcode
   - Asegúrate de que esté incluido en el target

4. **Configurar el servidor API**
   - Actualiza la URL base en `APIManager.swift`:
   ```swift
   private let baseURL = "http://tu-servidor.com/api"
   ```

5. **Ejecutar el proyecto**
   - Selecciona tu dispositivo o simulador
   - Presiona `Cmd + R` para compilar y ejecutar

## 🔧 Configuración

### Variables de Entorno

El proyecto utiliza las siguientes configuraciones:

- **Bundle Identifier**: `pe.cibertec.ReciclaPlus`
- **Deployment Target**: iOS 13.0 o Superior
- **Google Sign-In**: Configurado via `GoogleService-Info.plist`

### API Backend

La aplicación se conecta a un servidor backend que proporciona:

- Datos de onboarding
- Categorías y productos reciclables
- Eventos ambientales
- Sistema de logros
- Puntos de recolección
- Tips educativos

## 📖 Uso

### Primera Vez

1. **Onboarding**: La app muestra slides informativos sobre reciclaje
2. **Autenticación**: Elige entre Google Sign-In o modo invitado
3. **Exploración**: Navega por las diferentes secciones usando el tab bar

### Funcionalidades Principales

#### 🏠 Home
- Visualiza categorías de reciclaje (Plástico, Metal, Vidrio)
- Explora productos más reciclados
- Accede al servicio de recolección

#### 📅 Eventos
- Consulta eventos ambientales próximos y pasados
- Obtén detalles de cada evento
- Mantente informado sobre actividades ecológicas

#### 🏆 Logros
- Desbloquea logros por actividades de reciclaje
- Visualiza tu progreso personal
- Comparte tus logros (solo usuarios autenticados)

#### 💡 Tips
- Aprende consejos prácticos de reciclaje
- Explora diferentes categorías de tips
- Mejora tus hábitos ambientales

#### 👤 Perfil
- Gestiona tu cuenta de usuario
- Visualiza tus envíos (usuarios autenticados)
- Cierra sesión cuando sea necesario

## 🛠️ Tecnologías Utilizadas

- **Swift 5**: Lenguaje de programación principal
- **UIKit**: Framework de interfaz de usuario
- **Google Sign-In**: Autenticación con Google
- **URLSession**: Comunicación con API REST
- **UserDefaults**: Almacenamiento local de preferencias
- **MapKit**: Integración de mapas para puntos de recolección
- **Core Location**: Servicios de ubicación

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Para contribuir:

1. **Fork** el proyecto
2. Crea una **rama** para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. Abre un **Pull Request**

### Guías de Contribución

- Sigue las convenciones de código Swift
- Documenta nuevas funcionalidades
- Incluye tests cuando sea apropiado
- Actualiza la documentación si es necesario

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Equipo de Desarrollo

- **Michael Vairo**
- **Omar Ruiz**
- Patrick Muñante**

## 🔄 Changelog

### v1.0.0 (2025-01-13)
- ✅ Lanzamiento inicial
- ✅ Sistema de autenticación con Google
- ✅ Funcionalidades básicas de reciclaje
- ✅ Sistema de logros
- ✅ Servicio de recolección
- ✅ Tips educativos
- ✅ Calendario de eventos

---

<div align="center">
  <p><strong>Hecho con ❤️ para un mundo más verde 🌍</strong></p>
  <p>ReciclaPlus © 2025. Todos los derechos reservados.</p>
</div>