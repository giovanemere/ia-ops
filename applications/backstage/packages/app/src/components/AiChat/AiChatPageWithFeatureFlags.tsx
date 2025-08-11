import React, { useState, useRef, useEffect } from 'react';
import {
  Page,
  Header,
  Content,
  ContentHeader,
  InfoCard,
} from '@backstage/core-components';
import { useApi, featureFlagsApiRef } from '@backstage/core-plugin-api';
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
  Switch,
  FormControlLabel,
  Divider,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import SendIcon from '@material-ui/icons/Send';
import AndroidIcon from '@material-ui/icons/Android';
import PersonIcon from '@material-ui/icons/Person';
import SettingsIcon from '@material-ui/icons/Settings';
import InfoIcon from '@material-ui/icons/Info';
import PaletteIcon from '@material-ui/icons/Palette';
import TrendingUpIcon from '@material-ui/icons/TrendingUp';
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
  // Enhanced dark mode styles (when feature flag is enabled)
  chatContainerDarkMode: {
    backgroundColor: theme.palette.type === 'dark' ? '#1a1a1a' : theme.palette.background.default,
    border: `1px solid ${theme.palette.type === 'dark' ? '#333' : theme.palette.divider}`,
    '&::-webkit-scrollbar-track': {
      background: theme.palette.type === 'dark' ? '#2a2a2a' : theme.palette.grey[100],
    },
    '&::-webkit-scrollbar-thumb': {
      background: theme.palette.type === 'dark' ? '#555' : theme.palette.grey[400],
      '&:hover': {
        background: theme.palette.type === 'dark' ? '#777' : theme.palette.grey[600],
      },
    },
  },
  messageContainer: {
    display: 'flex',
    alignItems: 'flex-start',
    marginBottom: theme.spacing(2),
    animation: '$fadeIn 0.3s ease-in',
  },
  // Enhanced animations (when experimental UI is enabled)
  messageContainerEnhanced: {
    animation: '$slideInFromBottom 0.5s ease-out',
    transform: 'translateY(0)',
  },
  userMessage: {
    justifyContent: 'flex-end',
  },
  messageContent: {
    maxWidth: '70%',
    padding: theme.spacing(1.5),
    borderRadius: theme.spacing(2),
    wordWrap: 'break-word',
  },
  userMessageContent: {
    backgroundColor: theme.palette.primary.main,
    color: theme.palette.primary.contrastText,
    marginLeft: theme.spacing(1),
  },
  aiMessageContent: {
    backgroundColor: theme.palette.grey[100],
    color: theme.palette.text.primary,
    marginRight: theme.spacing(1),
  },
  // Enhanced AI message styling (when experimental UI is enabled)
  aiMessageContentEnhanced: {
    background: `linear-gradient(135deg, ${theme.palette.grey[100]} 0%, ${theme.palette.grey[50]} 100%)`,
    boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
    border: `1px solid ${theme.palette.grey[200]}`,
  },
  inputContainer: {
    display: 'flex',
    gap: theme.spacing(1),
    alignItems: 'flex-end',
    marginTop: theme.spacing(2),
  },
  textField: {
    flex: 1,
  },
  sendButton: {
    minWidth: 'auto',
    padding: theme.spacing(1.5),
  },
  avatar: {
    width: theme.spacing(4),
    height: theme.spacing(4),
  },
  settingsButton: {
    marginLeft: 'auto',
  },
  featureBadge: {
    marginLeft: theme.spacing(1),
    fontSize: '0.75rem',
  },
  analyticsCard: {
    marginTop: theme.spacing(2),
    background: `linear-gradient(135deg, ${theme.palette.primary.light} 0%, ${theme.palette.primary.main} 100%)`,
    color: theme.palette.primary.contrastText,
  },
  '@keyframes fadeIn': {
    from: { opacity: 0 },
    to: { opacity: 1 },
  },
  '@keyframes slideInFromBottom': {
    from: { 
      opacity: 0,
      transform: 'translateY(20px)',
    },
    to: { 
      opacity: 1,
      transform: 'translateY(0)',
    },
  },
}));

