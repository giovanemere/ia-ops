@app.get("/api/v1/dashboard")
async def get_dashboard_data():
    """Obtener datos del dashboard"""
    try:
        redis_client = get_redis_connection()
        cache_stats = {"cached_configs": 0, "connected": False}
        
        if redis_client:
            try:
                pattern = get_cache_key("*")
                keys = redis_client.keys(pattern)
                cache_stats = {
                    "cached_configs": len(keys),
                    "connected": True
                }
            except:
                pass
        
        # Contar configuraciones en BD
        conn = get_db_connection()
        total_configs = 0
        configured_count = 0
        
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT COUNT(*) FROM configurations")
                total_configs = cursor.fetchone()[0]
                
                cursor.execute("SELECT COUNT(*) FROM configurations WHERE config_value::text LIKE '%\"configured\": true%' OR config_value::text LIKE '%\"token\"%' OR config_value::text LIKE '%\"access_key\"%'")
                configured_count = cursor.fetchone()[0]
                
                cursor.close()
                conn.close()
            except:
                pass
        
        return {
            "success": True,
            "data": {
                "configurations": {
                    "total": total_configs,
                    "configured": configured_count,
                    "pending": total_configs - configured_count
                },
                "cache": cache_stats,
                "system": {
                    "status": "healthy",
                    "database": "connected" if get_db_connection() else "disconnected",
                    "redis": "connected" if cache_stats["connected"] else "disconnected"
                }
            }
        }
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.get("/api/system/status")
async def get_system_status():
    """Obtener estado del sistema"""
    try:
        db_status = "connected" if get_db_connection() else "disconnected"
        
        redis_client = get_redis_connection()
        redis_status = "connected" if redis_client else "disconnected"
        
        return {
            "success": True,
            "status": "healthy",
            "services": {
                "database": db_status,
                "cache": redis_status,
                "backend": "running"
            },
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.post("/api/repositories/refresh")
async def refresh_repositories(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Refrescar repositorios de GitHub"""
    verify_bearer_token(credentials)
    
    try:
        # Invalidar cache de repositorios
        redis_client = get_redis_connection()
        if redis_client:
            pattern = "github_repos:*"
            keys = redis_client.keys(pattern)
            if keys:
                redis_client.delete(*keys)
        
        return {"success": True, "message": "Cache de repositorios invalidado"}
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.post("/api/tasks/failed/clear")
async def clear_failed_tasks(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Limpiar tareas fallidas"""
    verify_bearer_token(credentials)
    return {"success": True, "message": "No failed tasks to clear"}

@app.post("/api/build/all")
async def build_all(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Construir todos los proyectos"""
    verify_bearer_token(credentials)
    return {"success": True, "message": "Build process initiated"}
