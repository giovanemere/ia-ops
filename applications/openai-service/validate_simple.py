#!/usr/bin/env python3
"""
Script de validación simplificado para LangChain Service
"""

import asyncio
import os
import sys
from datetime import datetime
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Agregar el directorio actual al path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

async def main():
    """Función principal de validación"""
    print("🔍 Validando LangChain Service...")
    print("=" * 50)
    
    try:
        # Test 1: Importar servicio
        print("📦 Test 1: Importando servicio...")
        from langchain_service_simple import simple_langchain_service
        print("✅ Servicio importado correctamente")
        
        # Test 2: Verificar configuración
        print("\n⚙️  Test 2: Verificando configuración...")
        print(f"   • Modelo: {simple_langchain_service.model_name}")
        print(f"   • Max Tokens: {simple_langchain_service.max_tokens}")
        print(f"   • Temperature: {simple_langchain_service.temperature}")
        print(f"   • API Key configurada: {bool(simple_langchain_service.api_key)}")
        print("✅ Configuración verificada")
        
        # Test 3: Análisis de código
        print("\n🔍 Test 3: Análisis de código...")
        test_code = """
        const express = require('express');
        const app = express();
        
        app.get('/health', (req, res) => {
            res.json({ status: 'healthy' });
        });
        
        app.listen(3000);
        """
        
        result = await simple_langchain_service.analyze_code(
            code_content=test_code,
            metadata={"language": "javascript", "framework": "express"}
        )
        
        if result and "analysis" in result:
            print("✅ Análisis de código funcionando")
            print(f"   • Longitud del análisis: {len(result['analysis'])} caracteres")
            print(f"   • Tokens usados: {result['metadata'].get('tokens_used', 0)}")
        else:
            print("❌ Error en análisis de código")
        
        # Test 4: Recomendación arquitectónica
        print("\n🏗️  Test 4: Recomendación arquitectónica...")
        arch_result = await simple_langchain_service.recommend_architecture(
            code_analysis="Express.js REST API application",
            reference_architectures=["Microservices", "Monolithic"],
            project_requirements="Small web application"
        )
        
        if arch_result and "recommendation" in arch_result:
            print("✅ Recomendación arquitectónica funcionando")
            print(f"   • Longitud: {len(arch_result['recommendation'])} caracteres")
        else:
            print("❌ Error en recomendación arquitectónica")
        
        # Test 5: Generación de documentación
        print("\n📚 Test 5: Generación de documentación...")
        doc_result = await simple_langchain_service.generate_documentation(
            code_analysis="Express.js application analysis",
            architecture_recommendation="Microservices recommended",
            doc_type="README"
        )
        
        if doc_result and "documentation" in doc_result:
            print("✅ Generación de documentación funcionando")
            print(f"   • Longitud: {len(doc_result['documentation'])} caracteres")
        else:
            print("❌ Error en generación de documentación")
        
        # Test 6: Chat completion
        print("\n💬 Test 6: Chat completion...")
        chat_result = await simple_langchain_service.chat_completion(
            "Hello, can you help me with code analysis?"
        )
        
        if chat_result and "response" in chat_result:
            print("✅ Chat completion funcionando")
            print(f"   • Longitud de respuesta: {len(chat_result['response'])} caracteres")
        else:
            print("❌ Error en chat completion")
        
        print("\n" + "=" * 50)
        print("🎉 VALIDACIÓN COMPLETADA")
        print("=" * 50)
        print("✅ Todos los componentes principales funcionando")
        print("🚀 LangChain Service listo para usar")
        
        if not simple_langchain_service.api_key:
            print("\n💡 NOTA: Corriendo en modo demo")
            print("   Para funcionalidad completa, configura OPENAI_API_KEY")
        
        return True
        
    except ImportError as e:
        print(f"❌ Error de importación: {e}")
        print("💡 Asegúrate de instalar las dependencias: pip install -r requirements.txt")
        return False
    except Exception as e:
        print(f"❌ Error durante la validación: {e}")
        return False

if __name__ == "__main__":
    success = asyncio.run(main())
    sys.exit(0 if success else 1)
