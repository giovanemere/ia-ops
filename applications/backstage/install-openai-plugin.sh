#!/bin/bash

echo "🤖 INSTALANDO PLUGIN OPENAI PERSONALIZADO"
echo "========================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}1. CREANDO ESTRUCTURA DEL PLUGIN OPENAI${NC}"
echo "--------------------------------------"

# Crear directorio del plugin
PLUGIN_DIR="plugins/openai"
mkdir -p "$PLUGIN_DIR/src/components"
mkdir -p "$PLUGIN_DIR/src/api"

echo -e "${GREEN}✅ Estructura de directorios creada${NC}"

# Crear package.json del plugin
echo -e "${BLUE}2. CREANDO PACKAGE.JSON DEL PLUGIN${NC}"
echo "--------------------------------"

cat > "$PLUGIN_DIR/package.json" << 'EOF'
{
  "name": "@internal/plugin-openai",
  "version": "0.1.0",
  "main": "src/index.ts",
  "types": "src/index.ts",
  "license": "Apache-2.0",
  "private": true,
  "publishConfig": {
    "access": "public",
    "main": "dist/index.esm.js",
    "types": "dist/index.d.ts"
  },
  "backstage": {
    "role": "frontend-plugin"
  },
  "scripts": {
    "start": "backstage-cli package start",
    "build": "backstage-cli package build",
    "lint": "backstage-cli package lint",
    "test": "backstage-cli package test",
    "clean": "backstage-cli package clean",
    "prepack": "backstage-cli package prepack",
    "postpack": "backstage-cli package postpack"
  },
  "dependencies": {
    "@backstage/core-components": "^0.17.4",
    "@backstage/core-plugin-api": "^1.10.9",
    "@backstage/theme": "^0.6.7",
    "@material-ui/core": "^4.12.2",
    "@material-ui/icons": "^4.9.1",
    "@material-ui/lab": "4.0.0-alpha.61",
    "react": "^18.0.2",
    "react-dom": "^18.0.2",
    "react-router": "^6.3.0",
    "react-router-dom": "^6.3.0"
  },
  "devDependencies": {
    "@backstage/cli": "^0.33.1",
    "@backstage/core-app-api": "^1.18.0",
    "@backstage/dev-utils": "^1.1.9",
    "@backstage/test-utils": "^1.7.10",
    "@testing-library/jest-dom": "^6.0.0",
    "@testing-library/react": "^14.0.0",
    "@testing-library/user-event": "^14.0.0",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0"
  },
  "files": [
    "dist"
  ]
}
EOF

echo -e "${GREEN}✅ package.json del plugin creado${NC}"

# Crear index.ts del plugin
echo -e "${BLUE}3. CREANDO ARCHIVOS PRINCIPALES DEL PLUGIN${NC}"
echo "----------------------------------------"

cat > "$PLUGIN_DIR/src/index.ts" << 'EOF'
export { openaiPlugin, OpenAIPage } from './plugin';
export { OpenAIChatComponent } from './components/OpenAIChatComponent';
EOF

# Crear plugin.ts
cat > "$PLUGIN_DIR/src/plugin.ts" << 'EOF'
import {
  createPlugin,
  createRoutableExtension,
} from '@backstage/core-plugin-api';

import { rootRouteRef } from './routes';

export const openaiPlugin = createPlugin({
  id: 'openai',
  routes: {
    root: rootRouteRef,
  },
});

export const OpenAIPage = openaiPlugin.provide(
  createRoutableExtension({
    name: 'OpenAIPage',
    component: () =>
      import('./components/OpenAIPage').then(m => m.OpenAIPage),
    mountPoint: rootRouteRef,
  }),
);
EOF

# Crear routes.ts
cat > "$PLUGIN_DIR/src/routes.ts" << 'EOF'
import { createRouteRef } from '@backstage/core-plugin-api';

export const rootRouteRef = createRouteRef({
  id: 'openai',
});
EOF

# Crear componente principal
cat > "$PLUGIN_DIR/src/components/OpenAIPage.tsx" << 'EOF'
import React from 'react';
import { Typography, Grid } from '@material-ui/core';
import {
  Page,
  Header,
  Content,
  ContentHeader,
  HeaderLabel,
  SupportButton,
} from '@backstage/core-components';
import { OpenAIChatComponent } from './OpenAIChatComponent';

export const OpenAIPage = () => (
  <Page themeId="tool">
    <Header title="OpenAI Assistant" subtitle="DevOps AI Assistant">
      <HeaderLabel label="Owner" value="IA-Ops Team" />
      <HeaderLabel label="Lifecycle" value="Alpha" />
    </Header>
    <Content>
      <ContentHeader title="DevOps AI Assistant">
        <SupportButton>
          AI-powered assistant for code analysis, documentation generation, and architectural recommendations.
        </SupportButton>
      </ContentHeader>
      <Grid container spacing={3} direction="column">
        <Grid item>
          <OpenAIChatComponent />
        </Grid>
      </Grid>
    </Content>
  </Page>
);
EOF