export const AiChatPageWithFeatureFlags = () => {
  const classes = useStyles();
  const featureFlagsApi = useApi(featureFlagsApiRef);
  
  // Feature flags
  const isAdvancedFeaturesEnabled = featureFlagsApi.isActive('enable-advanced-features');
  const isExperimentalUIEnabled = featureFlagsApi.isActive('enable-experimental-ui');
  const isBetaAnalyticsEnabled = featureFlagsApi.isActive('enable-beta-analytics');
  const isDarkModeEnhancementsEnabled = featureFlagsApi.isActive('enable-dark-mode-enhancements');

  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      role: 'assistant',
      content: `Hello! I'm your AI assistant. ${isAdvancedFeaturesEnabled ? 'Advanced features are enabled!' : ''} ${isExperimentalUIEnabled ? 'You\'re using the experimental UI!' : ''} How can I help you today?`,
    },
  ]);
  const [inputValue, setInputValue] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [settingsOpen, setSettingsOpen] = useState(false);
  const [messageCount, setMessageCount] = useState(1);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = async () => {
    if (!inputValue.trim() || isLoading) return;

    const userMessage: ChatMessage = {
      role: 'user',
      content: inputValue,
    };

    setMessages(prev => [...prev, userMessage]);
    setInputValue('');
    setIsLoading(true);
    setMessageCount(prev => prev + 1);

    try {
      const responseContent = await openaiService.sendMessage([...messages, userMessage]);
      const response: ChatMessage = {
        role: 'assistant',
        content: responseContent,
      };
      setMessages(prev => [...prev, response]);
    } catch (error) {
      // Error handling - log to backstage logger instead of console
      // console.error('Error sending message:', error);
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: 'Sorry, I encountered an error. Please try again.',
      }]);
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

  const getChatContainerClass = () => {
    let baseClass = classes.chatContainer;
    if (isDarkModeEnhancementsEnabled) {
      baseClass += ` ${classes.chatContainerDarkMode}`;
    }
    return baseClass;
  };

  const getMessageContainerClass = (isUser: boolean) => {
    let baseClass = `${classes.messageContainer} ${isUser ? classes.userMessage : ''}`;
    if (isExperimentalUIEnabled) {
      baseClass += ` ${classes.messageContainerEnhanced}`;
    }
    return baseClass;
  };

  const getAiMessageContentClass = () => {
    let baseClass = classes.aiMessageContent;
    if (isExperimentalUIEnabled) {
      baseClass += ` ${classes.aiMessageContentEnhanced}`;
    }
    return baseClass;
  };

  return (
    <Page themeId="tool">
      <Header 
        title="AI Assistant" 
        subtitle={
          <Box display="flex" alignItems="center">
            <span>Chat with our intelligent assistant</span>
            {isAdvancedFeaturesEnabled && (
              <Chip 
                label="Advanced" 
                size="small" 
                color="primary" 
                className={classes.featureBadge}
              />
            )}
            {isExperimentalUIEnabled && (
              <Chip 
                label="Experimental UI" 
                size="small" 
                color="secondary" 
                className={classes.featureBadge}
              />
            )}
          </Box>
        }
      >
        <IconButton 
          className={classes.settingsButton}
          onClick={() => setSettingsOpen(true)}
        >
          <SettingsIcon />
        </IconButton>
      </Header>
      <Content>
        <Grid container spacing={3}>
          <Grid item xs={12} md={isBetaAnalyticsEnabled ? 8 : 12}>
            <Paper className={classes.root}>
              <ContentHeader title="Chat">
                <Box display="flex" alignItems="center" style={{ gap: '8px' }}>
                  {isDarkModeEnhancementsEnabled && (
                    <Chip 
                      icon={<PaletteIcon />}
                      label="Enhanced Dark Mode" 
                      size="small" 
                      variant="outlined"
                    />
                  )}
                  <InfoIcon color="action" />
                </Box>
              </ContentHeader>
              
              <Box className={getChatContainerClass()}>
                {messages.map((message, index) => (
                  <Fade in key={index} timeout={isExperimentalUIEnabled ? 500 : 300}>
                    <div className={getMessageContainerClass(message.role === 'user')}>
                      {message.role === 'assistant' && (
                        <Avatar className={classes.avatar}>
                          <AndroidIcon />
                        </Avatar>
                      )}
                      <Paper 
                        className={`${classes.messageContent} ${
                          message.role === 'user' 
                            ? classes.userMessageContent 
                            : getAiMessageContentClass()
                        }`}
                        elevation={isExperimentalUIEnabled ? 3 : 1}
                      >
                        <Typography variant="body1">
                          {message.content}
                        </Typography>
                      </Paper>
                      {message.role === 'user' && (
                        <Avatar className={classes.avatar}>
                          <PersonIcon />
                        </Avatar>
                      )}
                    </div>
                  </Fade>
                ))}
                
                {isLoading && (
                  <Fade in>
                    <div className={classes.messageContainer}>
                      <Avatar className={classes.avatar}>
                        <AndroidIcon />
                      </Avatar>
                      <Paper className={`${classes.messageContent} ${getAiMessageContentClass()}`}>
                        <Box display="flex" alignItems="center" style={{ gap: 8 }}>
                          <CircularProgress size={16} />
                          <Typography variant="body1">
                            {isAdvancedFeaturesEnabled ? 'Processing with advanced AI...' : 'Thinking...'}
                          </Typography>
                        </Box>
                      </Paper>
                    </div>
                  </Fade>
                )}
                <div ref={messagesEndRef} />
              </Box>

              <Box className={classes.inputContainer}>
                <TextField
                  className={classes.textField}
                  multiline
                  maxRows={4}
                  variant="outlined"
                  placeholder={isAdvancedFeaturesEnabled ? "Ask me anything... (Advanced mode active)" : "Type your message..."}
                  value={inputValue}
                  onChange={(e) => setInputValue(e.target.value)}
                  onKeyPress={handleKeyPress}
                  disabled={isLoading}
                />
                <Button
                  className={classes.sendButton}
                  variant="contained"
                  color="primary"
                  onClick={handleSendMessage}
                  disabled={isLoading || !inputValue.trim()}
                  startIcon={<SendIcon />}
                >
                  Send
                </Button>
              </Box>
            </Paper>
          </Grid>

          {/* Beta Analytics Panel - Only shown when feature flag is enabled */}
          {isBetaAnalyticsEnabled && (
            <Grid item xs={12} md={4}>
              <InfoCard title="📊 Chat Analytics" className={classes.analyticsCard}>
                <Box display="flex" flexDirection="column" style={{ gap: 16 }}>
                  <Box display="flex" justifyContent="space-between" alignItems="center">
                    <Typography variant="body2">Messages Sent:</Typography>
                    <Typography variant="h6">{messageCount}</Typography>
                  </Box>
                  <Box display="flex" justifyContent="space-between" alignItems="center">
                    <Typography variant="body2">Session Duration:</Typography>
                    <Typography variant="h6">5m 23s</Typography>
                  </Box>
                  <Box display="flex" justifyContent="space-between" alignItems="center">
                    <Typography variant="body2">Response Time:</Typography>
                    <Typography variant="h6">1.2s avg</Typography>
                  </Box>
                  <Divider style={{ backgroundColor: 'rgba(255,255,255,0.2)' }} />
                  <Box display="flex" alignItems="center" style={{ gap: 8 }}>
                    <TrendingUpIcon />
                    <Typography variant="caption">
                      Performance metrics available in beta
                    </Typography>
                  </Box>
                </Box>
              </InfoCard>

              {isAdvancedFeaturesEnabled && (
                <Card style={{ marginTop: 16 }}>
                  <CardContent>
                    <Typography variant="h6" gutterBottom>
                      🚀 Advanced Features
                    </Typography>
                    <Typography variant="body2" color="textSecondary">
                      • Enhanced context understanding
                      • Improved response quality
                      • Advanced conversation memory
                      • Smart topic detection
                    </Typography>
                  </CardContent>
                </Card>
              )}
            </Grid>
          )}
        </Grid>

        {/* Settings Dialog */}
        <Dialog open={settingsOpen} onClose={() => setSettingsOpen(false)} maxWidth="sm" fullWidth>
          <DialogTitle>Feature Flags Status</DialogTitle>
          <DialogContent>
            <Box display="flex" flexDirection="column" style={{ gap: 16 }}>
              <FormControlLabel
                control={<Switch checked={isAdvancedFeaturesEnabled} disabled />}
                label="Advanced Features"
              />
              <FormControlLabel
                control={<Switch checked={isExperimentalUIEnabled} disabled />}
                label="Experimental UI"
              />
              <FormControlLabel
                control={<Switch checked={isBetaAnalyticsEnabled} disabled />}
                label="Beta Analytics"
              />
              <FormControlLabel
                control={<Switch checked={isDarkModeEnhancementsEnabled} disabled />}
                label="Dark Mode Enhancements"
              />
              <Typography variant="caption" color="textSecondary">
                Feature flags are configured in app-config.yaml and cannot be changed at runtime.
              </Typography>
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setSettingsOpen(false)}>Close</Button>
          </DialogActions>
        </Dialog>
      </Content>
    </Page>
  );
};
