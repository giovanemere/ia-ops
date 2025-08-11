# Troubleshooting Guide

## Common Issues

### Service Startup Issues

#### Docker Compose Services Not Starting
```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs [service-name]

# Restart services
docker-compose restart [service-name]
```

#### Port Conflicts
```bash
# Check port usage
netstat -tulpn | grep :8080

# Stop conflicting services
sudo systemctl stop [service-name]
```

### GitHub Integration Issues

#### Authentication Failures
1. Verify GitHub token has correct permissions
2. Check client ID and secret configuration
3. Ensure callback URLs are correctly configured

#### Repository Access Issues
```bash
# Test GitHub API access
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user
```

### OpenAI Service Issues

#### API Key Problems
1. Verify OpenAI API key is valid
2. Check API quota and billing status
3. Ensure correct model is specified

#### Connection Timeouts
```bash
# Test OpenAI API connectivity
curl -X POST https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"test"}]}'
```

### Database Issues

#### PostgreSQL Connection Problems
```bash
# Check database status
docker-compose exec postgres pg_isready

# Connect to database
docker-compose exec postgres psql -U postgres -d backstage
```

#### Migration Issues
```bash
# Run migrations manually
docker-compose exec backstage yarn backstage-cli migrate:up
```

### Backstage Catalog Issues

#### Entities Not Loading
1. Check catalog configuration in `app-config.yaml`
2. Verify repository permissions
3. Check entity YAML syntax

#### Discovery Problems
```bash
# Refresh catalog
curl -X POST http://localhost:8080/api/catalog/refresh
```

## Performance Issues

### High Memory Usage
- Monitor container memory usage
- Adjust Docker memory limits
- Check for memory leaks in logs

### Slow Response Times
- Check network connectivity
- Monitor database performance
- Review service logs for bottlenecks

## Getting Help

1. Check service logs: `docker-compose logs -f [service]`
2. Review GitHub Issues: [Repository Issues](https://github.com/giovanemere/ia-ops/issues)
3. Contact support: devops@tu-organizacion.com

## Debug Mode

Enable debug logging by setting:
```bash
LOG_LEVEL=debug
NODE_ENV=development
```
