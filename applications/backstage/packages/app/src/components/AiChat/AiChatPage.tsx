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
