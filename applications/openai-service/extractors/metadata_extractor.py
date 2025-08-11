"""
Extractor de metadatos de proyectos
Extrae información de package.json, pom.xml, requirements.txt, etc.
"""

import json
import xml.etree.ElementTree as ET
import yaml
import re
from typing import Dict, List, Any, Optional
from pathlib import Path
import structlog

logger = structlog.get_logger(__name__)

class MetadataExtractor:
    """Extractor de metadatos de archivos de configuración"""
    
    def __init__(self):
        self.extractors = {
            'package.json': self._extract_package_json,
            'pom.xml': self._extract_pom_xml,
            'build.gradle': self._extract_gradle,
            'requirements.txt': self._extract_requirements_txt,
            'pyproject.toml': self._extract_pyproject_toml,
            'Cargo.toml': self._extract_cargo_toml,
            'go.mod': self._extract_go_mod,
            'composer.json': self._extract_composer_json,
            'Gemfile': self._extract_gemfile,
            'Dockerfile': self._extract_dockerfile,
            'docker-compose.yml': self._extract_docker_compose,
            'docker-compose.yaml': self._extract_docker_compose,
            '.env': self._extract_env_file,
            'README.md': self._extract_readme,
            'README.rst': self._extract_readme
        }
    
    def extract_project_metadata(self, directory_path: str) -> Dict[str, Any]:
        """
        Extraer metadatos completos del proyecto
        """
        try:
            directory_path = Path(directory_path)
            metadata = {
                "project_info": {},
                "dependencies": {},
                "dev_dependencies": {},
                "scripts": {},
                "configuration": {},
                "deployment": {},
                "documentation": {},
                "detected_files": []
            }
            
            # Buscar archivos de configuración
            for file_pattern, extractor in self.extractors.items():
                matching_files = list(directory_path.rglob(file_pattern))
                for file_path in matching_files:
                    try:
                        file_metadata = extractor(file_path)
                        if file_metadata:
                            metadata["detected_files"].append(str(file_path))
                            self._merge_metadata(metadata, file_metadata)
                    except Exception as e:
                        logger.warning("Failed to extract metadata", 
                                     file=str(file_path), error=str(e))
            
            # Análisis adicional
            metadata["project_summary"] = self._generate_project_summary(metadata)
            metadata["technology_stack"] = self._identify_technology_stack(metadata)
            metadata["project_type"] = self._classify_project_type(metadata)
            
            logger.info("Project metadata extracted", 
                       files_processed=len(metadata["detected_files"]))
            
            return metadata
            
        except Exception as e:
            logger.error("Failed to extract project metadata", error=str(e))
            return {"error": str(e)}
    
    def _extract_package_json(self, file_path: Path) -> Dict[str, Any]:
        """Extraer metadatos de package.json"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            metadata = {
                "project_info": {
                    "name": data.get("name", ""),
                    "version": data.get("version", ""),
                    "description": data.get("description", ""),
                    "author": data.get("author", ""),
                    "license": data.get("license", ""),
                    "homepage": data.get("homepage", ""),
                    "repository": data.get("repository", {}),
                    "keywords": data.get("keywords", [])
                },
                "dependencies": data.get("dependencies", {}),
                "dev_dependencies": data.get("devDependencies", {}),
                "scripts": data.get("scripts", {}),
                "configuration": {
                    "engines": data.get("engines", {}),
                    "main": data.get("main", ""),
                    "type": data.get("type", "commonjs")
                }
            }
            
            return metadata
            
        except Exception as e:
            logger.error("Failed to extract package.json", error=str(e))
            return {}
    
    def _extract_pom_xml(self, file_path: Path) -> Dict[str, Any]:
        """Extraer metadatos de pom.xml"""
        try:
            tree = ET.parse(file_path)
            root = tree.getroot()
            
            # Namespace handling
            ns = {'maven': 'http://maven.apache.org/POM/4.0.0'}
            if root.tag.startswith('{'):
                ns_uri = root.tag.split('}')[0][1:]
                ns = {'maven': ns_uri}
            
            metadata = {
                "project_info": {
                    "name": self._get_xml_text(root, './/maven:name', ns),
                    "version": self._get_xml_text(root, './/maven:version', ns),
                    "description": self._get_xml_text(root, './/maven:description', ns),
                    "groupId": self._get_xml_text(root, './/maven:groupId', ns),
                    "artifactId": self._get_xml_text(root, './/maven:artifactId', ns)
                },
                "dependencies": {},
                "configuration": {
                    "java_version": self._get_xml_text(root, './/maven:maven.compiler.source', ns),
                    "packaging": self._get_xml_text(root, './/maven:packaging', ns)
                }
            }
            
            # Extraer dependencias
            dependencies = root.findall('.//maven:dependency', ns)
            for dep in dependencies:
                group_id = self._get_xml_text(dep, './maven:groupId', ns)
                artifact_id = self._get_xml_text(dep, './maven:artifactId', ns)
                version = self._get_xml_text(dep, './maven:version', ns)
                if group_id and artifact_id:
                    metadata["dependencies"][f"{group_id}:{artifact_id}"] = version
            
            return metadata
            
        except Exception as e:
            logger.error("Failed to extract pom.xml", error=str(e))
            return {}
    
    def _extract_requirements_txt(self, file_path: Path) -> Dict[str, Any]:
        """Extraer metadatos de requirements.txt"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            dependencies = {}
            for line in content.splitlines():
                line = line.strip()
                if line and not line.startswith('#'):
                    # Parse requirement line
                    if '==' in line:
                        name, version = line.split('==', 1)
                        dependencies[name.strip()] = version.strip()
                    elif '>=' in line:
                        name, version = line.split('>=', 1)
                        dependencies[name.strip()] = f">={version.strip()}"
                    else:
                        dependencies[line] = "latest"
            
            return {
                "dependencies": dependencies,
                "project_info": {
                    "package_manager": "pip"
                }
            }
            
        except Exception as e:
            logger.error("Failed to extract requirements.txt", error=str(e))
            return {}
    
    def _extract_dockerfile(self, file_path: Path) -> Dict[str, Any]:
        """Extraer metadatos de Dockerfile"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            metadata = {
                "deployment": {
                    "containerized": True,
                    "base_images": [],
                    "exposed_ports": [],
                    "environment_vars": [],
                    "volumes": []
                }
            }
            
            for line in content.splitlines():
                line = line.strip()
                if line.startswith('FROM '):
                    base_image = line.replace('FROM ', '').split(' as ')[0]
                    metadata["deployment"]["base_images"].append(base_image)
                elif line.startswith('EXPOSE '):
                    port = line.replace('EXPOSE ', '')
                    metadata["deployment"]["exposed_ports"].append(port)
                elif line.startswith('ENV '):
                    env_var = line.replace('ENV ', '')
                    metadata["deployment"]["environment_vars"].append(env_var)
                elif line.startswith('VOLUME '):
                    volume = line.replace('VOLUME ', '')
                    metadata["deployment"]["volumes"].append(volume)
            
            return metadata
            
        except Exception as e:
            logger.error("Failed to extract Dockerfile", error=str(e))
            return {}
    
    def _extract_docker_compose(self, file_path: Path) -> Dict[str, Any]:
        """Extraer metadatos de docker-compose.yml"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
            
            metadata = {
                "deployment": {
                    "orchestrated": True,
                    "services": [],
                    "networks": list(data.get("networks", {}).keys()),
                    "volumes": list(data.get("volumes", {}).keys())
                }
            }
            
            services = data.get("services", {})
            for service_name, service_config in services.items():
                service_info = {
                    "name": service_name,
                    "image": service_config.get("image", ""),
                    "ports": service_config.get("ports", []),
                    "environment": service_config.get("environment", {}),
                    "depends_on": service_config.get("depends_on", [])
                }
                metadata["deployment"]["services"].append(service_info)
            
            return metadata
            
        except Exception as e:
            logger.error("Failed to extract docker-compose", error=str(e))
            return {}
    
    def _extract_readme(self, file_path: Path) -> Dict[str, Any]:
        """Extraer metadatos de README"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            metadata = {
                "documentation": {
                    "has_readme": True,
                    "readme_length": len(content),
                    "sections": self._extract_readme_sections(content),
                    "badges": self._extract_badges(content),
                    "links": self._extract_links(content)
                }
            }
            
            # Extraer título del proyecto
            lines = content.splitlines()
            for line in lines:
                if line.startswith('# '):
                    metadata["project_info"] = {
                        "title": line.replace('# ', '').strip()
                    }
                    break
            
            return metadata
            
        except Exception as e:
            logger.error("Failed to extract README", error=str(e))
            return {}
    
    def _extract_env_file(self, file_path: Path) -> Dict[str, Any]:
        """Extraer metadatos de archivo .env"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            env_vars = {}
            for line in content.splitlines():
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    # No almacenar valores sensibles
                    if any(sensitive in key.upper() for sensitive in ['PASSWORD', 'SECRET', 'KEY', 'TOKEN']):
                        env_vars[key] = "[REDACTED]"
                    else:
                        env_vars[key] = value
            
            return {
                "configuration": {
                    "environment_variables": env_vars,
                    "has_env_file": True
                }
            }
            
        except Exception as e:
            logger.error("Failed to extract .env file", error=str(e))
            return {}
    
    def _extract_gradle(self, file_path: Path) -> Dict[str, Any]:
        """Extraer metadatos básicos de build.gradle"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            metadata = {
                "project_info": {
                    "build_tool": "gradle"
                },
                "dependencies": {},
                "configuration": {}
            }
            
            # Extraer dependencias básicas (análisis simple)
            dependencies_section = False
            for line in content.splitlines():
                line = line.strip()
                if 'dependencies {' in line:
                    dependencies_section = True
                elif dependencies_section and '}' in line:
                    dependencies_section = False
                elif dependencies_section and any(dep_type in line for dep_type in ['implementation', 'compile', 'api']):
                    # Extraer nombre de dependencia
                    match = re.search(r"['\"]([^'\"]+)['\"]", line)
                    if match:
                        dep_name = match.group(1)
                        metadata["dependencies"][dep_name] = "gradle_dependency"
            
            return metadata
            
        except Exception as e:
            logger.error("Failed to extract build.gradle", error=str(e))
            return {}
    
    def _extract_cargo_toml(self, file_path: Path) -> Dict[str, Any]:
        """Extraer metadatos de Cargo.toml (Rust)"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Análisis básico sin parser TOML completo
            metadata = {
                "project_info": {
                    "language": "rust",
                    "package_manager": "cargo"
                },
                "dependencies": {}
            }
            
            # Extraer información básica
            for line in content.splitlines():
                line = line.strip()
                if line.startswith('name = '):
                    metadata["project_info"]["name"] = line.split('=')[1].strip().strip('"')
                elif line.startswith('version = '):
                    metadata["project_info"]["version"] = line.split('=')[1].strip().strip('"')
            
            return metadata
            
        except Exception as e:
            logger.error("Failed to extract Cargo.toml", error=str(e))
            return {}
    
    def _extract_go_mod(self, file_path: Path) -> Dict[str, Any]:
        """Extraer metadatos de go.mod"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            metadata = {
                "project_info": {
                    "language": "go",
                    "package_manager": "go_modules"
                },
                "dependencies": {}
            }
            
            for line in content.splitlines():
                line = line.strip()
                if line.startswith('module '):
                    metadata["project_info"]["module"] = line.replace('module ', '')
                elif line.startswith('go '):
                    metadata["project_info"]["go_version"] = line.replace('go ', '')
                elif line and not line.startswith('//') and ' v' in line:
                    parts = line.split()
                    if len(parts) >= 2:
                        metadata["dependencies"][parts[0]] = parts[1]
            
            return metadata
            
        except Exception as e:
            logger.error("Failed to extract go.mod", error=str(e))
            return {}
    
    def _extract_composer_json(self, file_path: Path) -> Dict[str, Any]:
        """Extraer metadatos de composer.json (PHP)"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            return {
                "project_info": {
                    "name": data.get("name", ""),
                    "description": data.get("description", ""),
                    "version": data.get("version", ""),
                    "language": "php",
                    "package_manager": "composer"
                },
                "dependencies": data.get("require", {}),
                "dev_dependencies": data.get("require-dev", {})
            }
            
        except Exception as e:
            logger.error("Failed to extract composer.json", error=str(e))
            return {}
    
    def _extract_gemfile(self, file_path: Path) -> Dict[str, Any]:
        """Extraer metadatos de Gemfile (Ruby)"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            metadata = {
                "project_info": {
                    "language": "ruby",
                    "package_manager": "bundler"
                },
                "dependencies": {}
            }
            
            for line in content.splitlines():
                line = line.strip()
                if line.startswith("gem '") or line.startswith('gem "'):
                    match = re.search(r"gem ['\"]([^'\"]+)['\"]", line)
                    if match:
                        gem_name = match.group(1)
                        version_match = re.search(r"['\"]([^'\"]+)['\"].*['\"]([^'\"]+)['\"]", line)
                        if version_match and len(version_match.groups()) > 1:
                            metadata["dependencies"][gem_name] = version_match.group(2)
                        else:
                            metadata["dependencies"][gem_name] = "latest"
            
            return metadata
            
        except Exception as e:
            logger.error("Failed to extract Gemfile", error=str(e))
            return {}
    
    def _extract_pyproject_toml(self, file_path: Path) -> Dict[str, Any]:
        """Extraer metadatos básicos de pyproject.toml"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            metadata = {
                "project_info": {
                    "language": "python",
                    "package_manager": "pip"
                },
                "dependencies": {}
            }
            
            # Análisis básico sin parser TOML
            in_dependencies = False
            for line in content.splitlines():
                line = line.strip()
                if '[tool.poetry.dependencies]' in line or '[project.dependencies]' in line:
                    in_dependencies = True
                elif line.startswith('[') and in_dependencies:
                    in_dependencies = False
                elif in_dependencies and '=' in line:
                    parts = line.split('=', 1)
                    if len(parts) == 2:
                        dep_name = parts[0].strip()
                        dep_version = parts[1].strip().strip('"\'')
                        metadata["dependencies"][dep_name] = dep_version
            
            return metadata
            
        except Exception as e:
            logger.error("Failed to extract pyproject.toml", error=str(e))
            return {}
    
    def _get_xml_text(self, element, xpath: str, namespaces: Dict[str, str]) -> str:
        """Obtener texto de elemento XML"""
        try:
            found = element.find(xpath, namespaces)
            return found.text if found is not None else ""
        except:
            return ""
    
    def _extract_readme_sections(self, content: str) -> List[str]:
        """Extraer secciones del README"""
        sections = []
        for line in content.splitlines():
            if line.startswith('#'):
                section = line.lstrip('#').strip()
                if section:
                    sections.append(section)
        return sections
    
    def _extract_badges(self, content: str) -> List[str]:
        """Extraer badges del README"""
        badge_pattern = r'!\[([^\]]*)\]\([^)]+\)'
        return re.findall(badge_pattern, content)
    
    def _extract_links(self, content: str) -> List[str]:
        """Extraer links del README"""
        link_pattern = r'\[([^\]]+)\]\(([^)]+)\)'
        matches = re.findall(link_pattern, content)
        return [match[1] for match in matches if match[1].startswith('http')]
    
    def _merge_metadata(self, target: Dict[str, Any], source: Dict[str, Any]):
        """Fusionar metadatos de diferentes fuentes"""
        for key, value in source.items():
            if key in target:
                if isinstance(target[key], dict) and isinstance(value, dict):
                    target[key].update(value)
                elif isinstance(target[key], list) and isinstance(value, list):
                    target[key].extend(value)
                else:
                    target[key] = value
            else:
                target[key] = value
    
    def _generate_project_summary(self, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Generar resumen del proyecto"""
        return {
            "total_dependencies": len(metadata.get("dependencies", {})),
            "has_documentation": bool(metadata.get("documentation", {})),
            "is_containerized": metadata.get("deployment", {}).get("containerized", False),
            "is_orchestrated": metadata.get("deployment", {}).get("orchestrated", False),
            "configuration_files": len(metadata.get("detected_files", []))
        }
    
    def _identify_technology_stack(self, metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Identificar stack tecnológico"""
        stack = {
            "languages": [],
            "frameworks": [],
            "databases": [],
            "tools": []
        }
        
        # Identificar lenguajes
        project_info = metadata.get("project_info", {})
        if "language" in project_info:
            stack["languages"].append(project_info["language"])
        
        # Identificar frameworks por dependencias
        dependencies = metadata.get("dependencies", {})
        for dep_name in dependencies.keys():
            dep_lower = dep_name.lower()
            if any(fw in dep_lower for fw in ['react', 'angular', 'vue']):
                stack["frameworks"].append(dep_name)
            elif any(fw in dep_lower for fw in ['express', 'fastapi', 'django', 'flask']):
                stack["frameworks"].append(dep_name)
        
        return stack
    
    def _classify_project_type(self, metadata: Dict[str, Any]) -> str:
        """Clasificar tipo de proyecto"""
        dependencies = metadata.get("dependencies", {})
        deployment = metadata.get("deployment", {})
        
        # Web application
        if any(fw in str(dependencies).lower() for fw in ['react', 'angular', 'vue', 'express']):
            return "web_application"
        
        # API service
        if any(fw in str(dependencies).lower() for fw in ['fastapi', 'flask', 'express']):
            return "api_service"
        
        # Microservice
        if deployment.get("containerized") and len(deployment.get("services", [])) > 1:
            return "microservice"
        
        # Library
        if not deployment.get("containerized") and len(dependencies) > 0:
            return "library"
        
        return "application"

# Instancia global del extractor
metadata_extractor = MetadataExtractor()
