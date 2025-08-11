import React from 'react';
import {
  Content,
  Header,
  Page,
  InfoCard,
  Link,
} from '@backstage/core-components';
import { Grid, Typography, Box, Button } from '@material-ui/core';
import MoneyOffIcon from '@material-ui/icons/MoneyOff';
import CloudIcon from '@material-ui/icons/Cloud';
import TrendingUpIcon from '@material-ui/icons/TrendingUp';

export const CostInsightsPlaceholder: React.FC = () => {
  return (
    <Page themeId="tool">
      <Header title="Cost Insights" subtitle="Monitoreo y análisis de costos">
        <MoneyOffIcon />
      </Header>
      <Content>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <InfoCard title="💰 Cost Insights - IA-Ops Platform">
              <Typography variant="body1" paragraph>
                Bienvenido al módulo de Cost Insights de la plataforma IA-Ops.
                Aquí podrás monitorear y analizar los costos de tu infraestructura cloud.
              </Typography>
              
              <Box mt={2} mb={2}>
                <Typography variant="h6" gutterBottom>
                  🎯 Funcionalidades:
                </Typography>
                <ul>
                  <li>Seguimiento de costos multi-cloud (AWS, Azure, GCP, OCI)</li>
                  <li>Análisis de tendencias de gasto</li>
                  <li>Alertas de presupuesto</li>
                  <li>Optimización de recursos</li>
                </ul>
              </Box>

              <Box mt={3}>
                <Button
                  variant="contained"
                  color="primary"
                  startIcon={<CloudIcon />}
                  href="https://console.aws.amazon.com/billing/"
                  target="_blank"
                  style={{ marginRight: 8, marginBottom: 8 }}
                >
                  AWS Billing
                </Button>
                <Button
                  variant="contained"
                  color="primary"
                  startIcon={<CloudIcon />}
                  href="https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/overview"
                  target="_blank"
                  style={{ marginRight: 8, marginBottom: 8 }}
                >
                  Azure Cost Management
                </Button>
                <Button
                  variant="contained"
                  color="primary"
                  startIcon={<TrendingUpIcon />}
                  href="http://localhost:3001"
                  target="_blank"
                  style={{ marginBottom: 8 }}
                >
                  Grafana Dashboards
                </Button>
              </Box>
            </InfoCard>
          </Grid>

          <Grid item xs={12} md={4}>
            <InfoCard title="🔶 AWS">
              <Typography variant="h4" color="primary">
                $---.--
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Costo mensual estimado
              </Typography>
            </InfoCard>
          </Grid>

          <Grid item xs={12} md={4}>
            <InfoCard title="🔷 Azure">
              <Typography variant="h4" color="primary">
                $---.--
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Costo mensual estimado
              </Typography>
            </InfoCard>
          </Grid>

          <Grid item xs={12} md={4}>
            <InfoCard title="🟡 GCP">
              <Typography variant="h4" color="primary">
                $---.--
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Costo mensual estimado
              </Typography>
            </InfoCard>
          </Grid>

          <Grid item xs={12}>
            <InfoCard title="🚀 Estado del Sistema">
              <Typography variant="body1" paragraph>
                ✅ Configuración básica completada<br/>
                ⏳ Conectores de datos en desarrollo<br/>
                📊 Dashboards en configuración
              </Typography>
              
              <Box mt={2}>
                <Link to="/catalog?filters%5Bkind%5D=resource">
                  Ver recursos en el catálogo →
                </Link>
              </Box>
            </InfoCard>
          </Grid>
        </Grid>
      </Content>
    </Page>
  );
};
