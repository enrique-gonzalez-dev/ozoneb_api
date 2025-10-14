# Ozone Benefits - Sistema de Gestión Empresarial(API)

Una API REST robusta construida con Ruby on Rails 8.0 para la gestión de usuarios y autenticación empresarial.

## Descripción General

Ozoneb API es una aplicación backend diseñada para proporcionar servicios de autenticación y gestión de usuarios de manera segura y escalable. La API implementa estándares de la industria para autenticación JWT, gestión de roles y recuperación de contraseñas.

## Características Principales

### Autenticación y Seguridad
- Autenticación basada en JWT (JSON Web Tokens)
- Integración con Devise para manejo seguro de usuarios
- Recuperación de contraseñas vía email
- Sistema de roles multi-nivel (Admin, Operation, Supervisor)
- Configuración CORS para integración con aplicaciones frontend

### Gestión de Usuarios
- CRUD completo para usuarios
- Sistema de estados (Activo/Inactivo)
- Soporte para avatares de usuario con Active Storage
- Validaciones robustas de datos
- Paginación de resultados con Kaminari

### Arquitectura
- API RESTful con versionado (v1)
- Arquitectura MVC estándar de Rails
- Serialización de datos estructurada
- Manejo centralizado de errores
- Health checks para monitoreo

## Especificaciones Técnicas

### Tecnologías Utilizadas
- **Framework**: Ruby on Rails 8.0.3
- **Base de Datos**: PostgreSQL
- **Servidor Web**: Puma
- **Autenticación**: Devise + Devise-JWT
- **Almacenamiento**: Active Storage
- **Caché**: Solid Cache
- **Cola de Trabajos**: Solid Queue
- **WebSockets**: Solid Cable

### Requisitos del Sistema
- Ruby 3.0 o superior
- PostgreSQL 12 o superior
- Docker (opcional, para despliegue)

## Instalación y Configuración

### Configuración Local

1. **Clonar el repositorio**
   ```bash
   git clone git@github.com:grupo-ozonebeneifts/ozoneb_api.git
   cd ozoneb_api
   ```

2. **Instalar dependencias**
   ```bash
   bundle install
   ```

3. **Configurar base de datos**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Configurar variables de entorno**
   ```bash
   cp .env.example .env
   # Editar .env con las configuraciones apropiadas
   ```

5. **Iniciar servidor**
   ```bash
   rails server
   ```

### Despliegue con Docker

```bash
docker build -t ozoneb-api .
docker run -p 3000:3000 ozoneb-api
```

### Despliegue con Kamal

```bash
kamal setup
kamal deploy
```

## Estructura de la API

### Endpoints Principales

#### Autenticación
- `POST /api/v1/login` - Iniciar sesión
- `DELETE /api/v1/logout` - Cerrar sesión
- `POST /api/v1/password/forgot` - Solicitar recuperación de contraseña
- `PUT /api/v1/password/reset` - Restablecer contraseña

#### Gestión de Usuarios
- `GET /api/v1/users` - Listar usuarios (paginado)
- `GET /api/v1/users/:id` - Obtener usuario específico
- `POST /api/v1/users` - Crear nuevo usuario
- `PUT /api/v1/users/:id` - Actualizar usuario
- `DELETE /api/v1/users/:id` - Eliminar usuario
- `PATCH /api/v1/users/:id/update_password` - Cambiar contraseña
- `PATCH /api/v1/users/:id/update_avatar` - Actualizar avatar

#### Monitoreo
- `GET /api/v1/health` - Estado de la API
- `GET /up` - Health check del sistema

### Formato de Respuesta

La API devuelve respuestas en formato JSON con la siguiente estructura:

```json
{
  "data": {},
  "message": "string",
  "status": "success|error",
  "errors": []
}
```

### Códigos de Estado HTTP

- `200 OK` - Solicitud exitosa
- `201 Created` - Recurso creado exitosamente
- `400 Bad Request` - Error en los datos enviados
- `401 Unauthorized` - No autenticado
- `403 Forbidden` - No autorizado
- `404 Not Found` - Recurso no encontrado
- `422 Unprocessable Entity` - Error de validación
- `500 Internal Server Error` - Error interno del servidor

## Modelos de Datos

### Usuario
```ruby
{
  id: UUID,
  email: String,
  name: String,
  last_name: String,
  role: Enum [admin, operation, supervisor],
  status: Enum [active, inactive],
  created_at: DateTime,
  updated_at: DateTime
}
```

## Seguridad

### Medidas Implementadas
- Autenticación JWT con expiración configurable
- Validación de datos de entrada
- Sanitización de parámetros
- Headers de seguridad configurados
- Rate limiting (configurable)
- Logging de accesos y errores

### Variables de Entorno Requeridas
- `DATABASE_URL` - Conexión a la base de datos
- `SECRET_KEY_BASE` - Clave secreta de Rails
- `JWT_SECRET_KEY` - Clave para firmar tokens JWT
- `SMTP_*` - Configuración para envío de emails

## Testing

### Ejecutar Suite de Pruebas
```bash
rails test
```

### Cobertura de Pruebas
- Modelos: Validaciones y métodos de instancia
- Controladores: Endpoints y autenticación
- Integración: Flujos completos de usuario
- Mailers: Envío de notificaciones

## Herramientas de Desarrollo

### Análisis de Código
```bash
rubocop                    # Análisis de estilo
brakeman                   # Análisis de seguridad
```

### Debugging
```bash
rails console              # Consola interactiva
rails dbconsole           # Consola de base de datos
```

## Monitoreo y Logs

### Health Checks
- Endpoint `/api/v1/health` para monitoreo automático
- Verificación de conectividad a base de datos
- Estado de servicios críticos

### Logging
- Logs estructurados en formato JSON
- Rotación automática de archivos de log
- Diferentes niveles de logging por ambiente

## Contribución

### Estándares de Código
- Seguir guías de estilo de Ruby community
- Pruebas unitarias para toda nueva funcionalidad
- Documentación actualizada en cada cambio
- Code review obligatorio para cambios principales

### Workflow de Desarrollo
1. Crear branch desde main
2. Implementar funcionalidad con pruebas
3. Ejecutar suite de pruebas y análisis de código
4. Crear pull request con descripción detallada
5. Code review y merge

## Licencia

Propiedad de Grupo Ozone Benefits. Todos los derechos reservados.

## Contacto

Para soporte técnico o consultas sobre la API, contactar al equipo de desarrollo.

---

**Versión**: 1.0.0  
**Última actualización**: Octubre 2024  
**Compatibilidad**: Ruby 3.0+, Rails 8.0+
