# Getting Started

This guide will help you get up and running with the Sample Service quickly.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Node.js](https://nodejs.org/) (version 18 or higher)
- [Docker](https://www.docker.com/) (for containerized deployment)
- [Git](https://git-scm.com/) (for version control)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/sample-service.git
cd sample-service
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Environment Configuration

Create a `.env` file in the root directory:

```bash
# Database Configuration
DATABASE_URL=postgresql://user:password@localhost:5432/sampledb
REDIS_URL=redis://localhost:6379

# API Configuration
API_PORT=3000
JWT_SECRET=your-secret-key

# External Services
EXTERNAL_API_KEY=your-api-key
EXTERNAL_API_URL=https://api.example.com
```

### 4. Database Setup

Run the database migrations:

```bash
npm run migrate
```

Seed the database with sample data:

```bash
npm run seed
```

## Running the Service

### Development Mode

Start the service in development mode with hot reloading:

```bash
npm run dev
```

The service will be available at `http://localhost:3000`.

### Production Mode

Build and start the service for production:

```bash
npm run build
npm start
```

### Docker

Run using Docker Compose:

```bash
docker-compose up -d
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `API_PORT` | Port for the API server | `3000` |
| `DATABASE_URL` | PostgreSQL connection string | - |
| `REDIS_URL` | Redis connection string | - |
| `JWT_SECRET` | Secret for JWT token signing | - |
| `LOG_LEVEL` | Logging level (debug, info, warn, error) | `info` |

### Feature Flags

The service supports feature flags for gradual rollouts:

```javascript
{
  "features": {
    "newUserInterface": true,
    "advancedAnalytics": false,
    "betaFeatures": false
  }
}
```

## Health Checks

The service provides several health check endpoints:

- `GET /health` - Basic health check
- `GET /health/detailed` - Detailed health information
- `GET /metrics` - Prometheus metrics

Example health check response:

```json
{
  "status": "healthy",
  "timestamp": "2024-08-08T21:00:00Z",
  "version": "1.0.0",
  "dependencies": {
    "database": "connected",
    "redis": "connected",
    "external_api": "available"
  }
}
```

## Next Steps

Now that you have the service running:

1. Explore the [API Reference](api.md) to understand available endpoints
2. Review the [Architecture](architecture.md) to understand the system design
3. Check the [Deployment](deployment.md) guide for production deployment

!!! success "You're Ready!"
    Your Sample Service is now running and ready for development or testing.
