// Configuración de variables de entorno para el AI Chat
// Estas constantes son sincronizadas automáticamente desde /home/giovanemere/ia-ops/ia-ops/.env
// Actualizado el: Sun Aug 10 23:06:04 -05 2025

// Variables de OpenAI desde el archivo .env principal
export const OPENAI_CONFIG = {
  API_KEY: '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',
  MODEL: 'gpt-4o-mini',
  MAX_TOKENS: 150,
  TEMPERATURE: 0.7,
} as const;

// Función helper para verificar si estamos en desarrollo
export const isDevelopment = () => {
  try {
    return typeof window !== 'undefined' && window.location.hostname === 'localhost';
  } catch {
    return false;
  }
};

// Configuración por defecto
export const DEFAULT_CONFIG = {
  apiKey: OPENAI_CONFIG.API_KEY,
  model: OPENAI_CONFIG.MODEL,
  maxTokens: OPENAI_CONFIG.MAX_TOKENS,
  temperature: OPENAI_CONFIG.TEMPERATURE,
} as const;