# Crear componente de chat
cat > "$PLUGIN_DIR/src/components/OpenAIChatComponent.tsx" << 'EOF'
import React, { useState } from 'react';
import {
  Card,
  CardContent,
  TextField,
  Button,
  Typography,
  Box,
  Paper,
  CircularProgress,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import SendIcon from '@material-ui/icons/Send';
import SmartToyIcon from '@material-ui/icons/SmartToy';

const useStyles = makeStyles(theme => ({
  chatContainer: {
    height: '600px',
    display: 'flex',
    flexDirection: 'column',
  },
  messagesContainer: {
    flex: 1,
    overflowY: 'auto',
    padding: theme.spacing(1),
    marginBottom: theme.spacing(2),
  },
  message: {
    marginBottom: theme.spacing(1),
    padding: theme.spacing(1, 2),
    borderRadius: theme.spacing(1),
  },
  userMessage: {
    backgroundColor: theme.palette.primary.light,
    color: theme.palette.primary.contrastText,
    marginLeft: theme.spacing(4),
  },
  aiMessage: {
    backgroundColor: theme.palette.grey[100],
    marginRight: theme.spacing(4),
  },
  inputContainer: {
    display: 'flex',
    gap: theme.spacing(1),
    alignItems: 'flex-end',
  },
  textField: {
    flex: 1,
  },
}));

interface Message {
  id: string;
  text: string;
  sender: 'user' | 'ai';
  timestamp: Date;
}

export const OpenAIChatComponent = () => {
  const classes = useStyles();
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      text: 'Hello! I\'m your DevOps AI Assistant. I can help you with code analysis, documentation generation, and architectural recommendations. How can I assist you today?',
      sender: 'ai',
      timestamp: new Date(),
    },
  ]);
  const [inputText, setInputText] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSendMessage = async () => {
    if (!inputText.trim()) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      text: inputText,
      sender: 'user',
      timestamp: new Date(),
    };

    setMessages(prev => [...prev, userMessage]);
    setInputText('');
    setIsLoading(true);

    try {
      // TODO: Replace with actual OpenAI Service call
      const response = await fetch('http://localhost:8003/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: inputText,
          context: 'devops_assistant',
        }),
      });

      let aiResponseText = 'I\'m currently in demo mode. The OpenAI service integration is being configured. Your message was: "' + inputText + '"';
      
      if (response.ok) {
        const data = await response.json();
        aiResponseText = data.response || data.message || aiResponseText;
      }

      const aiMessage: Message = {
        id: (Date.now() + 1).toString(),
        text: aiResponseText,
        sender: 'ai',
        timestamp: new Date(),
      };

      setMessages(prev => [...prev, aiMessage]);
    } catch (error) {
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        text: 'Sorry, I\'m having trouble connecting to the AI service. Please try again later.',
        sender: 'ai',
        timestamp: new Date(),
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleKeyPress = (event: React.KeyboardEvent) => {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      handleSendMessage();
    }
  };

  return (
    <Card>
      <CardContent>
        <Box display="flex" alignItems="center" mb={2}>
          <SmartToyIcon color="primary" />
          <Typography variant="h6" style={{ marginLeft: 8 }}>
            DevOps AI Assistant
          </Typography>
        </Box>
        
        <Paper className={classes.chatContainer} variant="outlined">
          <div className={classes.messagesContainer}>
            {messages.map(message => (
              <Paper
                key={message.id}
                className={`${classes.message} ${
                  message.sender === 'user' ? classes.userMessage : classes.aiMessage
                }`}
                elevation={1}
              >
                <Typography variant="body2">
                  {message.text}
                </Typography>
              </Paper>
            ))}
            {isLoading && (
              <Box display="flex" justifyContent="center" p={2}>
                <CircularProgress size={24} />
              </Box>
            )}
          </div>
          
          <div className={classes.inputContainer}>
            <TextField
              className={classes.textField}
              multiline
              maxRows={4}
              variant="outlined"
              placeholder="Ask me about code analysis, documentation, or architecture..."
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              onKeyPress={handleKeyPress}
              disabled={isLoading}
            />
            <Button
              variant="contained"
              color="primary"
              endIcon={<SendIcon />}
              onClick={handleSendMessage}
              disabled={isLoading || !inputText.trim()}
            >
              Send
            </Button>
          </div>
        </Paper>
      </CardContent>
    </Card>
  );
};
EOF

echo -e "${GREEN}✅ Componentes del plugin creados${NC}"

# Agregar plugin al workspace
echo -e "${BLUE}4. CONFIGURANDO WORKSPACE${NC}"
echo "------------------------"

# Verificar si el plugin ya está en el workspace
if ! grep -q "plugins/openai" package.json; then
    # Agregar al workspace en package.json
    sed -i 's/"packages\/\*"/"packages\/\*",\n      "plugins\/\*"/' package.json
    echo -e "${GREEN}✅ Plugin agregado al workspace${NC}"
else
    echo -e "${YELLOW}⚠️  Plugin ya está en el workspace${NC}"
fi

# Instalar dependencias del plugin
echo -e "${BLUE}5. INSTALANDO DEPENDENCIAS${NC}"
echo "-------------------------"

echo "Instalando dependencias del plugin OpenAI..."
yarn install

echo -e "${GREEN}✅ Dependencias instaladas${NC}"

# Instrucciones para configurar en App.tsx
echo ""
echo -e "${BLUE}6. INSTRUCCIONES DE CONFIGURACIÓN${NC}"
echo "--------------------------------"

echo -e "${YELLOW}Para completar la instalación, agrega lo siguiente a App.tsx:${NC}"
echo ""
echo "1. Importar el plugin:"
echo "   import { OpenAIPage } from '@internal/plugin-openai';"
echo ""
echo "2. Agregar la ruta:"
echo "   <Route path=\"/openai\" element={<OpenAIPage />} />"
echo ""
echo "3. Agregar al menú de navegación en Root.tsx:"
echo "   <SidebarItem icon={SmartToyIcon} to=\"openai\" text=\"AI Assistant\" />"

echo ""
echo -e "${GREEN}🎉 PLUGIN OPENAI CREADO EXITOSAMENTE${NC}"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "1. Configurar el plugin en App.tsx (instrucciones arriba)"
echo "2. Reiniciar Backstage: ./start-with-env.sh"
echo "3. Acceder a: http://localhost:3002/openai"
echo "4. Configurar integración con OpenAI Service en puerto 8003"
