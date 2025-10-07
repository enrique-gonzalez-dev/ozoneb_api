# Ozone Benefits API

API RESTful para el sistema de gestión de beneficios Ozone, desarrollada con Ruby on Rails.

## 🚀 Características

- **Autenticación JWT**: Sistema de autenticación basado en tokens JSON Web Token
- **Gestión de Usuarios**: CRUD completo para usuarios con control de roles
- **Autorización por Roles**: Sistema de permisos basado en roles (admin, supervisor, operation)
- **Serializers**: Respuestas controladas que no exponen información sensible
- **API RESTful**: Endpoints bien estructurados siguiendo convenciones REST

## 📋 Requisitos

- Ruby 3.2+
- Rails 7.1+
- PostgreSQL
- Bundler

## 🛠️ Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
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

4. **Iniciar el servidor**
   ```bash
   rails server
   ```

El servidor estará disponible en `http://localhost:3000`

## 🔐 Autenticación

### Login
```http
POST /api/v1/login
Content-Type: application/json

{
  "email": "admin@mail.com",
  "password": "password"
}
```

**Respuesta exitosa:**
```json
{
  "user": {
    "id": "uuid",
    "name": "Admin",
    "last_name": "User",
    "role": "admin",
    "email": "admin@mail.com"
  },
  "token": "jwt_token_here"
}
```

### Logout
```http
DELETE /api/v1/logout
Authorization: Bearer jwt_token_here
```

## 👥 Gestión de Usuarios

### Listar Usuarios
```http
GET /api/v1/users
Authorization: Bearer jwt_token_here
```

**Permisos:** Solo `admin` y `supervisor`

### Obtener Usuario Específico
```http
GET /api/v1/users/:id
Authorization: Bearer jwt_token_here
```

### Crear Usuario
```http
POST /api/v1/users
Authorization: Bearer jwt_token_here
Content-Type: application/json

{
  "user": {
    "name": "Nuevo",
    "last_name": "Usuario",
    "email": "nuevo@mail.com",
    "password": "password123",
    "password_confirmation": "password123",
    "role": "operation"
  }
}
```

**Permisos:** Solo `admin` y `supervisor`

### Actualizar Usuario
```http
PUT /api/v1/users/:id
Authorization: Bearer jwt_token_here
Content-Type: application/json

{
  "user": {
    "name": "Nombre Actualizado",
    "last_name": "Apellido Actualizado",
    "email": "email@actualizado.com",
    "role": "supervisor"
  }
}
```

**Permisos:** 
- Los usuarios pueden actualizar su propia información (excepto rol)
- Solo `admin` y `supervisor` pueden actualizar cualquier usuario y cambiar roles

### Eliminar Usuario
```http
DELETE /api/v1/users/:id
Authorization: Bearer jwt_token_here
```

**Permisos:** Solo `admin` y `supervisor`

## 🎭 Roles de Usuario

| Rol | Valor | Permisos |
|-----|-------|----------|
| `admin` | 0 | Acceso completo a todas las funciones |
| `operation` | 1 | Acceso limitado, solo lectura |
| `supervisor` | 2 | Puede gestionar usuarios, acceso amplio |

## 📊 Formato de Respuestas

### Respuesta Exitosa
```json
{
  "status": {
    "code": 200,
    "message": "Operation completed successfully"
  },
  "data": {
    "id": "uuid",
    "name": "Usuario",
    "last_name": "Ejemplo",
    "role": "operation",
    "email": "usuario@mail.com"
  }
}
```

### Respuesta de Error
```json
{
  "status": {
    "message": "Error description"
  }
}
```

### Códigos de Estado HTTP

- `200` - OK
- `201` - Created
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Unprocessable Entity

## 🛡️ Seguridad

- **JWT Authentication**: Tokens con expiración configurable
- **Autorización por Roles**: Control granular de permisos
- **Serializers**: Solo se exponen campos seguros en las respuestas
- **Validaciones**: Validación completa de datos de entrada
- **CORS**: Configurado para peticiones cross-origin

## 🔧 Herramientas de Desarrollo

### Health Check
```http
GET /api/v1/health
```

### Rails Health Check
```http
GET /up
```

## 🧪 Testing

```bash
# Ejecutar todas las pruebas
rails test

# Ejecutar pruebas específicas
rails test test/models/user_test.rb
```

## 📝 Ejemplos con cURL

### 1. Login y obtener token
```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@mail.com",
    "password": "password"
  }'
```

### 2. Crear un nuevo usuario
```bash
curl -X POST http://localhost:3000/api/v1/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "user": {
      "name": "Juan",
      "last_name": "Pérez",
      "email": "juan@mail.com",
      "password": "password123",
      "password_confirmation": "password123",
      "role": "operation"
    }
  }'
```

### 3. Listar todos los usuarios
```bash
curl -X GET http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 4. Actualizar un usuario
```bash
curl -X PUT http://localhost:3000/api/v1/users/USER_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "user": {
      "name": "Juan Carlos",
      "role": "supervisor"
    }
  }'
```

## 🏗️ Arquitectura

```
app/
├── controllers/
│   └── api/v1/          # Controladores de la API
├── models/              # Modelos de datos
├── serializers/         # Serializers para respuestas
│   └── api/v1/
├── services/            # Servicios de negocio
└── lib/                 # Librerías personalizadas
```

## 📋 TODO

- [ ] Implementar paginación en listados
- [ ] Agregar filtros de búsqueda
- [ ] Implementar rate limiting
- [ ] Agregar logs de auditoría
- [ ] Documentación con Swagger/OpenAPI

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.
