#!/bin/bash

echo "🎨 MEJORANDO INTERFAZ DE AI CHAT"
echo "==============================="

echo ""
echo "🎯 MEJORAS A IMPLEMENTAR:"
echo "========================"
echo "• 🎨 Interfaz más moderna y atractiva"
echo "• 🤖 Integración con OpenAI service"
echo "• ⚡ Indicadores de carga"
echo "• 🎭 Avatares y mejor UX"
echo "• 🌈 Colores y animaciones"

echo ""
echo "🔧 ACTUALIZANDO COMPONENTE AI CHAT:"
echo "=================================="

# Crear backup del componente actual
cp packages/app/src/components/AiChat/AiChatPage.tsx packages/app/src/components/AiChat/AiChatPage.tsx.backup.$(date +%Y%m%d_%H%M%S)
echo "💾 Backup creado: AiChatPage.tsx.backup.*"

# Crear la nueva versión mejorada del componente
cat > packages/app/src/components/AiChat/AiChatPage.tsx << 'EOF'
import React, { useState, useRef, useEffect } from 'react';
import {
  Page,
  Header,
  Content,
  ContentHeader,
  Progress,
} from '@backstage/core-components';
import { 
  Grid, 
  Paper, 
  TextField, 
  Button, 
  Typography, 
  Box, 
  Avatar,
  Chip,
  IconButton,
  Fade,
  CircularProgress,
  Card,
  CardContent,
} from '@material-ui/core';
import { makeStyles, useTheme } from '@material-ui/core/styles';
import SendIcon from '@material-ui/icons/Send';
import SmartToyIcon from '@material-ui/icons/SmartToy';
import PersonIcon from '@material-ui/icons/Person';
import SettingsIcon from '@material-ui/icons/Settings';
import InfoIcon from '@material-ui/icons/Info';
import { openaiService, ChatMessage } from '../../services/openaiService';

const useStyles = makeStyles((theme) => ({
  root: {
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
  },
  chatContainer: {
    height: '500px',
    overflowY: 'auto',
    padding: theme.spacing(2),
    backgroundColor: theme.palette.background.default,
    borderRadius: theme.spacing(1),
    border: `1px solid ${theme.palette.divider}`,
    '&::-webkit-scrollbar': {
      width: '8px',
    },
    '&::-webkit-scrollbar-track': {
      background: theme.palette.grey[100],
      borderRadius: '4px',
    },
    '&::-webkit-scrollbar-thumb': {
      background: theme.palette.grey[400],
      borderRadius: '4px',
      '&:hover': {
        background: theme.palette.grey[600],
      },
    },
  },
  messageContainer: {
    marginBottom: theme.spacing(2),
    display: 'flex',
    alignItems: 'flex-start',
    gap: theme.spacing(1),
  },
  userMessageContainer: {
    flexDirection: 'row-reverse',
  },
  messageContent: {
    maxWidth: '70%',
    minWidth: '200px',
  },
  userMessage: {
    backgroundColor: theme.palette.primary.main,
    color: theme.palette.primary.contrastText,
    padding: theme.spacing(1.5),
    borderRadius: '18px 18px 4px 18px',
    wordWrap: 'break-word',
    boxShadow: theme.shadows[2],
  },
  aiMessage: {
    backgroundColor: theme.palette.grey[100],
    color: theme.palette.text.primary,
    padding: theme.spacing(1.5),
    borderRadius: '18px 18px 18px 4px',
    wordWrap: 'break-word',
    boxShadow: theme.shadows[1],
    border: `1px solid ${theme.palette.divider}`,
  },
  avatar: {
    width: theme.spacing(4),
    height: theme.spacing(4),
  },
  userAvatar: {
    backgroundColor: theme.palette.primary.main,
  },
  aiAvatar: {
    backgroundColor: theme.palette.secondary.main,
  },
  inputContainer: {
    padding: theme.spacing(2),
    backgroundColor: theme.palette.background.paper,
    borderRadius: theme.spacing(1),
    border: `1px solid ${theme.palette.divider}`,
    marginTop: theme.spacing(2),
  },
  inputField: {
    '& .MuiOutlinedInput-root': {
      borderRadius: theme.spacing(3),
      '&:hover fieldset': {
        borderColor: theme.palette.primary.main,
      },
    },
  },
  sendButton: {
    borderRadius: theme.spacing(3),
    minWidth: '60px',
    height: '56px',
  },
  timestamp: {
    fontSize: '0.75rem',
    color: theme.palette.text.secondary,
    marginTop: theme.spacing(0.5),
    textAlign: 'center',
  },
  loadingContainer: {
    display: 'flex',
    alignItems: 'center',
    gap: theme.spacing(1),
    padding: theme.spacing(1),
  },
  statusCard: {
    marginBottom: theme.spacing(2),
  },
  commandChip: {
    margin: theme.spacing(0.5),
    cursor: 'pointer',
    '&:hover': {
      backgroundColor: theme.palette.primary.light,
      color: theme.palette.primary.contrastText,
    },
  },
  configSection: {
    marginTop: theme.spacing(2),
    padding: theme.spacing(2),
    backgroundColor: theme.palette.background.paper,
    borderRadius: theme.spacing(1),
    border: `1px solid ${theme.palette.divider}`,
  },
}));

