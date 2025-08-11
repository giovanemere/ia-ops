import {
  Page,
  Header,
  Content,
  ContentHeader,
  SupportButton,
} from '@backstage/core-components';
import { 
  Grid, 
  Card, 
  CardContent, 
  Typography, 
  Box,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  Chip,
  Button,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import GitHubIcon from '@material-ui/icons/GitHub';
import PlayArrowIcon from '@material-ui/icons/PlayArrow';
import CheckCircleIcon from '@material-ui/icons/CheckCircle';

const useStyles = makeStyles((theme) => ({
  root: {
    height: '100%',
  },
  card: {
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
  },
  cardContent: {
    flexGrow: 1,
  },
  repoCard: {
    marginBottom: theme.spacing(2),
    border: `1px solid ${theme.palette.divider}`,
  },
  repoHeader: {
    display: 'flex',
    alignItems: 'center',
    marginBottom: theme.spacing(2),
  },
  repoIcon: {
    marginRight: theme.spacing(1),
  },
  statusChip: {
    marginLeft: theme.spacing(1),
  },
  workflowItem: {
    borderBottom: `1px solid ${theme.palette.divider}`,
    '&:last-child': {
      borderBottom: 'none',
    },
  },
  noWorkflows: {
    textAlign: 'center',
    padding: theme.spacing(4),
    color: theme.palette.text.secondary,
  },
  setupButton: {
    marginTop: theme.spacing(2),
  },
}));

interface Repository {
  owner: string;
  repo: string;
  url: string;
  description?: string;
}

const repositories: Repository[] = [
  {
    owner: 'giovanemere',
    repo: 'poc-billpay-back',
    url: 'https://github.com/giovanemere/poc-billpay-back',
    description: 'Backend service for POC BillPay application',
  },
  {
    owner: 'giovanemere',
    repo: 'poc-billpay-front-a',
    url: 'https://github.com/giovanemere/poc-billpay-front-a',
    description: 'Frontend A for POC BillPay application',
  },
  {
    owner: 'giovanemere',
    repo: 'poc-billpay-front-b',
    url: 'https://github.com/giovanemere/poc-billpay-front-b',
    description: 'Frontend B for POC BillPay application',
  },
  {
    owner: 'giovanemere',
    repo: 'poc-billpay-front-feature-flags',
    url: 'https://github.com/giovanemere/poc-billpay-front-feature-flags',
    description: 'Feature flags frontend for POC BillPay',
  },
  {
    owner: 'giovanemere',
    repo: 'poc-icbs',
    url: 'https://github.com/giovanemere/poc-icbs',
    description: 'POC ICBS integration service',
  },
];

export const GitHubActionsPage = () => {
  const classes = useStyles();

  const handleSetupWorkflow = (repo: Repository) => {
    window.open(`${repo.url}/actions/new`, '_blank');
  };

  const handleViewRepo = (repo: Repository) => {
    window.open(repo.url, '_blank');
  };

  return (
    <Page themeId="tool">
      <Header title="GitHub Actions" subtitle="CI/CD Workflows and Build Status">
        <SupportButton>
          Monitor and manage your GitHub Actions workflows across all repositories.
        </SupportButton>
      </Header>
      <Content className={classes.root}>
        <ContentHeader title="Repository Workflows">
          <Button
            variant="contained"
            color="primary"
            startIcon={<GitHubIcon />}
            onClick={() => window.open('https://github.com/giovanemere', '_blank')}
          >
            View All Repositories
          </Button>
        </ContentHeader>

        <Grid container spacing={3}>
          {repositories.map((repo) => (
            <Grid item xs={12} md={6} lg={4} key={`${repo.owner}/${repo.repo}`}>
              <Card className={classes.repoCard}>
                <CardContent className={classes.cardContent}>
                  <Box className={classes.repoHeader}>
                    <GitHubIcon className={classes.repoIcon} />
                    <Typography variant="h6" component="h2">
                      {repo.repo}
                    </Typography>
                    <Chip
                      label="No Workflows"
                      size="small"
                      className={classes.statusChip}
                      color="default"
                    />
                  </Box>

                  <Typography variant="body2" color="textSecondary" gutterBottom>
                    {repo.description}
                  </Typography>

                  <Box 
                    style={{ 
                      marginTop: 16, 
                      marginBottom: 16, 
                      padding: 12, 
                      backgroundColor: '#e3f2fd', 
                      borderRadius: 4,
                      border: '1px solid #2196f3'
                    }}
                  >
                    <Typography variant="body2" style={{ color: '#1976d2' }}>
                      No GitHub Actions workflows found in this repository.
                    </Typography>
                  </Box>

                  <Box className={classes.noWorkflows}>
                    <PlayArrowIcon style={{ fontSize: 48, color: '#ccc', marginBottom: 8 }} />
                    <Typography variant="body2" gutterBottom>
                      Set up your first workflow to see CI/CD status here.
                    </Typography>
                    <Button
                      variant="outlined"
                      size="small"
                      startIcon={<PlayArrowIcon />}
                      onClick={() => handleSetupWorkflow(repo)}
                      className={classes.setupButton}
                    >
                      Setup Workflow
                    </Button>
                  </Box>

                  <Box style={{ marginTop: 16 }}>
                    <Button
                      variant="text"
                      size="small"
                      startIcon={<GitHubIcon />}
                      onClick={() => handleViewRepo(repo)}
                      fullWidth
                    >
                      View Repository
                    </Button>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>

        <Box style={{ marginTop: 32 }}>
          <Box 
            style={{ 
              padding: 24, 
              backgroundColor: '#e3f2fd', 
              borderRadius: 4,
              border: '1px solid #2196f3'
            }}
          >
            <Typography variant="h6" gutterBottom style={{ color: '#1976d2' }}>
              Getting Started with GitHub Actions
            </Typography>
            <Typography variant="body2" paragraph style={{ color: '#1976d2' }}>
              GitHub Actions help you automate your software development workflows. Here's how to get started:
            </Typography>
            <List dense>
              <ListItem>
                <ListItemIcon>
                  <CheckCircleIcon color="primary" />
                </ListItemIcon>
                <ListItemText 
                  primary="Create a .github/workflows directory in your repository"
                  secondary="This is where your workflow files will live"
                />
              </ListItem>
              <ListItem>
                <ListItemIcon>
                  <CheckCircleIcon color="primary" />
                </ListItemIcon>
                <ListItemText 
                  primary="Add a YAML workflow file"
                  secondary="Define your CI/CD pipeline with jobs and steps"
                />
              </ListItem>
              <ListItem>
                <ListItemIcon>
                  <CheckCircleIcon color="primary" />
                </ListItemIcon>
                <ListItemText 
                  primary="Commit and push your changes"
                  secondary="GitHub will automatically run your workflows"
                />
              </ListItem>
            </List>
            <Button
              variant="contained"
              color="primary"
              style={{ marginTop: 16 }}
              onClick={() => window.open('https://docs.github.com/en/actions/quickstart', '_blank')}
            >
              Learn More About GitHub Actions
            </Button>
          </Box>
        </Box>
      </Content>
    </Page>
  );
};

export default GitHubActionsPage;
