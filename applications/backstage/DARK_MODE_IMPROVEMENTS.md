# 🌙 Mejoras de Modo Oscuro para Backstage

## Descripción
Este documento describe las mejoras implementadas para mejorar la experiencia visual en modo oscuro de Backstage, especialmente para elementos como `<pre>`, `<code>` y el componente de AI Chat.

## Problema Original
- Los elementos `<pre>` tenían fondo gris claro (`rgb(245, 245, 245)`) que no se veía bien en modo oscuro
- Falta de contraste en varios componentes UI
- Scrollbars y inputs no optimizados para modo oscuro
- Texto poco legible en ciertos elementos

## Solución Implementada

### 1. Feature Flags
```yaml
featureFlags:
  enable-dark-mode-enhancements: true
```

### 2. Estilos CSS Personalizados (`packages/app/src/styles/dark-mode.css`)

#### Elementos de Código
- **`<pre>`**: Fondo `#2d2d2d`, texto `#e0e0e0`, borde `#404040`
- **`<code>`**: Fondo `#3a3a3a`, texto `#f5f5f5`
- **Feature flags display**: Fondo `#1a1a1a`, texto verde `#00ff00`

#### Componentes UI
- **Chat container**: Fondo `#1e1e1e` con bordes `#404040`
- **Mensajes AI**: Fondo `#2d2d2d` con mejor contraste
- **Inputs**: Fondo `#2d2d2d` con bordes optimizados
- **Scrollbars**: Colores `#2d2d2d` (track) y `#555555` (thumb)

#### Syntax Highlighting
- **Keywords**: `#569cd6`
- **Strings**: `#ce9178`
- **Numbers**: `#b5cea8`
- **Comments**: `#6a9955`

### 3. Mejoras en Componentes React

#### AiChatPage.tsx
- Estilos condicionales basados en `theme.palette.type`
- Mejor contraste para mensajes y contenedores
- Estilos específicos para elementos `<pre>` y `<code>` dentro de mensajes

### 4. Variables de Entorno
```bash
ENABLE_DARK_MODE_ENHANCEMENTS=true
THEME_MODE=auto
```

## Archivos Modificados

1. **`app-config.yaml`**
   - Habilitado `enable-dark-mode-enhancements: true`

2. **`packages/app/src/styles/dark-mode.css`** (nuevo)
   - Estilos CSS personalizados para modo oscuro

3. **`packages/app/src/index.tsx`**
   - Importación de estilos personalizados

4. **`packages/app/src/components/AiChat/AiChatPage.tsx`**
   - Mejoras en estilos condicionales para modo oscuro

5. **`.env`**
   - Variables de configuración para modo oscuro

## Cómo Usar

### Aplicar Mejoras
```bash
cd /path/to/backstage
./apply-dark-mode-improvements.sh
```

### Verificar Cambios
1. Ejecutar `yarn start`
2. Cambiar a modo oscuro en configuración de usuario
3. Visitar página de AI Chat
4. Verificar elementos `<pre>` y `<code>`

## Elementos Mejorados

### ✅ Elementos de Código
- [x] Elementos `<pre>` con fondo oscuro y texto claro
- [x] Elementos `<code>` inline con mejor contraste
- [x] Syntax highlighting optimizado

### ✅ Componentes UI
- [x] Chat container con fondo oscuro
- [x] Mensajes AI con mejor contraste
- [x] Inputs y campos de texto optimizados
- [x] Scrollbars con colores apropiados

### ✅ Elementos Interactivos
- [x] Botones con colores apropiados
- [x] Chips y badges optimizados
- [x] Alerts y notificaciones mejoradas
- [x] Tablas con mejor legibilidad

## Colores Utilizados

### Fondos
- **Principal**: `#1e1e1e`
- **Secundario**: `#2d2d2d`
- **Código**: `#1a1a1a`
- **Inputs**: `#2d2d2d`

### Texto
- **Principal**: `#e0e0e0`
- **Secundario**: `#b0b0b0`
- **Código**: `#00ff00` (para feature flags)
- **Código general**: `#f5f5f5`

### Bordes
- **Principal**: `#404040`
- **Código**: `#333333`

## Testing

### Verificación Manual
1. ✅ Cambiar a modo oscuro
2. ✅ Verificar elementos `<pre>` en AI Chat
3. ✅ Verificar contraste de texto
4. ✅ Verificar scrollbars
5. ✅ Verificar inputs y botones

### Verificación Automática
```bash
yarn tsc --noEmit  # Verificar TypeScript
yarn lint          # Verificar linting
```

## Troubleshooting

### Problema: Estilos no se aplican
**Solución**: Verificar que `dark-mode.css` esté importado en `index.tsx`

### Problema: Feature flag no funciona
**Solución**: Verificar `app-config.yaml` y reiniciar aplicación

### Problema: Elementos siguen con fondo claro
**Solución**: Verificar que el selector CSS `[data-theme="dark"]` esté funcionando

## Próximas Mejoras

- [ ] Modo automático basado en preferencias del sistema
- [ ] Más opciones de personalización de colores
- [ ] Mejoras en componentes de terceros
- [ ] Transiciones suaves entre modos

## Contribuir

Para contribuir con mejoras adicionales:

1. Editar `packages/app/src/styles/dark-mode.css`
2. Probar en modo oscuro
3. Verificar contraste y legibilidad
4. Documentar cambios en este archivo

---

**Fecha de última actualización**: $(date)
**Versión**: 1.0.0
**Autor**: IA-OPS Team