interface Message {
  text: string;
  isUser: boolean;
  timestamp: Date;
  id: string;
}

export const AiChatPage = () => {
  const classes = useStyles();
  const theme = useTheme();
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      text: "¡Hola! 👋 Soy tu asistente de IA especializado en Backstage. Puedo ayudarte con preguntas sobre desarrollo, DevOps, y la plataforma Backstage. ¿En qué puedo ayudarte hoy?",
      isUser: false,
      timestamp: new Date(),
    },
  ]);
  const [inputMessage, setInputMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const chatEndRef = useRef<HTMLDivElement>(null);
  const [isConfigured, setIsConfigured] = useState(false);

  useEffect(() => {
    setIsConfigured(openaiService.isConfigured());
  }, []);

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSendMessage = async () => {
    if (inputMessage.trim() && !isLoading) {
      const userMessage: Message = {
        id: Date.now().toString(),
        text: inputMessage,
        isUser: true,
        timestamp: new Date(),
      };
      
      setMessages(prev => [...prev, userMessage]);
      setInputMessage('');
      setIsLoading(true);

      try {
        // Preparar mensajes para OpenAI
        const chatMessages: ChatMessage[] = messages
          .slice(-5) // Solo los últimos 5 mensajes para contexto
          .map(msg => ({
            role: msg.isUser ? 'user' : 'assistant',
            content: msg.text,
          }));
        
        chatMessages.push({
          role: 'user',
          content: inputMessage,
        });

        const response = await openaiService.sendMessage(chatMessages);
        
        const aiResponse: Message = {
          id: (Date.now() + 1).toString(),
          text: response,
          isUser: false,
          timestamp: new Date(),
        };
        
        setMessages(prev => [...prev, aiResponse]);
      } catch (error) {
        console.error('Error sending message:', error);
        const errorMessage: Message = {
          id: (Date.now() + 1).toString(),
          text: "Lo siento, hubo un error al procesar tu mensaje. Por favor, inténtalo de nuevo.",
          isUser: false,
          timestamp: new Date(),
        };
        setMessages(prev => [...prev, errorMessage]);
      } finally {
        setIsLoading(false);
      }
    }
  };

  const handleKeyPress = (event: React.KeyboardEvent) => {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      handleSendMessage();
    }
  };

  const handleQuickCommand = (command: string) => {
    setInputMessage(command);
  };

  const quickCommands = [
    "¿Cómo crear un componente en Backstage?",
    "Explica el Software Catalog",
    "¿Qué es TechDocs?",
    "Ayuda con GitHub Actions",
    "¿Cómo usar el Scaffolder?",
    "Configurar plugins de Backstage",
  ];

  return (
    <Page themeId="tool">
      <Header 
        title="🤖 AI Chat Assistant" 
        subtitle="Asistente inteligente para Backstage y desarrollo"
      />
      <Content>
        <ContentHeader title="Chat con IA">
          <Typography variant="body2" color="textSecondary">
            Pregunta sobre Backstage, desarrollo, DevOps, o cualquier tema relacionado con tu plataforma.
          </Typography>
        </ContentHeader>
        
        <Grid container spacing={3}>
          <Grid item xs={12} md={8}>
            {/* Estado de configuración */}
            <Card className={classes.statusCard}>
              <CardContent>
                <Box display="flex" alignItems="center" gap={1}>
                  <InfoIcon color={isConfigured ? "primary" : "secondary"} />
                  <Typography variant="body2">
                    Estado: {isConfigured ? "🟢 OpenAI API Configurada" : "🟡 Modo Simulación"}
                  </Typography>
                  {!isConfigured && (
                    <Chip 
                      size="small" 
                      label="Configura API Key para IA real" 
                      color="secondary"
                    />
                  )}
                </Box>
              </CardContent>
            </Card>

            {/* Chat Container */}
            <Paper elevation={2}>
              <Box className={classes.chatContainer}>
                {messages.map((message) => (
                  <Fade in={true} key={message.id}>
                    <div 
                      className={`${classes.messageContainer} ${
                        message.isUser ? classes.userMessageContainer : ''
                      }`}
                    >
                      <Avatar 
                        className={`${classes.avatar} ${
                          message.isUser ? classes.userAvatar : classes.aiAvatar
                        }`}
                      >
                        {message.isUser ? <PersonIcon /> : <SmartToyIcon />}
                      </Avatar>
                      
                      <Box className={classes.messageContent}>
                        <Paper
                          className={message.isUser ? classes.userMessage : classes.aiMessage}
                          elevation={0}
                        >
                          <Typography variant="body2">
                            {message.text}
                          </Typography>
                        </Paper>
                        <Typography className={classes.timestamp}>
                          {message.timestamp.toLocaleTimeString()}
                        </Typography>
                      </Box>
                    </div>
                  </Fade>
                ))}
                
                {/* Loading indicator */}
                {isLoading && (
                  <Fade in={true}>
                    <div className={classes.messageContainer}>
                      <Avatar className={`${classes.avatar} ${classes.aiAvatar}`}>
                        <SmartToyIcon />
                      </Avatar>
                      <Box className={classes.loadingContainer}>
                        <CircularProgress size={20} />
                        <Typography variant="body2" color="textSecondary">
                          Pensando...
                        </Typography>
                      </Box>
                    </div>
                  </Fade>
                )}
                
                <div ref={chatEndRef} />
              </Box>
              
              {/* Input Container */}
              <Box className={classes.inputContainer}>
                <Grid container spacing={2} alignItems="flex-end">
                  <Grid item xs={10}>
                    <TextField
                      fullWidth
                      multiline
                      maxRows={3}
                      variant="outlined"
                      placeholder="Escribe tu mensaje aquí... (Enter para enviar)"
                      value={inputMessage}
                      onChange={(e) => setInputMessage(e.target.value)}
                      onKeyPress={handleKeyPress}
                      disabled={isLoading}
                      className={classes.inputField}
                    />
                  </Grid>
                  <Grid item xs={2}>
                    <Button
                      fullWidth
                      variant="contained"
                      color="primary"
                      onClick={handleSendMessage}
                      disabled={!inputMessage.trim() || isLoading}
                      className={classes.sendButton}
                      startIcon={isLoading ? <CircularProgress size={20} /> : <SendIcon />}
                    >
                      {isLoading ? '' : 'Enviar'}
                    </Button>
                  </Grid>
                </Grid>
              </Box>
            </Paper>
          </Grid>
          
          {/* Sidebar */}
          <Grid item xs={12} md={4}>
            {/* Quick Commands */}
            <Paper style={{ padding: '16px', marginBottom: '16px' }}>
              <Typography variant="h6" gutterBottom>
                🚀 Comandos Rápidos
              </Typography>
              <Box>
                {quickCommands.map((command, index) => (
                  <Chip
                    key={index}
                    label={command}
                    onClick={() => handleQuickCommand(command)}
                    className={classes.commandChip}
                    size="small"
                    variant="outlined"
                  />
                ))}
              </Box>
            </Paper>

            {/* Configuration */}
            <Paper style={{ padding: '16px' }}>
              <Box display="flex" alignItems="center" gap={1} marginBottom={2}>
                <SettingsIcon />
                <Typography variant="h6">
                  Configuración
                </Typography>
              </Box>
              
              <Typography variant="body2" paragraph>
                <strong>Modelo:</strong> {openaiService.getConfig().model}
              </Typography>
              <Typography variant="body2" paragraph>
                <strong>Max Tokens:</strong> {openaiService.getConfig().maxTokens}
              </Typography>
              <Typography variant="body2" paragraph>
                <strong>Temperature:</strong> {openaiService.getConfig().temperature}
              </Typography>
              
              <Typography variant="body2" color="textSecondary" paragraph>
                {isConfigured 
                  ? "✅ Usando OpenAI API real"
                  : "🔧 Usando respuestas simuladas"
                }
              </Typography>

              {!isConfigured && (
                <Box className={classes.configSection}>
                  <Typography variant="subtitle2" gutterBottom>
                    Para habilitar IA real:
                  </Typography>
                  <Typography variant="body2" paragraph>
                    1. Obtén una API key de OpenAI
                  </Typography>
                  <Typography variant="body2" paragraph>
                    2. Edita packages/app/.env.local
                  </Typography>
                  <Typography variant="body2">
                    3. Agrega: REACT_APP_OPENAI_API_KEY=tu-key
                  </Typography>
                </Box>
              )}
            </Paper>
          </Grid>
        </Grid>
      </Content>
    </Page>
  );
};
EOF

