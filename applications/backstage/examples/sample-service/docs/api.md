# API Reference

The Sample Service provides a RESTful API for managing resources and data.

## Base URL

```
https://api.sample-service.com/v1
```

## Authentication

All API requests require authentication using JWT tokens:

```bash
curl -H "Authorization: Bearer <your-jwt-token>" \
     https://api.sample-service.com/v1/users
```

### Getting a Token

```bash
POST /auth/login
Content-Type: application/json

{
  "username": "your-username",
  "password": "your-password"
}
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "user": {
    "id": "123",
    "username": "your-username",
    "role": "user"
  }
}
```

## Endpoints

### Users

#### List Users

```http
GET /users
```

Query Parameters:
- `page` (integer): Page number (default: 1)
- `limit` (integer): Items per page (default: 20, max: 100)
- `search` (string): Search term for filtering users

Example:
```bash
curl -H "Authorization: Bearer <token>" \
     "https://api.sample-service.com/v1/users?page=1&limit=10&search=john"
```

Response:
```json
{
  "data": [
    {
      "id": "123",
      "username": "john_doe",
      "email": "john@example.com",
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-08-08T21:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 1,
    "pages": 1
  }
}
```

#### Get User

```http
GET /users/{id}
```

Parameters:
- `id` (string): User ID

Example:
```bash
curl -H "Authorization: Bearer <token>" \
     https://api.sample-service.com/v1/users/123
```

#### Create User

```http
POST /users
```

Request Body:
```json
{
  "username": "new_user",
  "email": "user@example.com",
  "password": "secure_password",
  "role": "user"
}
```

#### Update User

```http
PUT /users/{id}
```

Request Body:
```json
{
  "username": "updated_username",
  "email": "updated@example.com"
}
```

#### Delete User

```http
DELETE /users/{id}
```

### Resources

#### List Resources

```http
GET /resources
```

Query Parameters:
- `category` (string): Filter by category
- `status` (string): Filter by status (active, inactive, pending)
- `sort` (string): Sort field (name, created_at, updated_at)
- `order` (string): Sort order (asc, desc)

#### Get Resource

```http
GET /resources/{id}
```

#### Create Resource

```http
POST /resources
```

Request Body:
```json
{
  "name": "Resource Name",
  "description": "Resource description",
  "category": "category_name",
  "metadata": {
    "key1": "value1",
    "key2": "value2"
  }
}
```

## Error Handling

The API uses standard HTTP status codes and returns error details in JSON format:

### Error Response Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

### Common Error Codes

| Status Code | Error Code | Description |
|-------------|------------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request data |
| 401 | `UNAUTHORIZED` | Missing or invalid authentication |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Resource not found |
| 409 | `CONFLICT` | Resource already exists |
| 429 | `RATE_LIMIT_EXCEEDED` | Too many requests |
| 500 | `INTERNAL_ERROR` | Server error |

## Rate Limiting

The API implements rate limiting to ensure fair usage:

- **Authenticated requests**: 1000 requests per hour
- **Unauthenticated requests**: 100 requests per hour

Rate limit headers are included in responses:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1691524800
```

## Webhooks

The service supports webhooks for real-time notifications:

### Webhook Events

- `user.created` - New user registered
- `user.updated` - User information changed
- `user.deleted` - User account deleted
- `resource.created` - New resource created
- `resource.updated` - Resource modified

### Webhook Payload

```json
{
  "event": "user.created",
  "timestamp": "2024-08-08T21:00:00Z",
  "data": {
    "id": "123",
    "username": "new_user",
    "email": "user@example.com"
  }
}
```

## SDKs and Libraries

Official SDKs are available for popular programming languages:

=== "JavaScript/Node.js"
    ```bash
    npm install @sample-service/sdk
    ```
    
    ```javascript
    import { SampleServiceClient } from '@sample-service/sdk';
    
    const client = new SampleServiceClient({
      apiKey: 'your-api-key',
      baseUrl: 'https://api.sample-service.com/v1'
    });
    
    const users = await client.users.list();
    ```

=== "Python"
    ```bash
    pip install sample-service-sdk
    ```
    
    ```python
    from sample_service import Client
    
    client = Client(api_key='your-api-key')
    users = client.users.list()
    ```

=== "Go"
    ```bash
    go get github.com/sample-service/go-sdk
    ```
    
    ```go
    import "github.com/sample-service/go-sdk"
    
    client := sdk.NewClient("your-api-key")
    users, err := client.Users.List()
    ```

!!! info "API Versioning"
    The API uses semantic versioning. Breaking changes will result in a new major version (e.g., v2). We maintain backward compatibility for at least 12 months after a new version is released.
