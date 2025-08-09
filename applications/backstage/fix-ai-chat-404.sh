#!/bin/bash

echo "🤖 SOLUCIONANDO ERROR 404: AI-CHAT"
echo "=================================="

echo ""
echo "❌ ERROR DETECTADO:"
echo "=================="
echo "URL: http://localhost:3002/ai-chat"
echo "Error: 404 - PAGE NOT FOUND"
echo "Causa: La ruta /ai-chat no está configurada en Backstage"

echo ""
echo "🔍 VERIFICANDO RUTAS CONFIGURADAS:"
echo "================================="

# Verificar App.tsx para ver las rutas configuradas
if [ -f "packages/app/src/App.tsx" ]; then
    echo "📄 Rutas encontradas en App.tsx:"
    echo "--------------------------------"
    
    # Buscar rutas definidas
    grep -n "path=" packages/app/src/App.tsx | head -10
    
    echo ""
    echo "📋 Componentes de página configurados:"
    grep -n "Page" packages/app/src/App.tsx | grep -E "(import|const)" | head -10
    
else
    echo "❌ No se encontró packages/app/src/App.tsx"
fi

echo ""
echo "🔍 VERIFICANDO PLUGINS INSTALADOS:"
echo "================================="

# Verificar package.json del frontend para plugins relacionados con AI
if [ -f "packages/app/package.json" ]; then
    echo "🔌 Plugins relacionados con AI/Chat:"
    grep -i -E "(ai|chat|openai|llm)" packages/app/package.json || echo "❌ No se encontraron plugins de AI/Chat"
else
    echo "❌ No se encontró packages/app/package.json"
fi

echo ""
echo "💡 SOLUCIONES DISPONIBLES:"
echo "========================="

echo ""
echo "SOLUCIÓN 1: Verificar si AI Chat debería existir"
echo "==============================================="
echo "• ¿Esperabas que hubiera una funcionalidad de AI Chat?"
echo "• ¿Es parte de un plugin específico que instalaste?"
echo "• ¿O es una URL que viste en documentación?"

echo ""
echo "SOLUCIÓN 2: Rutas disponibles en Backstage por defecto"
echo "====================================================="
echo "Rutas que SÍ deberían funcionar:"
echo "• http://localhost:3002/ - Home"
echo "• http://localhost:3002/catalog - Software Catalog"
echo "• http://localhost:3002/create - Scaffolder Templates"
echo "• http://localhost:3002/search - Search"
echo "• http://localhost:3002/tech-radar - Tech Radar"
echo "• http://localhost:3002/docs - TechDocs"

echo ""
echo "SOLUCIÓN 3: Instalar plugin de AI Chat (si es necesario)"
echo "======================================================="
echo "Si necesitas funcionalidad de AI Chat, puedes:"
echo ""
echo "A) Instalar un plugin existente:"
echo "   • @backstage/plugin-ai-chat (si existe)"
echo "   • Plugins de terceros para AI"
echo ""
echo "B) Crear una página personalizada:"
echo "   • Agregar ruta en App.tsx"
echo "   • Crear componente de chat"
echo "   • Integrar con API de AI (OpenAI, etc.)"

echo ""
echo "🔧 CREAR PÁGINA DE AI CHAT PERSONALIZADA:"
echo "========================================"

read -p "¿Quieres crear una página básica de AI Chat? (y/n): " create_ai_chat

if [ "$create_ai_chat" = "y" ] || [ "$create_ai_chat" = "Y" ]; then
    echo ""
    echo "🛠️  CREANDO PÁGINA DE AI CHAT:"
    echo "============================="
    
    # Crear directorio para el componente
    mkdir -p packages/app/src/components/AiChat
    
    # Crear componente básico de AI Chat
    cat > packages/app/src/components/AiChat/AiChatPage.tsx << 'EOF'