echo "✅ Componente AI Chat mejorado creado"

echo ""
echo "🎨 MEJORAS IMPLEMENTADAS:"
echo "======================="
echo "• ✅ Interfaz moderna con Material-UI"
echo "• ✅ Avatares para usuario y IA"
echo "• ✅ Animaciones y transiciones"
echo "• ✅ Indicadores de carga"
echo "• ✅ Scroll automático"
echo "• ✅ Comandos rápidos"
echo "• ✅ Estado de configuración"
echo "• ✅ Integración con OpenAI service"
echo "• ✅ Mejor UX y diseño responsive"

echo ""
echo "🎯 FUNCIONALIDADES NUEVAS:"
echo "========================="
echo "• 🤖 Integración real con OpenAI (cuando se configure)"
echo "• 🎨 Interfaz más atractiva y moderna"
echo "• ⚡ Indicadores de estado y carga"
echo "• 🚀 Comandos rápidos predefinidos"
echo "• 📱 Diseño completamente responsive"
echo "• 🎭 Avatares personalizados"
echo "• 🌈 Colores y animaciones mejoradas"
echo "• 📊 Panel de configuración"

echo ""
echo "✅ ACTUALIZACIÓN COMPLETADA:"
echo "=========================="
echo "• ✅ Componente actualizado con nueva interfaz"
echo "• ✅ Servicio OpenAI integrado"
echo "• ✅ Backup del componente anterior creado"
echo "• ✅ Funcionalidad mejorada significativamente"
