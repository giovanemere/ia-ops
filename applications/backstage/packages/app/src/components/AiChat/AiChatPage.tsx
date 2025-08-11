import { useState, useRef, useEffect } from 'react';
import {
  Page,
  Header,
  Content,
  ContentHeader,
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
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import SendIcon from '@material-ui/icons/Send';
import AndroidIcon from '@material-ui/icons/Android';
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
    backgroundColor: theme.palette.type === 'dark' 
      ? '#1e1e1e' 
      : theme.palette.background.default,
    borderRadius: theme.spacing(1),
    border: `1px solid ${theme.palette.divider}`,
    '&::-webkit-scrollbar': {
      width: '8px',
    },
    '&::-webkit-scrollbar-track': {
      background: theme.palette.type === 'dark' 
        ? '#2d2d2d' 
        : theme.palette.grey[100],
      borderRadius: '4px',
    },
    '&::-webkit-scrollbar-thumb': {
      background: theme.palette.type === 'dark' 
        ? '#555555' 
        : theme.palette.grey[400],
      borderRadius: '4px',
      '&:hover': {
        background: theme.palette.type === 'dark' 
          ? '#666666' 
          : theme.palette.grey[600],
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
    backgroundColor: theme.palette.type === 'dark' 
      ? '#2d2d2d' 
      : theme.palette.grey[100],
    color: theme.palette.type === 'dark' 
      ? '#e0e0e0' 
      : theme.palette.text.primary,
    padding: theme.spacing(1.5),
    borderRadius: '18px 18px 18px 4px',
    wordWrap: 'break-word',
    boxShadow: theme.shadows[1],
    border: theme.palette.type === 'dark' 
      ? '1px solid #404040' 
      : `1px solid ${theme.palette.divider}`,
    // Estilos específicos para elementos pre y code dentro de mensajes AI
    '& pre': {
      backgroundColor: theme.palette.type === 'dark' 
        ? '#1a1a1a !important' 
        : '#f5f5f5 !important',
      color: theme.palette.type === 'dark' 
        ? '#00ff00 !important' 
        : '#333333 !important',
      border: theme.palette.type === 'dark' 
        ? '1px solid #333333 !important' 
        : '1px solid #ddd !important',
      borderRadius: '4px',
      padding: '12px',
      overflow: 'auto',
      fontSize: '0.875rem',
      fontFamily: "'Roboto Mono', 'Monaco', 'Consolas', monospace",
      margin: '8px 0',
    },
    '& code': {
      backgroundColor: theme.palette.type === 'dark' 
        ? '#3a3a3a !important' 
        : '#f0f0f0 !important',
      color: theme.palette.type === 'dark' 
        ? '#f5f5f5 !important' 
        : '#333333 !important',
      padding: '2px 4px',
      borderRadius: '3px',
      fontFamily: "'Roboto Mono', 'Monaco', 'Consolas', monospace",
    },
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
    backgroundColor: theme.palette.type === 'dark' 
      ? '#2d2d2d' 
      : theme.palette.background.paper,
    borderRadius: theme.spacing(1),
    border: theme.palette.type === 'dark' 
      ? '1px solid #404040' 
      : `1px solid ${theme.palette.divider}`,
    marginTop: theme.spacing(2),
  },
  inputField: {
    '& .MuiOutlinedInput-root': {
      borderRadius: theme.spacing(3),
      backgroundColor: theme.palette.type === 'dark' 
        ? '#1e1e1e' 
        : theme.palette.background.default,
      color: theme.palette.type === 'dark' 
        ? '#e0e0e0' 
        : theme.palette.text.primary,
      '& fieldset': {
        borderColor: theme.palette.type === 'dark' 
          ? '#404040' 
          : theme.palette.divider,
      },
      '&:hover fieldset': {
        borderColor: theme.palette.primary.main,
      },
      '&.Mui-focused fieldset': {
        borderColor: theme.palette.primary.main,
      },
    },
    '& .MuiInputBase-input': {
      color: theme.palette.type === 'dark' 
        ? '#e0e0e0' 
        : theme.palette.text.primary,
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
    backgroundColor: theme.palette.type === 'dark' 
      ? '#2d2d2d' 
      : theme.palette.background.paper,
    borderRadius: theme.spacing(1),
    border: theme.palette.type === 'dark' 
      ? '1px solid #404040' 
      : `1px solid ${theme.palette.divider}`,
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
  const [configDialogOpen, setConfigDialogOpen] = useState(false);
  const [apiKey, setApiKey] = useState('');

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
        // Error manejado silenciosamente - se muestra mensaje de error al usuario
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

  const handleConfigSave = () => {
    if (apiKey.trim()) {
      openaiService.updateConfig({ apiKey: apiKey.trim() });
      setIsConfigured(openaiService.isConfigured());
      setConfigDialogOpen(false);
      setApiKey('');
    }
  };

  const handleConfigOpen = () => {
    setConfigDialogOpen(true);
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
                <Box display="flex" alignItems="center">
                  <InfoIcon color={isConfigured ? "primary" : "secondary"} style={{ marginRight: 8 }} />
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
                  <IconButton 
                    size="small" 
                    onClick={handleConfigOpen}
                    title="Configurar OpenAI API"
                  >
                    <SettingsIcon />
                  </IconButton>
                </Box>
              </CardContent>
            </Card>

            {/* Chat Container */}
            <Paper elevation={2}>
              <Box className={classes.chatContainer}>
                {messages.map((message) => (
                  <Fade in key={message.id}>
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
                        {message.isUser ? <PersonIcon /> : <AndroidIcon />}
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
                  <Fade in>
                    <div className={classes.messageContainer}>
                      <Avatar className={`${classes.avatar} ${classes.aiAvatar}`}>
                        <AndroidIcon />
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
              <Box display="flex" alignItems="center" marginBottom={2}>
                <SettingsIcon style={{ marginRight: 8 }} />
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

        {/* Configuration Dialog */}
        <Dialog 
          open={configDialogOpen} 
          onClose={() => setConfigDialogOpen(false)}
          maxWidth="sm"
          fullWidth
        >
          <DialogTitle>Configurar OpenAI API</DialogTitle>
          <DialogContent>
            <Typography variant="body2" paragraph>
              Para habilitar la IA real, necesitas una API key de OpenAI.
            </Typography>
            <TextField
              fullWidth
              label="OpenAI API Key"
              type="password"
              value={apiKey}
              onChange={(e) => setApiKey(e.target.value)}
              placeholder="sk-..."
              margin="normal"
              helperText="Tu API key se guardará localmente en tu navegador"
            />
            <Typography variant="caption" color="textSecondary">
              Puedes obtener tu API key en: https://platform.openai.com/api-keys
            </Typography>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setConfigDialogOpen(false)}>
              Cancelar
            </Button>
            <Button 
              onClick={handleConfigSave} 
              color="primary" 
              variant="contained"
              disabled={!apiKey.trim()}
            >
              Guardar
            </Button>
          </DialogActions>
        </Dialog>
      </Content>
    </Page>
  );
};
