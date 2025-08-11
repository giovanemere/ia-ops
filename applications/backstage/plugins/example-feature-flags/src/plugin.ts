import { createPlugin, createRoutableExtension } from '@backstage/core-plugin-api';

import { rootRouteRef } from './routes';

export const exampleFeatureFlagsPlugin = createPlugin({
  id: 'example-feature-flags',
  routes: {
    root: rootRouteRef,
  },
  featureFlags: [
    { name: 'enable-advanced-features' },
    { name: 'enable-experimental-ui' },
    { name: 'enable-beta-analytics' },
    { name: 'enable-dark-mode-enhancements' },
  ],
});

export const ExampleFeatureFlagsPage = exampleFeatureFlagsPlugin.provide(
  createRoutableExtension({
    name: 'ExampleFeatureFlagsPage',
    component: () =>
      import('./components/ExampleFeatureFlagsPage').then(m => m.ExampleFeatureFlagsPage),
    mountPoint: rootRouteRef,
  }),
);
