import { 
  Content, 
  Header, 
  Page, 
  InfoCard,
  WarningPanel,
  Progress,
} from '@backstage/core-components';
import { useApi, featureFlagsApiRef } from '@backstage/core-plugin-api';
import { 
  Grid, 
  Typography, 
  Card, 
  CardContent, 
  Chip,
  Switch,
  FormControlLabel,
  Box,
  Divider,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { 
  Extension as ExperimentalIcon, 
  Settings as SettingsIcon, 
  Visibility as VisibilityIcon,
  Palette as PaletteIcon,
} from '@material-ui/icons';

const useStyles = makeStyles(theme => ({
  card: {
    height: '100%',
  },
  featureCard: {
    marginBottom: theme.spacing(2),
    padding: theme.spacing(2),
  },
  featureHeader: {
    display: 'flex',
    alignItems: 'center',
    marginBottom: theme.spacing(1),
  },
  featureIcon: {
    marginRight: theme.spacing(1),
  },
  enabledChip: {
    backgroundColor: theme.palette.success.main,
    color: theme.palette.success.contrastText,
  },
  disabledChip: {
    backgroundColor: theme.palette.grey[400],
    color: theme.palette.grey[800],
  },
}));

export const ExampleFeatureFlagsPage = () => {
  const classes = useStyles();
  const featureFlagsApi = useApi(featureFlagsApiRef);

  // Check feature flags
  const isAdvancedFeaturesEnabled = featureFlagsApi.isActive('enable-advanced-features');
  const isExperimentalUIEnabled = featureFlagsApi.isActive('enable-experimental-ui');
  const isBetaAnalyticsEnabled = featureFlagsApi.isActive('enable-beta-analytics');
  const isDarkModeEnhancementsEnabled = featureFlagsApi.isActive('enable-dark-mode-enhancements');

  const features = [
    {
      name: 'Advanced Features',
      flag: 'enable-advanced-features',
      enabled: isAdvancedFeaturesEnabled,
      description: 'Enables advanced functionality including enhanced search and filtering capabilities.',
      icon: <SettingsIcon className={classes.featureIcon} />,
    },
    {
      name: 'Experimental UI',
      flag: 'enable-experimental-ui',
      enabled: isExperimentalUIEnabled,
      description: 'Activates experimental user interface components and layouts.',
      icon: <ExperimentalIcon className={classes.featureIcon} />,
    },
    {
      name: 'Beta Analytics',
      flag: 'enable-beta-analytics',
      enabled: isBetaAnalyticsEnabled,
      description: 'Provides access to beta analytics dashboard and reporting features.',
      icon: <VisibilityIcon className={classes.featureIcon} />,
    },
    {
      name: 'Dark Mode Enhancements',
      flag: 'enable-dark-mode-enhancements',
      enabled: isDarkModeEnhancementsEnabled,
      description: 'Enhanced dark mode with improved contrast and accessibility features.',
      icon: <PaletteIcon className={classes.featureIcon} />,
    },
  ];

  return (
    <Page themeId="tool">
      <Header title="Feature Flags Demo" subtitle="Manage and test feature flags in your Backstage application" />
      <Content>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <InfoCard title="Feature Flags Overview">
              <Typography variant="body1" paragraph>
                Feature flags allow you to enable or disable features in your Backstage application 
                without deploying new code. This is useful for A/B testing, gradual rollouts, and 
                managing experimental features.
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Configure feature flags in your app-config.yaml file under the 'featureFlags' section.
              </Typography>
            </InfoCard>
          </Grid>

          <Grid item xs={12}>
            <InfoCard title="Available Feature Flags" className={classes.card}>
              {features.map((feature) => (
                <Card key={feature.flag} className={classes.featureCard} variant="outlined">
                  <CardContent>
                    <Box className={classes.featureHeader}>
                      {feature.icon}
                      <Typography variant="h6" component="h3">
                        {feature.name}
                      </Typography>
                      <Box ml="auto">
                        <Chip
                          label={feature.enabled ? 'Enabled' : 'Disabled'}
                          className={feature.enabled ? classes.enabledChip : classes.disabledChip}
                          size="small"
                        />
                      </Box>
                    </Box>
                    <Typography variant="body2" color="textSecondary" paragraph>
                      {feature.description}
                    </Typography>
                    <Typography variant="caption" color="textSecondary">
                      Flag: <code>{feature.flag}</code>
                    </Typography>
                  </CardContent>
                </Card>
              ))}
            </InfoCard>
          </Grid>

          {/* Conditional content based on feature flags */}
          {isAdvancedFeaturesEnabled && (
            <Grid item xs={12} md={6}>
              <InfoCard title="🚀 Advanced Features">
                <Typography variant="body1">
                  This content is only visible when the 'enable-advanced-features' flag is active!
                </Typography>
                <Box mt={2}>
                  <Progress />
                  <Typography variant="caption" display="block" style={{ marginTop: 8 }}>
                    Advanced search indexing in progress...
                  </Typography>
                </Box>
              </InfoCard>
            </Grid>
          )}

          {isExperimentalUIEnabled && (
            <Grid item xs={12} md={6}>
              <InfoCard title="🧪 Experimental UI">
                <Typography variant="body1" color="primary">
                  Welcome to the experimental interface! This uses new design patterns.
                </Typography>
                <Box mt={2}>
                  <FormControlLabel
                    control={<Switch checked color="primary" />}
                    label="Enhanced animations"
                  />
                  <FormControlLabel
                    control={<Switch checked color="primary" />}
                    label="New navigation style"
                  />
                </Box>
              </InfoCard>
            </Grid>
          )}

          {isBetaAnalyticsEnabled && (
            <Grid item xs={12}>
              <InfoCard title="📊 Beta Analytics Dashboard">
                <Typography variant="body1" paragraph>
                  Beta analytics features are now available! Track user engagement and feature usage.
                </Typography>
                <Divider style={{ margin: '16px 0' }} />
                <Grid container spacing={2}>
                  <Grid item xs={4}>
                    <Typography variant="h4" color="primary">1,234</Typography>
                    <Typography variant="caption">Active Users</Typography>
                  </Grid>
                  <Grid item xs={4}>
                    <Typography variant="h4" color="secondary">567</Typography>
                    <Typography variant="caption">Feature Interactions</Typography>
                  </Grid>
                  <Grid item xs={4}>
                    <Typography variant="h4" style={{ color: '#ff9800' }}>89%</Typography>
                    <Typography variant="caption">User Satisfaction</Typography>
                  </Grid>
                </Grid>
              </InfoCard>
            </Grid>
          )}

          {isDarkModeEnhancementsEnabled && (
            <Grid item xs={12}>
              <WarningPanel 
                title="🌙 Dark Mode Enhancements Active"
                message="Enhanced dark mode is enabled with improved accessibility and contrast ratios."
              />
            </Grid>
          )}

          <Grid item xs={12}>
            <InfoCard title="Configuration Example">
              <Typography variant="body2" paragraph>
                To enable these feature flags, add the following to your <code>app-config.yaml</code>:
              </Typography>
              <Box component="pre" style={{ 
                backgroundColor: '#f5f5f5', 
                padding: '16px', 
                borderRadius: '4px',
                overflow: 'auto',
                fontSize: '0.875rem',
              }}>
{`featureFlags:
  enable-advanced-features: true
  enable-experimental-ui: false
  enable-beta-analytics: true
  enable-dark-mode-enhancements: false`}
              </Box>
            </InfoCard>
          </Grid>
        </Grid>
      </Content>
    </Page>
  );
};
