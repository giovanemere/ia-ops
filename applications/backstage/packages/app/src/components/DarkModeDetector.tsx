import React, { useEffect } from 'react';
import { useTheme } from '@material-ui/core/styles';

export const DarkModeDetector: React.FC = () => {
  const theme = useTheme();

  useEffect(() => {
    const applyDarkModeStyles = () => {
      const isDarkMode = theme.palette.type === 'dark';
      
      if (isDarkMode) {
        // Agregar clase al body para identificar modo oscuro
        document.body.classList.add('dark-theme');
        document.documentElement.setAttribute('data-theme', 'dark');
        
        // Buscar y corregir elementos pre con fondo claro
        const preElements = document.querySelectorAll('pre[style*="background-color: rgb(245, 245, 245)"], .MuiBox-root[style*="background-color: rgb(245, 245, 245)"]');
        
        preElements.forEach((element: Element) => {
          const htmlElement = element as HTMLElement;
          htmlElement.style.setProperty('background-color', '#2d2d2d', 'important');
          htmlElement.style.setProperty('color', '#e0e0e0', 'important');
          htmlElement.style.setProperty('border', '1px solid #404040', 'important');
          
          // Si contiene feature flags, usar colores especiales
          if (htmlElement.textContent && htmlElement.textContent.includes('featureFlags')) {
            htmlElement.style.setProperty('background-color', '#1a1a1a', 'important');
            htmlElement.style.setProperty('color', '#00ff00', 'important');
            htmlElement.style.setProperty('border', '1px solid #333333', 'important');
          }
        });
        
        // Aplicar estilos a todos los elementos pre y MuiBox-root
        const allPreElements = document.querySelectorAll('pre, .MuiBox-root-1818, .MuiBox-root-2054');
        allPreElements.forEach((element: Element) => {
          const htmlElement = element as HTMLElement;
          const computedStyle = window.getComputedStyle(htmlElement);
          
          if (computedStyle.backgroundColor === 'rgb(245, 245, 245)' || 
              htmlElement.style.backgroundColor === 'rgb(245, 245, 245)') {
            htmlElement.style.setProperty('background-color', '#2d2d2d', 'important');
            htmlElement.style.setProperty('color', '#e0e0e0', 'important');
            htmlElement.style.setProperty('border', '1px solid #404040', 'important');
          }
        });
      } else {
        document.body.classList.remove('dark-theme');
        document.documentElement.setAttribute('data-theme', 'light');
      }
    };

    // Aplicar estilos inmediatamente
    applyDarkModeStyles();

    // Crear un observer para detectar cambios en el DOM
    const observer = new MutationObserver((mutations) => {
      let shouldApplyStyles = false;
      
      mutations.forEach((mutation) => {
        if (mutation.type === 'childList') {
          mutation.addedNodes.forEach((node) => {
            if (node.nodeType === Node.ELEMENT_NODE) {
              const element = node as Element;
              if (element.tagName === 'PRE' || 
                  element.classList.contains('MuiBox-root') ||
                  element.querySelector('pre')) {
                shouldApplyStyles = true;
              }
            }
          });
        }
      });
      
      if (shouldApplyStyles) {
        setTimeout(applyDarkModeStyles, 100);
      }
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });

    // Aplicar estilos periódicamente como fallback
    const interval = setInterval(applyDarkModeStyles, 1000);

    return () => {
      observer.disconnect();
      clearInterval(interval);
    };
  }, [theme.palette.type]);

  return null; // Este componente no renderiza nada
};

export default DarkModeDetector;
