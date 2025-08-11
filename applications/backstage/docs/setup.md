# Setup Guide

This guide will help you set up and configure the IA-OPS Developer Portal.

## Prerequisites

- Docker & Docker Compose
- Node.js 18+
- Python 3.11+
- Git

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd ia-ops/applications/backstage
```

### 2. Environment Configuration

Copy the environment file and configure your settings:

```bash
cp ../../.env.example ../../.env
```

Edit the `.env` file with your specific configuration:

```bash
# GitHub Integration
GITHUB_TOKEN=your_github_token
AUTH_GITHUB_CLIENT_ID=your_client_id
AUTH_GITHUB_CLIENT_SECRET=your_client_secret

# OpenAI Integration
OPENAI_API_KEY=your_openai_api_key

# Database
POSTGRES_USER=backstage_user
POSTGRES_PASSWORD=your_password
POSTGRES_DB=backstage_db
```

### 3. Install Dependencies

```bash
yarn install
```

### 4. Database Setup

Start the PostgreSQL database:

```bash
docker-compose up -d postgres
```

### 5. Start the Application

```bash
yarn dev
```

## Configuration

### GitHub Integration

1. Create a GitHub App or Personal Access Token
2. Configure the token in your `.env` file
3. Set up OAuth for user authentication (optional)

### OpenAI Integration

1. Obtain an OpenAI API key
2. Configure the key in your `.env` file
3. Adjust model settings as needed

### TechDocs

TechDocs is configured to work with local documentation by default. To use with GitHub repositories:

1. Ensure your repositories have `mkdocs.yml` files
2. Add the `backstage.io/techdocs-ref` annotation to your components
3. Configure the TechDocs builder in `app-config.yaml`

## Troubleshooting

### Common Issues

**Port conflicts**: Ensure ports 3000 and 7007 are available
**Database connection**: Verify PostgreSQL is running and accessible
**GitHub authentication**: Check your GitHub token permissions
**OpenAI errors**: Verify your API key and quota

### Logs

Check application logs for detailed error information:

```bash
yarn dev --verbose
```
