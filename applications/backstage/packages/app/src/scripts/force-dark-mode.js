// =============================================================================
// SCRIPT PARA FORZAR ESTILOS DE MODO OSCURO
// =============================================================================
// Este script se ejecuta para sobrescribir estilos inline problemáticos
// =============================================================================

(function() {
  'use strict';

  // Función para aplicar estilos de modo oscuro a elementos pre
  function applyDarkModeStyles() {
    // Detectar si estamos en modo oscuro
    const isDarkMode = 
      document.documentElement.getAttribute('data-theme') === 'dark' ||
      document.body.getAttribute('data-theme') === 'dark' ||
      document.documentElement.classList.contains('bp3-dark') ||
      document.body.classList.contains('bp3-dark') ||
      window.matchMedia('(prefers-color-scheme: dark)').matches;

    if (isDarkMode) {
      // Buscar todos los elementos pre con fondo claro
      const preElements = document.querySelectorAll('pre, .MuiBox-root');
      
      preElements.forEach(element => {
        const computedStyle = window.getComputedStyle(element);
        const bgColor = computedStyle.backgroundColor;
        
        // Si el fondo es claro (rgb(245, 245, 245) o similar)
        if (bgColor === 'rgb(245, 245, 245)' || 
            bgColor === 'rgb(255, 255, 255)' ||
            element.style.backgroundColor === 'rgb(245, 245, 245)') {
          
          // Aplicar estilos de modo oscuro
          element.style.setProperty('background-color', '#2d2d2d', 'important');
          element.style.setProperty('color', '#e0e0e0', 'important');
          element.style.setProperty('border', '1px solid #404040', 'important');
          
          // Si contiene feature flags, usar colores especiales
          if (element.textContent && element.textContent.includes('featureFlags')) {
            element.style.setProperty('background-color', '#1a1a1a', 'important');
            element.style.setProperty('color', '#00ff00', 'important');
            element.style.setProperty('border', '1px solid #333333', 'important');
          }
        }
      });

      // Aplicar estilos a elementos code
      const codeElements = document.querySelectorAll('code');
      codeElements.forEach(element => {
        const computedStyle = window.getComputedStyle(element);
        const bgColor = computedStyle.backgroundColor;
        
        if (bgColor === 'rgb(245, 245, 245)' || 
            bgColor === 'rgb(255, 255, 255)' ||
            bgColor === 'rgba(0, 0, 0, 0)') {
          
          element.style.setProperty('background-color', '#3a3a3a', 'important');
          element.style.setProperty('color', '#f5f5f5', 'important');
        }
      });
    }
  }

  // Función para observar cambios en el DOM
  function observeChanges() {
    const observer = new MutationObserver(function(mutations) {
      let shouldApplyStyles = false;
      
      mutations.forEach(function(mutation) {
        if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
          // Verificar si se agregaron elementos pre o code
          mutation.addedNodes.forEach(function(node) {
            if (node.nodeType === Node.ELEMENT_NODE) {
              if (node.tagName === 'PRE' || 
                  node.tagName === 'CODE' || 
                  node.classList.contains('MuiBox-root') ||
                  node.querySelector('pre, code')) {
                shouldApplyStyles = true;
              }
            }
          });
        }
        
        // Verificar cambios de atributos (como data-theme)
        if (mutation.type === 'attributes' && 
            (mutation.attributeName === 'data-theme' || 
             mutation.attributeName === 'class')) {
          shouldApplyStyles = true;
        }
      });
      
      if (shouldApplyStyles) {
        setTimeout(applyDarkModeStyles, 100);
      }
    });

    observer.observe(document.documentElement, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ['data-theme', 'class']
    });
  }

  // Función para detectar cambios en el tema del sistema
  function observeSystemTheme() {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    mediaQuery.addListener(function() {
      setTimeout(applyDarkModeStyles, 100);
    });
  }

  // Inicializar cuando el DOM esté listo
  function initialize() {
    applyDarkModeStyles();
    observeChanges();
    observeSystemTheme();
    
    // Aplicar estilos periódicamente como fallback
    setInterval(applyDarkModeStyles, 2000);
  }

  // Ejecutar cuando el DOM esté listo
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initialize);
  } else {
    initialize();
  }

  // También ejecutar cuando la página esté completamente cargada
  window.addEventListener('load', function() {
    setTimeout(applyDarkModeStyles, 500);
  });

  // Exponer función globalmente para debugging
  window.forceDarkModeStyles = applyDarkModeStyles;

})();
