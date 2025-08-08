import React, { useState } from 'react';
import {
  Card,
  CardContent,
  CardHeader,
  TextField,
  Button,
  Typography,
  CircularProgress,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import SendIcon from '@material-ui/icons/Send';
import AndroidIcon from '@material-ui/icons/Android';

const useStyles = makeStyles((theme) => ({
  chatContainer: {
    maxWidth: 800,
    margin: '0 auto',
    padding: theme.spacing(2),
  },
  chatMessages: {
    height: 400,
    overflowY: 'auto',
    padding: theme.spacing(1),
    backgroundColor: '#f5f5f5',
    borderRadius: theme.spacing(1),
    marginBottom: theme.spacing(2),
  },
  messageBox: {
    display: 'flex',
    alignItems: 'flex-start',
    marginBottom: theme.spacing(1),
    gap: theme.spacing(1),
  },
  userMessage: {
    justifyContent: 'flex-end',
  },
  aiMessage: {
    justifyContent: 'flex-start',
  },
  messageBubble: {
    maxWidth: '70%',
    padding: theme.spacing(1, 2),
    borderRadius: theme.spacing(2),
    wordWrap: 'break-word',
  },
  userBubble: {
    backgroundColor: theme.palette.primary.main,
    color: 'white',
  },
  aiBubble: {
    backgroundColor: 'white',
    border: `1px solid ${theme.palette.divider}`,
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
  content: string;
  role: 'user' | 'assistant';
  timestamp: Date;
}

export const OpenAIChat: React.FC = () => {
  const classes = useStyles();
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      content: '¡Hola! Soy el asistente DevOps con IA. Puedo ayudarte con análisis de código, documentación, arquitecturas de referencia y más. ¿En qué puedo ayudarte hoy?',
      role: 'assistant',
      timestamp: new Date(),
    },
  ]);
  const [inputValue, setInputValue] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSendMessage = async () => {
    if (!inputValue.trim()) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      content: inputValue,
      role: 'user',
      timestamp: new Date(),
    };

    setMessages(prev => [...prev, userMessage]);
    setInputValue('');
    setIsLoading(true);

    // TODO: Integrate with OpenAI Service
    // For now, simulate AI response
    setTimeout(() => {
      const aiMessage: Message = {
        id: (Date.now() + 1).toString(),
        content: `Entiendo tu consulta: "${inputValue}". Esta es una respuesta simulada. Una vez que el OpenAI Service esté integrado, podré proporcionarte análisis detallados de código, recomendaciones arquitectónicas y documentación automática.`,
        role: 'assistant',
        timestamp: new Date(),
      };
      setMessages(prev => [...prev, aiMessage]);
      setIsLoading(false);
    }, 1500);
  };

  const handleKeyPress = (event: React.KeyboardEvent) => {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      handleSendMessage();
    }
  };

  return (
    <div className={classes.chatContainer}>
      <Card className="ia-ops-card">
        <CardHeader
          avatar={<AndroidIcon />}
          title="Asistente DevOps con IA"
          subheader="Análisis de código, documentación y arquitecturas de referencia"
          className="ia-ops-header"
        />
        <CardContent>
          <div className={classes.chatMessages}>
            {messages.map((message) => (
              <div
                key={message.id}
                className={`${classes.messageBox} ${
                  message.role === 'user' ? classes.userMessage : classes.aiMessage
                }`}
              >
                <div
                  className={`${classes.messageBubble} ${
                    message.role === 'user' ? classes.userBubble : classes.aiBubble
                  }`}
                >
                  <Typography variant="body2">{message.content}</Typography>
                </div>
              </div>
            ))}
            {isLoading && (
              <div className={`${classes.messageBox} ${classes.aiMessage}`}>
                <div className={classes.aiBubble}>
                  <CircularProgress size={20} />
                  <Typography variant="body2" style={{ marginLeft: 8 }}>
                    Analizando...
                  </Typography>
                </div>
              </div>
            )}
          </div>
          
          <div className={classes.inputContainer}>
            <TextField
              className={classes.textField}
              multiline
              maxRows={4}
              variant="outlined"
              placeholder="Pregunta sobre análisis de código, arquitecturas, documentación..."
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              onKeyPress={handleKeyPress}
              disabled={isLoading}
            />
            <Button
              variant="contained"
              color="primary"
              endIcon={<SendIcon />}
              onClick={handleSendMessage}
              disabled={isLoading || !inputValue.trim()}
            >
              Enviar
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};
