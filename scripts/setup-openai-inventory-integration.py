#!/usr/bin/env python3
"""
Script para configurar la integración del servicio OpenAI con el inventario de aplicaciones DevOps
"""

import os
import json
import pandas as pd
from pathlib import Path

def load_devops_inventory():
    """Cargar el inventario de aplicaciones DevOps desde Excel"""
    inventory_path = Path("framework/apps/Listado Aplicaciones DevOps.xlsx")
    
    if not inventory_path.exists():
        print(f"❌ No se encontró el archivo de inventario: {inventory_path}")
        return None
    
    try:
        # Leer el archivo Excel
        df = pd.read_excel(inventory_path)
        print(f"✅ Inventario cargado: {len(df)} aplicaciones encontradas")
        return df
    except Exception as e:
        print(f"❌ Error al cargar el inventario: {e}")
        return None

def generate_openai_context():
    """Generar contexto para el servicio OpenAI basado en el inventario"""
    df = load_devops_inventory()
    if df is None:
        return None
    
    # Generar contexto estructurado
    context = {
        "applications": [],
        "cloud_providers": set(),
        "technologies": set(),
        "deployment_patterns": set()
    }
    
    for _, row in df.iterrows():
        app_info = {
            "name": row.get("Aplicación", ""),
            "description": row.get("Descripción", ""),
            "cloud_provider": row.get("Proveedor Cloud", ""),
            "technology_stack": row.get("Stack Tecnológico", ""),
            "deployment_type": row.get("Tipo Despliegue", ""),
            "status": row.get("Estado", ""),
            "team": row.get("Equipo", "")
        }
        
        context["applications"].append(app_info)
        
        if app_info["cloud_provider"]:
            context["cloud_providers"].add(app_info["cloud_provider"])
        if app_info["technology_stack"]:
            context["technologies"].add(app_info["technology_stack"])
        if app_info["deployment_type"]:
            context["deployment_patterns"].add(app_info["deployment_type"])
    
    # Convertir sets a listas para JSON
    context["cloud_providers"] = list(context["cloud_providers"])
    context["technologies"] = list(context["technologies"])
    context["deployment_patterns"] = list(context["deployment_patterns"])
    
    return context

def create_openai_knowledge_base():
    """Crear base de conocimiento para OpenAI"""
    context = generate_openai_context()
    if not context:
        return False
    
    knowledge_base = {
        "version": "1.0",
        "last_updated": "2025-08-11",
        "description": "Base de conocimiento de aplicaciones DevOps para IA-Ops Platform",
        "statistics": {
            "total_applications": len(context["applications"]),
            "cloud_providers": len(context["cloud_providers"]),
            "technologies": len(context["technologies"]),
            "deployment_patterns": len(context["deployment_patterns"])
        },
        "data": context
    }
    
    # Guardar la base de conocimiento
    kb_path = Path("config/openai/knowledge_base.json")
    kb_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(kb_path, 'w', encoding='utf-8') as f:
        json.dump(knowledge_base, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Base de conocimiento creada: {kb_path}")
    return True

def generate_openai_prompts():
    """Generar prompts específicos para el contexto DevOps"""
    prompts = {
        "system_prompt": """
Eres un asistente especializado en DevOps y arquitectura de aplicaciones para la plataforma IA-Ops.
Tienes acceso a un inventario completo de aplicaciones DevOps que incluye:

- Aplicaciones desplegadas en múltiples proveedores cloud (AWS, Azure, GCP, OCI)
- Stacks tecnológicos diversos
- Patrones de despliegue variados
- Estados y equipos responsables

Tu función es ayudar con:
1. Recomendaciones de arquitectura
2. Selección de templates apropiados
3. Mejores prácticas de despliegue
4. Troubleshooting de aplicaciones
5. Optimización de recursos

Siempre proporciona respuestas basadas en el contexto del inventario disponible.
        """.strip(),
        
        "architecture_prompt": """
Basándote en el inventario de aplicaciones DevOps disponible, proporciona recomendaciones de arquitectura
considerando:
- Patrones existentes exitosos
- Proveedores cloud utilizados
- Stacks tecnológicos compatibles
- Mejores prácticas observadas
        """.strip(),
        
        "template_selection_prompt": """
Ayuda a seleccionar el template más apropiado del catálogo multi-cloud considerando:
- Proveedor cloud objetivo
- Stack tecnológico requerido
- Patrón de despliegue deseado
- Experiencias previas documentadas en el inventario
        """.strip(),
        
        "troubleshooting_prompt": """
Proporciona asistencia para troubleshooting basándote en:
- Problemas similares documentados en el inventario
- Configuraciones exitosas de aplicaciones similares
- Mejores prácticas específicas del proveedor cloud
- Patrones de solución observados
        """.strip()
    }
    
    # Guardar los prompts
    prompts_path = Path("config/openai/prompts.json")
    with open(prompts_path, 'w', encoding='utf-8') as f:
        json.dump(prompts, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Prompts generados: {prompts_path}")
    return True

def update_openai_service_config():
    """Actualizar configuración del servicio OpenAI"""
    config = {
        "knowledge_base_enabled": True,
        "knowledge_base_path": "/app/config/knowledge_base.json",
        "prompts_path": "/app/config/prompts.json",
        "context_window": 4000,
        "temperature": 0.7,
        "max_tokens": 2000,
        "features": {
            "architecture_recommendations": True,
            "template_selection": True,
            "troubleshooting_assistance": True,
            "best_practices": True
        }
    }
    
    config_path = Path("config/openai/service_config.json")
    with open(config_path, 'w', encoding='utf-8') as f:
        json.dump(config, f, indent=2)
    
    print(f"✅ Configuración del servicio actualizada: {config_path}")
    return True

def main():
    """Función principal"""
    print("🚀 Configurando integración OpenAI con inventario DevOps...")
    
    # Crear directorios necesarios
    Path("config/openai").mkdir(parents=True, exist_ok=True)
    
    # Ejecutar configuración
    steps = [
        ("Creando base de conocimiento", create_openai_knowledge_base),
        ("Generando prompts especializados", generate_openai_prompts),
        ("Actualizando configuración del servicio", update_openai_service_config)
    ]
    
    success_count = 0
    for step_name, step_func in steps:
        print(f"\n📋 {step_name}...")
        if step_func():
            success_count += 1
        else:
            print(f"❌ Error en: {step_name}")
    
    print(f"\n🎯 Configuración completada: {success_count}/{len(steps)} pasos exitosos")
    
    if success_count == len(steps):
        print("\n✅ ¡Integración configurada exitosamente!")
        print("\n📚 Próximos pasos:")
        print("1. Reiniciar el servicio OpenAI para cargar la nueva configuración")
        print("2. Probar las nuevas funcionalidades de recomendación")
        print("3. Validar la integración con Backstage")
    else:
        print("\n⚠️  Algunos pasos fallaron. Revisar los errores anteriores.")

if __name__ == "__main__":
    main()
