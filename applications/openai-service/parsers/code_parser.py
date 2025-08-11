"""
Parser de código para múltiples lenguajes
Analiza estructura, dependencias y patrones de código
"""

import os
import re
import json
import ast
from typing import Dict, List, Any, Optional, Tuple
from pathlib import Path
import structlog

logger = structlog.get_logger(__name__)

class CodeParser:
    """Parser principal para análisis estático de código"""
    
    def __init__(self):
        self.supported_languages = {
            '.py': 'python',
            '.js': 'javascript',
            '.ts': 'typescript',
            '.jsx': 'javascript',
            '.tsx': 'typescript',
            '.java': 'java',
            '.go': 'go',
            '.rs': 'rust',
            '.php': 'php',
            '.rb': 'ruby',
            '.cs': 'csharp',
            '.cpp': 'cpp',
            '.c': 'c',
            '.h': 'c',
            '.hpp': 'cpp'
        }
        
        self.config_files = {
            'package.json': 'nodejs',
            'pom.xml': 'java',
            'build.gradle': 'java',
            'Cargo.toml': 'rust',
            'go.mod': 'go',
            'composer.json': 'php',
            'Gemfile': 'ruby',
            'requirements.txt': 'python',
            'pyproject.toml': 'python',
            'setup.py': 'python',
            'Dockerfile': 'docker',
            'docker-compose.yml': 'docker',
            'kubernetes.yaml': 'kubernetes',
            'terraform.tf': 'terraform'
        }
    
    def analyze_directory(self, directory_path: str) -> Dict[str, Any]:
        """
        Analizar directorio completo
        """
        try:
            directory_path = Path(directory_path)
            if not directory_path.exists():
                raise ValueError(f"Directory does not exist: {directory_path}")
            
            analysis = {
                "directory_info": self._get_directory_info(directory_path),
                "file_analysis": self._analyze_files(directory_path),
                "project_structure": self._analyze_project_structure(directory_path),
                "dependencies": self._extract_dependencies(directory_path),
                "patterns": self._identify_patterns(directory_path),
                "metrics": self._calculate_metrics(directory_path)
            }
            
            logger.info("Directory analysis completed", 
                       path=str(directory_path),
                       files_analyzed=len(analysis["file_analysis"]))
            
            return analysis
            
        except Exception as e:
            logger.error("Directory analysis failed", error=str(e), path=directory_path)
            return {"error": str(e)}
    
    def analyze_file(self, file_path: str) -> Dict[str, Any]:
        """
        Analizar archivo individual
        """
        try:
            file_path = Path(file_path)
            if not file_path.exists():
                raise ValueError(f"File does not exist: {file_path}")
            
            language = self._detect_language(file_path)
            content = self._read_file_safe(file_path)
            
            analysis = {
                "file_info": {
                    "path": str(file_path),
                    "name": file_path.name,
                    "extension": file_path.suffix,
                    "language": language,
                    "size": file_path.stat().st_size,
                    "lines": len(content.splitlines()) if content else 0
                },
                "content_analysis": self._analyze_content(content, language),
                "structure": self._analyze_file_structure(content, language),
                "complexity": self._calculate_complexity(content, language),
                "dependencies": self._extract_file_dependencies(content, language)
            }
            
            return analysis
            
        except Exception as e:
            logger.error("File analysis failed", error=str(e), path=file_path)
            return {"error": str(e)}
    
    def _get_directory_info(self, directory_path: Path) -> Dict[str, Any]:
        """Obtener información básica del directorio"""
        try:
            files = list(directory_path.rglob('*'))
            code_files = [f for f in files if f.is_file() and f.suffix in self.supported_languages]
            config_files = [f for f in files if f.name in self.config_files]
            
            return {
                "path": str(directory_path),
                "name": directory_path.name,
                "total_files": len([f for f in files if f.is_file()]),
                "total_directories": len([f for f in files if f.is_dir()]),
                "code_files": len(code_files),
                "config_files": len(config_files),
                "languages_detected": list(set(self.supported_languages[f.suffix] for f in code_files)),
                "project_types": list(set(self.config_files[f.name] for f in config_files))
            }
        except Exception as e:
            logger.error("Failed to get directory info", error=str(e))
            return {"error": str(e)}
    
    def _analyze_files(self, directory_path: Path) -> List[Dict[str, Any]]:
        """Analizar todos los archivos de código"""
        try:
            code_files = []
            for file_path in directory_path.rglob('*'):
                if file_path.is_file() and file_path.suffix in self.supported_languages:
                    # Limitar análisis a archivos no muy grandes
                    if file_path.stat().st_size < 1024 * 1024:  # 1MB limit
                        analysis = self.analyze_file(str(file_path))
                        if "error" not in analysis:
                            code_files.append(analysis)
            
            return code_files[:50]  # Limitar a 50 archivos para evitar sobrecarga
            
        except Exception as e:
            logger.error("Failed to analyze files", error=str(e))
            return []
    
    def _analyze_project_structure(self, directory_path: Path) -> Dict[str, Any]:
        """Analizar estructura del proyecto"""
        try:
            structure = {
                "root_files": [],
                "directories": {},
                "common_patterns": []
            }
            
            # Archivos en la raíz
            for item in directory_path.iterdir():
                if item.is_file():
                    structure["root_files"].append(item.name)
                elif item.is_dir() and not item.name.startswith('.'):
                    structure["directories"][item.name] = len(list(item.rglob('*')))
            
            # Patrones comunes
            if "src" in structure["directories"]:
                structure["common_patterns"].append("src_directory")
            if "test" in structure["directories"] or "tests" in structure["directories"]:
                structure["common_patterns"].append("test_directory")
            if "docs" in structure["directories"]:
                structure["common_patterns"].append("docs_directory")
            if "package.json" in structure["root_files"]:
                structure["common_patterns"].append("nodejs_project")
            if "pom.xml" in structure["root_files"]:
                structure["common_patterns"].append("java_maven_project")
            if "Dockerfile" in structure["root_files"]:
                structure["common_patterns"].append("containerized_project")
            
            return structure
            
        except Exception as e:
            logger.error("Failed to analyze project structure", error=str(e))
            return {"error": str(e)}
    
    def _extract_dependencies(self, directory_path: Path) -> Dict[str, Any]:
        """Extraer dependencias del proyecto"""
        dependencies = {
            "package_managers": [],
            "dependencies": {},
            "dev_dependencies": {},
            "external_apis": [],
            "databases": []
        }
        
        try:
            # package.json (Node.js)
            package_json = directory_path / "package.json"
            if package_json.exists():
                dependencies["package_managers"].append("npm")
                package_data = json.loads(self._read_file_safe(package_json))
                if "dependencies" in package_data:
                    dependencies["dependencies"].update(package_data["dependencies"])
                if "devDependencies" in package_data:
                    dependencies["dev_dependencies"].update(package_data["devDependencies"])
            
            # requirements.txt (Python)
            requirements_txt = directory_path / "requirements.txt"
            if requirements_txt.exists():
                dependencies["package_managers"].append("pip")
                content = self._read_file_safe(requirements_txt)
                for line in content.splitlines():
                    if line.strip() and not line.startswith('#'):
                        dep = line.split('==')[0].split('>=')[0].split('<=')[0].strip()
                        dependencies["dependencies"][dep] = line.strip()
            
            # pom.xml (Java Maven)
            pom_xml = directory_path / "pom.xml"
            if pom_xml.exists():
                dependencies["package_managers"].append("maven")
                # Análisis básico de XML (sin parser completo)
                content = self._read_file_safe(pom_xml)
                # Extraer dependencias básicas
                artifact_matches = re.findall(r'<artifactId>(.*?)</artifactId>', content)
                for artifact in artifact_matches:
                    dependencies["dependencies"][artifact] = "maven_dependency"
            
            # Detectar bases de datos y APIs externas
            dependencies["databases"] = self._detect_databases(directory_path)
            dependencies["external_apis"] = self._detect_external_apis(directory_path)
            
            return dependencies
            
        except Exception as e:
            logger.error("Failed to extract dependencies", error=str(e))
            return dependencies
    
    def _identify_patterns(self, directory_path: Path) -> Dict[str, Any]:
        """Identificar patrones arquitectónicos"""
        patterns = {
            "architectural_patterns": [],
            "design_patterns": [],
            "framework_patterns": [],
            "confidence_scores": {}
        }
        
        try:
            # Analizar estructura de directorios
            dirs = [d.name for d in directory_path.iterdir() if d.is_dir()]
            
            # Patrón MVC
            if any(d in dirs for d in ['models', 'views', 'controllers']):
                patterns["architectural_patterns"].append("MVC")
                patterns["confidence_scores"]["MVC"] = 0.8
            
            # Patrón Microservicios
            if any(d in dirs for d in ['services', 'microservices']) or len(dirs) > 10:
                patterns["architectural_patterns"].append("Microservices")
                patterns["confidence_scores"]["Microservices"] = 0.6
            
            # Patrón API-First
            if any(f.name in ['openapi.yaml', 'swagger.yaml', 'api.yaml'] 
                   for f in directory_path.rglob('*.yaml')):
                patterns["architectural_patterns"].append("API-First")
                patterns["confidence_scores"]["API-First"] = 0.7
            
            # Patrón Serverless
            if any(f.name in ['serverless.yml', 'template.yaml', 'sam.yaml'] 
                   for f in directory_path.rglob('*.y*ml')):
                patterns["architectural_patterns"].append("Serverless")
                patterns["confidence_scores"]["Serverless"] = 0.9
            
            # Framework patterns
            patterns["framework_patterns"] = self._detect_frameworks(directory_path)
            
            return patterns
            
        except Exception as e:
            logger.error("Failed to identify patterns", error=str(e))
            return patterns
    
    def _calculate_metrics(self, directory_path: Path) -> Dict[str, Any]:
        """Calcular métricas del código"""
        metrics = {
            "lines_of_code": 0,
            "files_count": 0,
            "complexity_score": 0,
            "maintainability_index": 0,
            "test_coverage_estimate": 0
        }
        
        try:
            code_files = [f for f in directory_path.rglob('*') 
                         if f.is_file() and f.suffix in self.supported_languages]
            
            total_lines = 0
            total_complexity = 0
            test_files = 0
            
            for file_path in code_files:
                if file_path.stat().st_size < 1024 * 1024:  # 1MB limit
                    content = self._read_file_safe(file_path)
                    lines = len(content.splitlines())
                    total_lines += lines
                    
                    # Complejidad básica
                    complexity = self._calculate_file_complexity(content)
                    total_complexity += complexity
                    
                    # Detectar archivos de test
                    if any(test_word in file_path.name.lower() 
                           for test_word in ['test', 'spec', '__test__']):
                        test_files += 1
            
            metrics["lines_of_code"] = total_lines
            metrics["files_count"] = len(code_files)
            metrics["complexity_score"] = total_complexity / max(len(code_files), 1)
            metrics["test_coverage_estimate"] = min((test_files / max(len(code_files), 1)) * 100, 100)
            
            # Índice de mantenibilidad simplificado
            if total_lines > 0:
                metrics["maintainability_index"] = max(0, 100 - (total_complexity / total_lines) * 100)
            
            return metrics
            
        except Exception as e:
            logger.error("Failed to calculate metrics", error=str(e))
            return metrics
    
    def _detect_language(self, file_path: Path) -> str:
        """Detectar lenguaje de programación"""
        return self.supported_languages.get(file_path.suffix, 'unknown')
    
    def _read_file_safe(self, file_path: Path) -> str:
        """Leer archivo de forma segura"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return f.read()
        except UnicodeDecodeError:
            try:
                with open(file_path, 'r', encoding='latin-1') as f:
                    return f.read()
            except Exception:
                return ""
        except Exception:
            return ""
    
    def _analyze_content(self, content: str, language: str) -> Dict[str, Any]:
        """Analizar contenido del archivo"""
        if not content:
            return {"error": "Empty content"}
        
        analysis = {
            "lines": len(content.splitlines()),
            "characters": len(content),
            "functions": self._count_functions(content, language),
            "classes": self._count_classes(content, language),
            "imports": self._extract_imports(content, language),
            "comments": self._count_comments(content, language)
        }
        
        return analysis
    
    def _analyze_file_structure(self, content: str, language: str) -> Dict[str, Any]:
        """Analizar estructura del archivo"""
        structure = {
            "has_main_function": False,
            "has_classes": False,
            "has_functions": False,
            "has_imports": False,
            "structure_type": "unknown"
        }
        
        if language == "python":
            structure["has_main_function"] = "if __name__ == '__main__':" in content
            structure["has_classes"] = "class " in content
            structure["has_functions"] = "def " in content
            structure["has_imports"] = any(line.strip().startswith(('import ', 'from ')) 
                                         for line in content.splitlines())
        elif language in ["javascript", "typescript"]:
            structure["has_functions"] = any(pattern in content 
                                           for pattern in ["function ", "=> ", "function("])
            structure["has_classes"] = "class " in content
            structure["has_imports"] = any(pattern in content 
                                         for pattern in ["import ", "require(", "from "])
        
        # Determinar tipo de estructura
        if structure["has_classes"] and structure["has_functions"]:
            structure["structure_type"] = "object_oriented"
        elif structure["has_functions"]:
            structure["structure_type"] = "functional"
        elif structure["has_imports"]:
            structure["structure_type"] = "module"
        
        return structure
    
    def _calculate_complexity(self, content: str, language: str) -> Dict[str, Any]:
        """Calcular complejidad del archivo"""
        return {
            "cyclomatic_complexity": self._calculate_file_complexity(content),
            "nesting_depth": self._calculate_nesting_depth(content),
            "complexity_rating": "low"  # Simplificado
        }
    
    def _extract_file_dependencies(self, content: str, language: str) -> List[str]:
        """Extraer dependencias del archivo"""
        dependencies = []
        
        if language == "python":
            for line in content.splitlines():
                line = line.strip()
                if line.startswith('import '):
                    dep = line.replace('import ', '').split('.')[0].split(' as ')[0]
                    dependencies.append(dep)
                elif line.startswith('from '):
                    dep = line.split(' ')[1].split('.')[0]
                    dependencies.append(dep)
        
        elif language in ["javascript", "typescript"]:
            # import statements
            import_matches = re.findall(r'import.*?from [\'"]([^\'"]+)[\'"]', content)
            dependencies.extend(import_matches)
            
            # require statements
            require_matches = re.findall(r'require\([\'"]([^\'"]+)[\'"]\)', content)
            dependencies.extend(require_matches)
        
        return list(set(dependencies))
    
    def _count_functions(self, content: str, language: str) -> int:
        """Contar funciones en el código"""
        if language == "python":
            return len(re.findall(r'^\s*def\s+\w+', content, re.MULTILINE))
        elif language in ["javascript", "typescript"]:
            return len(re.findall(r'function\s+\w+|=>\s*{|\w+\s*:\s*function', content))
        return 0
    
    def _count_classes(self, content: str, language: str) -> int:
        """Contar clases en el código"""
        if language == "python":
            return len(re.findall(r'^\s*class\s+\w+', content, re.MULTILINE))
        elif language in ["javascript", "typescript"]:
            return len(re.findall(r'class\s+\w+', content))
        return 0
    
    def _extract_imports(self, content: str, language: str) -> List[str]:
        """Extraer imports del código"""
        return self._extract_file_dependencies(content, language)
    
    def _count_comments(self, content: str, language: str) -> int:
        """Contar comentarios en el código"""
        if language == "python":
            return len(re.findall(r'#.*$', content, re.MULTILINE))
        elif language in ["javascript", "typescript"]:
            single_line = len(re.findall(r'//.*$', content, re.MULTILINE))
            multi_line = len(re.findall(r'/\*.*?\*/', content, re.DOTALL))
            return single_line + multi_line
        return 0
    
    def _calculate_file_complexity(self, content: str) -> int:
        """Calcular complejidad ciclomática básica"""
        # Contar estructuras de control
        control_structures = ['if', 'else', 'elif', 'for', 'while', 'try', 'except', 'case', 'switch']
        complexity = 1  # Base complexity
        
        for structure in control_structures:
            complexity += len(re.findall(rf'\b{structure}\b', content, re.IGNORECASE))
        
        return complexity
    
    def _calculate_nesting_depth(self, content: str) -> int:
        """Calcular profundidad de anidamiento"""
        max_depth = 0
        current_depth = 0
        
        for line in content.splitlines():
            stripped = line.strip()
            if any(keyword in stripped for keyword in ['if', 'for', 'while', 'try', 'def', 'class']):
                current_depth += 1
                max_depth = max(max_depth, current_depth)
            elif stripped in ['end', '}'] or (stripped.startswith('except') or stripped.startswith('finally')):
                current_depth = max(0, current_depth - 1)
        
        return max_depth
    
    def _detect_databases(self, directory_path: Path) -> List[str]:
        """Detectar bases de datos utilizadas"""
        databases = []
        
        # Buscar en archivos de configuración y código
        for file_path in directory_path.rglob('*'):
            if file_path.is_file():
                content = self._read_file_safe(file_path).lower()
                
                if any(db in content for db in ['postgresql', 'postgres', 'pg']):
                    databases.append('PostgreSQL')
                if any(db in content for db in ['mysql', 'mariadb']):
                    databases.append('MySQL')
                if any(db in content for db in ['mongodb', 'mongo']):
                    databases.append('MongoDB')
                if any(db in content for db in ['redis']):
                    databases.append('Redis')
                if any(db in content for db in ['sqlite']):
                    databases.append('SQLite')
        
        return list(set(databases))
    
    def _detect_external_apis(self, directory_path: Path) -> List[str]:
        """Detectar APIs externas utilizadas"""
        apis = []
        
        for file_path in directory_path.rglob('*'):
            if file_path.is_file() and file_path.suffix in ['.py', '.js', '.ts']:
                content = self._read_file_safe(file_path).lower()
                
                # APIs comunes
                if 'openai' in content:
                    apis.append('OpenAI API')
                if 'stripe' in content:
                    apis.append('Stripe API')
                if 'github' in content:
                    apis.append('GitHub API')
                if 'aws' in content:
                    apis.append('AWS Services')
                if 'google' in content and 'api' in content:
                    apis.append('Google APIs')
        
        return list(set(apis))
    
    def _detect_frameworks(self, directory_path: Path) -> List[str]:
        """Detectar frameworks utilizados"""
        frameworks = []
        
        # Verificar package.json
        package_json = directory_path / "package.json"
        if package_json.exists():
            content = self._read_file_safe(package_json).lower()
            if 'react' in content:
                frameworks.append('React')
            if 'angular' in content:
                frameworks.append('Angular')
            if 'vue' in content:
                frameworks.append('Vue.js')
            if 'express' in content:
                frameworks.append('Express.js')
            if 'next' in content:
                frameworks.append('Next.js')
        
        # Verificar requirements.txt
        requirements_txt = directory_path / "requirements.txt"
        if requirements_txt.exists():
            content = self._read_file_safe(requirements_txt).lower()
            if 'django' in content:
                frameworks.append('Django')
            if 'flask' in content:
                frameworks.append('Flask')
            if 'fastapi' in content:
                frameworks.append('FastAPI')
        
        return frameworks

# Instancia global del parser
code_parser = CodeParser()
