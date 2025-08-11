# Backstage Examples

This directory contains example configurations and components for the IA-Ops Platform Backstage instance.

## Contents

- `entities.yaml` - Example entity definitions
- `org.yaml` - Organization structure
- `test-component.yaml` - Test component with GitHub Actions integration
- `tech-radar-data.json` - Technology radar data
- `mkdocs.yml` - MkDocs configuration for TechDocs
- `docs/` - Documentation source files
- `template/` - Software template example

## TechDocs

The `docs/` directory contains documentation that is built using MkDocs and served through Backstage's TechDocs feature.

To build the documentation locally:

```bash
cd examples
mkdocs build
```

To serve the documentation locally:

```bash
cd examples
mkdocs serve
```

## Usage

These examples are automatically loaded by Backstage when the service starts. They provide:

1. Sample entities for testing catalog functionality
2. Organization structure for user management
3. Technology radar for tracking technology adoption
4. Documentation examples for TechDocs

## Customization

You can modify these files to match your organization's needs:

- Update `org.yaml` with your team structure
- Modify `entities.yaml` with your actual services and components
- Customize `tech-radar-data.json` with your technology stack
- Add more documentation in the `docs/` directory
