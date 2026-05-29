# IAMDEX — Asistente de documentos con Inteligencia Artificial

Aplicación móvil Android desarrollada como Trabajo de Fin de Ciclo (TFC) del ciclo de Desarrollo de Aplicaciones Multiplataforma (DAM) en el CIFP A Carballeira Marcos-Valcárcel, Ourense. Curso 2025/2026.

## ¿Qué es IAMDEX?

IAMDEX permite subir documentos personales (PDF, DOCX, TXT) y consultarlos mediante lenguaje natural. La IA responde basándose únicamente en el contenido real de los documentos del usuario, citando siempre la fuente.

## Tecnologías

| Componente | Tecnología |
|---|---|
| App móvil | Flutter / Dart |
| Backend | FastAPI / Python |
| Base de datos relacional | MySQL |
| Base de datos vectorial | ChromaDB |
| Modelo de lenguaje | Llama 3.3 (Groq API) |
| Despliegue | Railway |
| Control de versiones | GitHub |

## Funcionalidades principales

- Registro e inicio de sesión con JWT y contraseñas cifradas con bcrypt
- Subida de documentos en PDF, DOCX y TXT
- Chat con la IA por documento o sobre todos los documentos a la vez (chat general)
- Respuestas con fuente citada automáticamente
- Historial de conversaciones agrupado por documento
- Buscador de mensajes en el chat con resaltado y scroll automático
- Renombrar, ordenar y eliminar documentos
- Compartir respuestas de la IA
- Modo oscuro automático según el tema del sistema
- Onboarding para nuevos usuarios
- Backend desplegado en Railway (disponible 24/7)

## Arquitectura

El proyecto se divide en dos carpetas principales:

```
TFC/
├── backend/       # API REST con FastAPI + pipeline RAG
└── mobile/        # App Android con Flutter
    └── iamdex/
```

### Pipeline RAG

1. El usuario sube un documento
2. El sistema extrae el texto y lo divide en fragmentos de 500 palabras
3. Cada fragmento se convierte en un vector numérico (embedding) y se almacena en ChromaDB
4. Cuando el usuario hace una pregunta, se buscan los 8 fragmentos más similares
5. Los fragmentos y la pregunta se envían al modelo Llama 3.3 de Groq
6. El modelo genera una respuesta basada únicamente en esos fragmentos

## Instalación y despliegue

### Requisitos previos

- Cuenta en GitHub
- Cuenta en Railway (railway.app)
- Dispositivo Android 8.0 o superior

### Backend (Railway)

1. Crear un nuevo proyecto en Railway desde el repositorio GitHub
2. Establecer el directorio raíz en `backend`
3. Añadir un servicio MySQL al proyecto
4. Configurar las variables de entorno:

```
DB_HOST=${{MySQL.MYSQLHOST}}
DB_PORT=${{MySQL.MYSQLPORT}}
DB_NAME=${{MySQL.MYSQLDATABASE}}
DB_USER=${{MySQL.MYSQLUSER}}
DB_PASSWORD=${{MySQL.MYSQLPASSWORD}}
SECRET_KEY=tu_clave_secreta
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
GROQ_API_KEY=tu_api_key_de_groq
CHROMA_PERSIST_PATH=/app/chroma_data
```

5. Añadir un volumen persistente montado en `/app/chroma_data`
6. Railway desplegará automáticamente usando el `Procfile`

### App móvil (APK)

1. Activar instalación de fuentes desconocidas en el dispositivo Android
2. Transferir el APK al dispositivo
3. Abrir el APK e instalar
4. Abrir IamDex y crear una cuenta

## Autor

**Iam Silva Vázquez**  
2.º DAM · CIFP A Carballeira Marcos-Valcárcel · Ourense  
Curso 2025/2026

---

© 2026 Iam Silva Vázquez. Todos los derechos reservados.  
Queda prohibida la reproducción, distribución o uso de este proyecto sin autorización expresa del autor.
