"""
Tests unitarios para LangChain Service
"""

import pytest
import asyncio
from unittest.mock import Mock, patch, AsyncMock
from langchain_service import LangChainService
from chains.code_analysis import CodeAnalysisChain

class TestLangChainService:
    """Tests para LangChainService"""
    
    @pytest.fixture
    def service(self):
        """Fixture para crear instancia del servicio"""
        with patch.dict('os.environ', {
            'OPENAI_API_KEY': 'test-key',
            'OPENAI_MODEL': 'gpt-4o-mini',
            'OPENAI_MAX_TOKENS': '150',
            'OPENAI_TEMPERATURE': '0.7'
        }):
            return LangChainService()
    
    def test_service_initialization(self, service):
        """Test inicialización del servicio"""
        assert service.model_name == 'gpt-4o-mini'
        assert service.max_tokens == 150
        assert service.temperature == 0.7
        assert 'code_analysis' in service.chains
        assert 'architecture_recommendation' in service.chains
        assert 'documentation_generation' in service.chains
        assert 'conversational_chat' in service.chains
    
    @pytest.mark.asyncio
    async def test_analyze_code_demo_mode(self, service):
        """Test análisis de código en modo demo"""
        # Simular modo demo (sin API key)
        service.chains['code_analysis'] = None
        
        result = await service.analyze_code(
            code_content="console.log('Hello World');",
            metadata={"language": "javascript"}
        )
        
        assert result["analysis"] is not None
        assert "Análisis de Código (Modo Demo)" in result["analysis"]
        assert result["metadata"]["model"] == "demo-mode"
        assert result["metadata"]["tokens_used"] == 0
    
    @pytest.mark.asyncio
    async def test_recommend_architecture_demo_mode(self, service):
        """Test recomendación arquitectónica en modo demo"""
        service.chains['architecture_recommendation'] = None
        
        result = await service.recommend_architecture(
            code_analysis="Test analysis",
            reference_architectures=["Microservices"],
            project_requirements="Test requirements"
        )
        
        assert result["recommendation"] is not None
        assert "Recomendación Arquitectónica (Modo Demo)" in result["recommendation"]
        assert result["metadata"]["model"] == "demo-mode"
    
    @pytest.mark.asyncio
    async def test_generate_documentation_demo_mode(self, service):
        """Test generación de documentación en modo demo"""
        service.chains['documentation_generation'] = None
        
        result = await service.generate_documentation(
            code_analysis="Test analysis",
            architecture_recommendation="Test recommendation",
            doc_type="README"
        )
        
        assert result["documentation"] is not None
        assert "Proyecto Demo - Documentación Automática" in result["documentation"]
        assert result["metadata"]["model"] == "demo-mode"
    
    @pytest.mark.asyncio
    async def test_chat_completion_demo_mode(self, service):
        """Test chat completion en modo demo"""
        service.chains['conversational_chat'] = None
        
        result = await service.chat_completion("Hello, how are you?")
        
        assert result["response"] is not None
        assert "asistente DevOps con IA (modo demo)" in result["response"]
        assert result["metadata"]["model"] == "demo-mode"

class TestCodeAnalysisChain:
    """Tests para CodeAnalysisChain"""
    
    @pytest.fixture
    def mock_llm(self):
        """Mock LLM para testing"""
        llm = Mock()
        llm.arun = AsyncMock(return_value="Mock analysis result")
        return llm
    
    @pytest.fixture
    def chain(self, mock_llm):
        """Fixture para crear chain de análisis"""
        return CodeAnalysisChain(mock_llm)
    
    @pytest.mark.asyncio
    async def test_analyze_code(self, chain):
        """Test análisis de código"""
        result = await chain.analyze(
            code_content="function hello() { return 'world'; }",
            metadata={"language": "javascript", "framework": "none"},
            additional_files={"package.json": '{"name": "test"}'}
        )
        
        # Verificar que el chain fue llamado
        chain.chain.arun.assert_called_once()
        assert result is not None
    
    def test_get_analysis_summary(self, chain):
        """Test generación de resumen"""
        analysis = {
            "technologies": [
                {"name": "React", "type": "Framework"},
                {"name": "Node.js", "type": "Runtime"}
            ],
            "architecture_pattern": {"type": "MVC"},
            "components": ["Controller", "Service", "Model"],
            "recommendations": ["Add tests", "Improve documentation"]
        }
        
        summary = chain.get_analysis_summary(analysis)
        
        assert "React" in summary
        assert "MVC" in summary
        assert "3 identificados" in summary
        assert "2 sugerencias" in summary

@pytest.mark.integration
class TestLangChainIntegration:
    """Tests de integración con LangChain real"""
    
    @pytest.mark.skipif(
        not pytest.config.getoption("--integration"),
        reason="Integration tests require --integration flag"
    )
    @pytest.mark.asyncio
    async def test_real_openai_analysis(self):
        """Test con OpenAI real (requiere API key válida)"""
        import os
        if not os.getenv("OPENAI_API_KEY"):
            pytest.skip("OpenAI API key not available")
        
        service = LangChainService()
        
        # Test con código simple
        result = await service.analyze_code(
            code_content="""
            const express = require('express');
            const app = express();
            
            app.get('/', (req, res) => {
                res.json({ message: 'Hello World' });
            });
            
            app.listen(3000);
            """,
            metadata={"language": "javascript", "framework": "express"}
        )
        
        assert result["analysis"] is not None
        assert result["metadata"]["tokens_used"] > 0
        assert "express" in result["analysis"].lower()

# Configuración de pytest
def pytest_addoption(parser):
    """Agregar opciones de pytest"""
    parser.addoption(
        "--integration",
        action="store_true",
        default=False,
        help="Run integration tests"
    )

def pytest_configure(config):
    """Configurar pytest"""
    config.addinivalue_line(
        "markers", "integration: mark test as integration test"
    )

if __name__ == "__main__":
    # Ejecutar tests
    pytest.main([__file__, "-v"])
