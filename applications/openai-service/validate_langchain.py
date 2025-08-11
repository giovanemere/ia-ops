#!/usr/bin/env python3
"""
Script de validación para LangChain Service
Verifica que todos los componentes estén funcionando correctamente
"""

import asyncio
import os
import sys
import json
from datetime import datetime
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Agregar el directorio actual al path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

try:
    from langchain_service import langchain_service
    from chains.code_analysis import CodeAnalysisChain
    from prompts.analysis_prompts import analysis_prompts
except ImportError as e:
    print(f"❌ Error importing modules: {e}")
    print("💡 Make sure to install requirements: pip install -r requirements.txt")
    sys.exit(1)

class LangChainValidator:
    """Validador para LangChain Service"""
    
    def __init__(self):
        self.results = {
            "timestamp": datetime.now().isoformat(),
            "tests": {},
            "summary": {
                "total": 0,
                "passed": 0,
                "failed": 0,
                "warnings": 0
            }
        }
    
    def log_test(self, test_name: str, status: str, message: str, details: dict = None):
        """Registrar resultado de test"""
        self.results["tests"][test_name] = {
            "status": status,
            "message": message,
            "details": details or {},
            "timestamp": datetime.now().isoformat()
        }
        
        self.results["summary"]["total"] += 1
        if status == "PASS":
            self.results["summary"]["passed"] += 1
            print(f"✅ {test_name}: {message}")
        elif status == "FAIL":
            self.results["summary"]["failed"] += 1
            print(f"❌ {test_name}: {message}")
        elif status == "WARN":
            self.results["summary"]["warnings"] += 1
            print(f"⚠️  {test_name}: {message}")
    
    def test_environment_variables(self):
        """Test variables de entorno"""
        try:
            api_key = os.getenv("OPENAI_API_KEY")
            model = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
            max_tokens = os.getenv("OPENAI_MAX_TOKENS", "150")
            temperature = os.getenv("OPENAI_TEMPERATURE", "0.7")
            
            if not api_key:
                self.log_test(
                    "environment_variables",
                    "WARN",
                    "OpenAI API key not configured - running in demo mode",
                    {"demo_mode": True}
                )
            else:
                self.log_test(
                    "environment_variables",
                    "PASS",
                    f"Environment configured - Model: {model}, Tokens: {max_tokens}",
                    {
                        "api_key_configured": True,
                        "model": model,
                        "max_tokens": max_tokens,
                        "temperature": temperature
                    }
                )
                
        except Exception as e:
            self.log_test(
                "environment_variables",
                "FAIL",
                f"Environment validation failed: {str(e)}"
            )
    
    def test_langchain_service_initialization(self):
        """Test inicialización del servicio LangChain"""
        try:
            # Verificar que el servicio se inicializó
            if hasattr(langchain_service, 'model_name'):
                self.log_test(
                    "langchain_service_init",
                    "PASS",
                    f"LangChain service initialized with model: {langchain_service.model_name}",
                    {
                        "model": langchain_service.model_name,
                        "max_tokens": langchain_service.max_tokens,
                        "temperature": langchain_service.temperature
                    }
                )
            else:
                self.log_test(
                    "langchain_service_init",
                    "FAIL",
                    "LangChain service not properly initialized"
                )
                
        except Exception as e:
            self.log_test(
                "langchain_service_init",
                "FAIL",
                f"LangChain service initialization failed: {str(e)}"
            )
    
    def test_chains_availability(self):
        """Test disponibilidad de chains"""
        try:
            expected_chains = [
                'code_analysis',
                'architecture_recommendation', 
                'documentation_generation',
                'conversational_chat'
            ]
            
            available_chains = list(langchain_service.chains.keys()) if langchain_service.chains else []
            missing_chains = [chain for chain in expected_chains if chain not in available_chains]
            
            if not missing_chains:
                self.log_test(
                    "chains_availability",
                    "PASS",
                    f"All {len(expected_chains)} chains available",
                    {"available_chains": available_chains}
                )
            else:
                self.log_test(
                    "chains_availability",
                    "WARN",
                    f"Missing chains: {missing_chains}",
                    {
                        "available_chains": available_chains,
                        "missing_chains": missing_chains
                    }
                )
                
        except Exception as e:
            self.log_test(
                "chains_availability",
                "FAIL",
                f"Chains availability check failed: {str(e)}"
            )
    
    async def test_code_analysis_functionality(self):
        """Test funcionalidad de análisis de código"""
        try:
            test_code = """
            const express = require('express');
            const app = express();
            
            app.get('/health', (req, res) => {
                res.json({ status: 'healthy' });
            });
            
            app.listen(3000, () => {
                console.log('Server running on port 3000');
            });
            """
            
            result = await langchain_service.analyze_code(
                code_content=test_code,
                metadata={"language": "javascript", "framework": "express"}
            )
            
            if result and "analysis" in result:
                self.log_test(
                    "code_analysis_functionality",
                    "PASS",
                    "Code analysis completed successfully",
                    {
                        "analysis_length": len(result["analysis"]),
                        "tokens_used": result["metadata"].get("tokens_used", 0),
                        "model": result["metadata"].get("model", "unknown")
                    }
                )
            else:
                self.log_test(
                    "code_analysis_functionality",
                    "FAIL",
                    "Code analysis returned invalid result"
                )
                
        except Exception as e:
            self.log_test(
                "code_analysis_functionality",
                "FAIL",
                f"Code analysis test failed: {str(e)}"
            )
    
    async def test_architecture_recommendation(self):
        """Test recomendación arquitectónica"""
        try:
            test_analysis = "Test analysis: Express.js application with REST API"
            
            result = await langchain_service.recommend_architecture(
                code_analysis=test_analysis,
                reference_architectures=["Microservices", "Monolithic"],
                project_requirements="Small web application"
            )
            
            if result and "recommendation" in result:
                self.log_test(
                    "architecture_recommendation",
                    "PASS",
                    "Architecture recommendation completed successfully",
                    {
                        "recommendation_length": len(result["recommendation"]),
                        "tokens_used": result["metadata"].get("tokens_used", 0)
                    }
                )
            else:
                self.log_test(
                    "architecture_recommendation",
                    "FAIL",
                    "Architecture recommendation returned invalid result"
                )
                
        except Exception as e:
            self.log_test(
                "architecture_recommendation",
                "FAIL",
                f"Architecture recommendation test failed: {str(e)}"
            )
    
    async def test_documentation_generation(self):
        """Test generación de documentación"""
        try:
            test_analysis = "Express.js REST API application"
            test_recommendation = "Microservices architecture recommended"
            
            result = await langchain_service.generate_documentation(
                code_analysis=test_analysis,
                architecture_recommendation=test_recommendation,
                doc_type="README"
            )
            
            if result and "documentation" in result:
                self.log_test(
                    "documentation_generation",
                    "PASS",
                    "Documentation generation completed successfully",
                    {
                        "documentation_length": len(result["documentation"]),
                        "tokens_used": result["metadata"].get("tokens_used", 0)
                    }
                )
            else:
                self.log_test(
                    "documentation_generation",
                    "FAIL",
                    "Documentation generation returned invalid result"
                )
                
        except Exception as e:
            self.log_test(
                "documentation_generation",
                "FAIL",
                f"Documentation generation test failed: {str(e)}"
            )
    
    async def test_chat_completion(self):
        """Test chat completion"""
        try:
            result = await langchain_service.chat_completion(
                "Hello, can you help me analyze some code?"
            )
            
            if result and "response" in result:
                self.log_test(
                    "chat_completion",
                    "PASS",
                    "Chat completion working correctly",
                    {
                        "response_length": len(result["response"]),
                        "tokens_used": result["metadata"].get("tokens_used", 0)
                    }
                )
            else:
                self.log_test(
                    "chat_completion",
                    "FAIL",
                    "Chat completion returned invalid result"
                )
                
        except Exception as e:
            self.log_test(
                "chat_completion",
                "FAIL",
                f"Chat completion test failed: {str(e)}"
            )
    
    def test_prompts_availability(self):
        """Test disponibilidad de prompts"""
        try:
            # Verificar que los prompts están disponibles
            code_prompt = analysis_prompts.get_code_analysis_prompt()
            arch_prompt = analysis_prompts.get_architecture_recommendation_prompt()
            doc_prompt = analysis_prompts.get_documentation_generation_prompt()
            
            if all([code_prompt, arch_prompt, doc_prompt]):
                self.log_test(
                    "prompts_availability",
                    "PASS",
                    "All specialized prompts available",
                    {
                        "code_analysis_prompt": bool(code_prompt),
                        "architecture_prompt": bool(arch_prompt),
                        "documentation_prompt": bool(doc_prompt)
                    }
                )
            else:
                self.log_test(
                    "prompts_availability",
                    "FAIL",
                    "Some prompts are missing"
                )
                
        except Exception as e:
            self.log_test(
                "prompts_availability",
                "FAIL",
                f"Prompts availability check failed: {str(e)}"
            )
    
    async def run_all_tests(self):
        """Ejecutar todos los tests"""
        print("🔍 Starting LangChain Service Validation...")
        print("=" * 50)
        
        # Tests síncronos
        self.test_environment_variables()
        self.test_langchain_service_initialization()
        self.test_chains_availability()
        self.test_prompts_availability()
        
        # Tests asíncronos
        await self.test_code_analysis_functionality()
        await self.test_architecture_recommendation()
        await self.test_documentation_generation()
        await self.test_chat_completion()
        
        # Mostrar resumen
        print("\n" + "=" * 50)
        print("📊 VALIDATION SUMMARY")
        print("=" * 50)
        
        summary = self.results["summary"]
        print(f"✅ Passed: {summary['passed']}")
        print(f"❌ Failed: {summary['failed']}")
        print(f"⚠️  Warnings: {summary['warnings']}")
        print(f"📊 Total: {summary['total']}")
        
        success_rate = (summary['passed'] / summary['total']) * 100 if summary['total'] > 0 else 0
        print(f"🎯 Success Rate: {success_rate:.1f}%")
        
        if summary['failed'] == 0:
            print("\n🎉 All critical tests passed! LangChain service is ready.")
            return True
        else:
            print(f"\n⚠️  {summary['failed']} tests failed. Check the details above.")
            return False
    
    def save_results(self, filename: str = "langchain_validation_results.json"):
        """Guardar resultados en archivo JSON"""
        try:
            with open(filename, 'w') as f:
                json.dump(self.results, f, indent=2)
            print(f"📄 Results saved to {filename}")
        except Exception as e:
            print(f"❌ Failed to save results: {e}")

async def main():
    """Función principal"""
    validator = LangChainValidator()
    
    try:
        success = await validator.run_all_tests()
        validator.save_results()
        
        # Exit code basado en el resultado
        sys.exit(0 if success else 1)
        
    except KeyboardInterrupt:
        print("\n⚠️  Validation interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Validation failed with error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