import React, { useState } from 'react';
import {
  Page,
  Header,
  Content,
  ContentHeader,
} from '@backstage/core-components';
import { Grid, Paper, TextField, Button, Typography, Box } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
  chatContainer: {
    height: '400px',
    overflowY: 'auto',
    padding: theme.spacing(2),
    backgroundColor: theme.palette.background.default,
  },
  messageContainer: {
    marginBottom: theme.spacing(1),
  },
  userMessage: {
    textAlign: 'right',
    backgroundColor: theme.palette.primary.light,
    padding: theme.spacing(1),
    borderRadius: theme.spacing(1),
    marginLeft: theme.spacing(4),
  },
  aiMessage: {
    textAlign: 'left',
    backgroundColor: theme.palette.grey[200],
    padding: theme.spacing(1),
    borderRadius: theme.spacing(1),
    marginRight: theme.spacing(4),
  },
  inputContainer: {
    padding: theme.spacing(2),
  },
}));

interface Message {
  text: string;
  isUser: boolean;
  timestamp: Date;
}

export const AiChatPage = () => {
  const classes = useStyles();
  const [messages, setMessages] = useState<Message[]>([
    {
      text: "¡Hola! Soy tu asistente de IA para Backstage. ¿En qué puedo ayudarte?",
      isUser: false,
      timestamp: new Date(),
    },
  ]);
  const [inputMessage, setInputMessage] = useState('');

  const handleSendMessage = () => {
    if (inputMessage.trim()) {
      // Agregar mensaje del usuario
      const userMessage: Message = {
        text: inputMessage,
        isUser: true,
        timestamp: new Date(),
      };
      
      setMessages(prev => [...prev, userMessage]);
      
      // Simular respuesta de IA (aquí integrarías con una API real)
      setTimeout(() => {
        const aiResponse: Message = {
          text: `Gracias por tu mensaje: "${inputMessage}". Esta es una respuesta simulada. Para funcionalidad completa, integra con OpenAI API o similar.`,
          isUser: false,
          timestamp: new Date(),
        };
        setMessages(prev => [...prev, aiResponse]);
      }, 1000);
      
      setInputMessage('');
    }
  };

  const handleKeyPress = (event: React.KeyboardEvent) => {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      handleSendMessage();
    }
  };

  return (
    <Page themeId="tool">
      <Header title="AI Chat Assistant" subtitle="Asistente de IA para Backstage" />
      <Content>
        <ContentHeader title="Chat con IA">
          <Typography variant="body2">
            Pregunta sobre Backstage, desarrollo, o cualquier tema relacionado con tu plataforma.
          </Typography>
        </ContentHeader>
        
        <Grid container spacing={3}>
          <Grid item xs={12} md={8}>
            <Paper>
              <Box className={classes.chatContainer}>
                {messages.map((message, index) => (
                  <div key={index} className={classes.messageContainer}>
                    <Paper
                      className={message.isUser ? classes.userMessage : classes.aiMessage}
                      elevation={1}
                    >
                      <Typography variant="body2">
                        {message.text}
                      </Typography>
                      <Typography variant="caption" color="textSecondary">
                        {message.timestamp.toLocaleTimeString()}
                      </Typography>
                    </Paper>
                  </div>
                ))}
              </Box>
              
              <Box className={classes.inputContainer}>
                <Grid container spacing={2} alignItems="flex-end">
                  <Grid item xs={10}>
                    <TextField
                      fullWidth
                      multiline
                      maxRows={3}
                      variant="outlined"
                      placeholder="Escribe tu mensaje aquí..."
                      value={inputMessage}
                      onChange={(e) => setInputMessage(e.target.value)}
                      onKeyPress={handleKeyPress}
                    />
                  </Grid>
                  <Grid item xs={2}>
                    <Button
                      fullWidth
                      variant="contained"
                      color="primary"
                      onClick={handleSendMessage}
                      disabled={!inputMessage.trim()}
                    >
                      Enviar
                    </Button>
                  </Grid>
                </Grid>
              </Box>
            </Paper>
          </Grid>
          
          <Grid item xs={12} md={4}>
            <Paper style={{ padding: '16px' }}>
              <Typography variant="h6" gutterBottom>
                Comandos Útiles
              </Typography>
              <Typography variant="body2" paragraph>
                • "¿Cómo crear un componente?"
              </Typography>
              <Typography variant="body2" paragraph>
                • "Explica el Software Catalog"
              </Typography>
              <Typography variant="body2" paragraph>
                • "¿Qué es TechDocs?"
              </Typography>
              <Typography variant="body2" paragraph>
                • "Ayuda con GitHub Actions"
              </Typography>
              
              <Typography variant="h6" gutterBottom style={{ marginTop: '24px' }}>
                Estado
              </Typography>
              <Typography variant="body2" color="textSecondary">
                🤖 Modo: Simulación
              </Typography>
              <Typography variant="body2" color="textSecondary">
                🔌 API: No configurada
              </Typography>
              <Typography variant="body2" color="textSecondary">
                💡 Para funcionalidad completa, configura OpenAI API
              </Typography>
            </Paper>
          </Grid>
        </Grid>
      </Content>
    </Page>
  );
};
EOF

    echo "✅ Componente AiChatPage creado"
    
    # Crear archivo de exportación
    cat > packages/app/src/components/AiChat/index.ts << 'EOF'
