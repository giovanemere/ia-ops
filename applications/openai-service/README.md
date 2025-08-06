# 🤖 OpenAI Service

## Descripción
Servicio nativo de IA basado en FastAPI que proporciona endpoints compatibles con OpenAI API.

## Estructura
```
openai-service/
├── app/
│   ├── main.py           # Aplicación principal
│   ├── models/           # Modelos de datos
│   ├── services/         # Lógica de negocio
│   └── utils/            # Utilidades
├── knowledge/
│   └── applications.yaml # Base de conocimiento
├── tests/
│   └── test_*.py         # Tests unitarios
└── requirements.txt      # Dependencias Python
```

## Endpoints
- `POST /chat/completions` - Chat interactivo
- `POST /completions` - Completions simples
- `GET /health` - Health check

## Configuración
- **Puerto**: 8000
- **Framework**: FastAPI
- **Modo Demo**: Disponible sin API key
- **Rate Limiting**: 100 req/min

## Variables de Entorno
Ver `../../.env` para configuración completa.

## Comandos
```bash
# Desarrollo
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Docker
docker build -t openai-service .
docker run -p 8000:8000 openai-service

# Test
pytest tests/
```

## Features
- ✅ Modo demo sin API key
- ✅ Base de conocimiento empresarial
- ✅ Rate limiting
- ✅ Health checks
- ✅ CORS configurado
- ✅ Logging estructurado
