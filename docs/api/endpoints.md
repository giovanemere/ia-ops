# API Endpoints

## Overview

This section documents the available API endpoints for the IA-Ops Platform.

## OpenAI Service Endpoints

### Chat Completions
- **Endpoint**: `/openai/chat/completions`
- **Method**: `POST`
- **Description**: Process chat completions with DevOps context

### Health Check
- **Endpoint**: `/openai/health`
- **Method**: `GET`
- **Description**: Check OpenAI service health

## Backstage API Endpoints

### Catalog
- **Endpoint**: `/api/catalog/entities`
- **Method**: `GET`
- **Description**: Retrieve catalog entities

### Templates
- **Endpoint**: `/api/scaffolder/v2/templates`
- **Method**: `GET`
- **Description**: List available templates

## Proxy Service Endpoints

### Gateway
- **Endpoint**: `/`
- **Method**: `GET`
- **Description**: Main gateway endpoint

For detailed API documentation, refer to the OpenAPI specifications in each service.