export { AiChatPage } from './AiChatPage';
EOF

    echo "✅ Archivo de exportación creado"
    
    # Crear backup de App.tsx
    cp packages/app/src/App.tsx packages/app/src/App.tsx.backup.$(date +%Y%m%d_%H%M%S)
    echo "💾 Backup de App.tsx creado"
    
    # Agregar import y ruta en App.tsx
    echo "🔧 Agregando ruta en App.tsx..."
    
    # Agregar import después de los otros imports
    sed -i '/import.*from.*@backstage/a import { AiChatPage } from '\''./components/AiChat'\'';' packages/app/src/App.tsx
    
    # Agregar ruta antes de la ruta de NotFoundErrorPage
    sed -i '/NotFoundErrorPage/i\        <Route path="/ai-chat" element={<AiChatPage />} />' packages/app/src/App.tsx
    
    echo "✅ Ruta /ai-chat agregada a App.tsx"
    
    echo ""
    echo "🎉 PÁGINA DE AI CHAT CREADA:"
    echo "=========================="
    echo "• ✅ Componente React creado"
    echo "• ✅ Ruta /ai-chat configurada"
    echo "• ✅ Interfaz de chat básica"
    echo "• ✅ Simulación de respuestas"
    
else
    echo ""
    echo "✅ NO SE CREÓ PÁGINA DE AI CHAT"
    echo "=============================="
    echo "Puedes usar las rutas estándar de Backstage"
fi

echo ""
echo "🔍 VERIFICAR RUTAS DISPONIBLES:"
echo "==============================="

echo ""
echo "📋 Rutas que FUNCIONAN en tu Backstage:"
echo "======================================="
echo "• 🏠 Home: http://localhost:3002/"
echo "• 📊 Catalog: http://localhost:3002/catalog"
echo "• 🏗️  Create: http://localhost:3002/create"
echo "• 🔍 Search: http://localhost:3002/search"
echo "• 📡 Tech Radar: http://localhost:3002/tech-radar"
echo "• 📚 Docs: http://localhost:3002/docs"

if [ "$create_ai_chat" = "y" ] || [ "$create_ai_chat" = "Y" ]; then
    echo "• 🤖 AI Chat: http://localhost:3002/ai-chat (NUEVA)"
fi

echo ""
echo "🚀 PRÓXIMOS PASOS:"
echo "=================="

if [ "$create_ai_chat" = "y" ] || [ "$create_ai_chat" = "Y" ]; then
    echo "1. 🔄 Reiniciar Backstage:"
    echo "   ./start-with-env.sh"
    echo ""
    echo "2. 🌐 Probar la nueva página:"
    echo "   http://localhost:3002/ai-chat"
    echo ""
    echo "3. 🔧 Para funcionalidad completa de IA:"
    echo "   • Configurar OpenAI API key"
    echo "   • Integrar con servicio de IA"
    echo "   • Personalizar respuestas"
else
    echo "1. 🌐 Usar rutas disponibles:"
    echo "   http://localhost:3002/catalog"
    echo ""
    echo "2. 📖 Si necesitas AI Chat:"
    echo "   • Ejecuta este script nuevamente"
    echo "   • O instala un plugin específico"
fi

echo ""
echo "💡 NOTA:"
echo "========"
echo "El error 404 en /ai-chat es normal si no has instalado"
echo "un plugin específico de AI o no has configurado esa ruta."
echo "Backstage por defecto no incluye funcionalidad de AI Chat."
