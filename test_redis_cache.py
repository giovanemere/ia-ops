#!/usr/bin/env python3
"""
Script de prueba para Redis cache de configuraciones
"""

import redis
import json
import time

# Configuración de Redis
REDIS_CONFIG = {
    "host": "localhost",  # Cambiar a iaops-redis en producción
    "port": 6380,        # Puerto de Redis en el stack
    "db": 0,
    "decode_responses": True
}

def test_redis_cache():
    """Probar funcionalidad de cache Redis"""
    try:
        # Conectar a Redis
        r = redis.Redis(**REDIS_CONFIG)
        
        print("🔗 Conectando a Redis...")
        r.ping()
        print("✅ Redis conectado correctamente")
        
        # Test 1: Guardar configuración en cache
        print("\n📝 Test 1: Guardar configuración en cache")
        config_key = "config:github"
        config_data = {
            "success": True,
            "config": {
                "token": "ghp_test123",
                "user": "testuser",
                "configured": True
            },
            "type": "provider"
        }
        
        r.setex(config_key, 300, json.dumps(config_data))  # TTL 5 minutos
        print(f"✅ Configuración guardada en cache: {config_key}")
        
        # Test 2: Leer configuración desde cache
        print("\n📖 Test 2: Leer configuración desde cache")
        cached_data = r.get(config_key)
        if cached_data:
            parsed_data = json.loads(cached_data)
            print(f"✅ Configuración leída desde cache:")
            print(f"   Usuario: {parsed_data['config']['user']}")
            print(f"   Configurado: {parsed_data['config']['configured']}")
        
        # Test 3: TTL (Time To Live)
        print("\n⏰ Test 3: Verificar TTL")
        ttl = r.ttl(config_key)
        print(f"✅ TTL restante: {ttl} segundos")
        
        # Test 4: Múltiples configuraciones
        print("\n📚 Test 4: Múltiples configuraciones")
        configs = {
            "config:openai": {
                "success": True,
                "config": {"api_key": "sk-test", "model": "gpt-4", "configured": True},
                "type": "api_provider"
            },
            "config:aws": {
                "success": True,
                "config": {"access_key": "AKIA123", "region": "us-east-1", "configured": True},
                "type": "provider"
            }
        }
        
        for key, data in configs.items():
            r.setex(key, 300, json.dumps(data))
            print(f"✅ Guardado: {key}")
        
        # Test 5: Listar todas las configuraciones
        print("\n📋 Test 5: Listar configuraciones en cache")
        pattern = "config:*"
        keys = r.keys(pattern)
        print(f"✅ Configuraciones en cache ({len(keys)}):")
        for key in keys:
            ttl = r.ttl(key)
            print(f"   - {key} (TTL: {ttl}s)")
        
        # Test 6: Invalidar cache específico
        print("\n🗑️ Test 6: Invalidar cache específico")
        r.delete("config:aws")
        remaining_keys = r.keys(pattern)
        print(f"✅ Cache AWS eliminado. Restantes: {len(remaining_keys)}")
        
        # Test 7: Estadísticas
        print("\n📊 Test 7: Estadísticas de Redis")
        info = r.info()
        print(f"✅ Conexiones: {info.get('connected_clients', 'N/A')}")
        print(f"✅ Memoria usada: {info.get('used_memory_human', 'N/A')}")
        print(f"✅ Keys totales: {info.get('db0', {}).get('keys', 0) if 'db0' in info else 0}")
        
        print("\n🎉 Todos los tests de Redis cache completados exitosamente!")
        return True
        
    except redis.ConnectionError:
        print("❌ Error: No se pudo conectar a Redis")
        print("   Verifica que Redis esté ejecutándose en localhost:6380")
        return False
    except Exception as e:
        print(f"❌ Error inesperado: {e}")
        return False

if __name__ == "__main__":
    print("🧪 Iniciando tests de Redis Cache para IA-Ops")
    print("=" * 50)
    
    success = test_redis_cache()
    
    print("\n" + "=" * 50)
    if success:
        print("✅ Redis cache está funcionando correctamente")
    else:
        print("❌ Redis cache tiene problemas")
