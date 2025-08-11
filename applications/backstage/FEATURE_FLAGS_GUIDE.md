# Feature Flags Implementation Guide

## Overview

Feature flags in Backstage allow you to enable or disable features without deploying new code. This is useful for:

- **A/B Testing**: Test different versions of features with different user groups
- **Gradual Rollouts**: Slowly roll out new features to minimize risk
- **Experimental Features**: Test new functionality before full release
- **Emergency Switches**: Quickly disable problematic features

## Implementation

### 1. Plugin Structure

We've created a complete feature flags plugin at:
```
plugins/example-feature-flags/
├── package.json
├── src/
│   ├── index.ts
│   ├── plugin.ts
│   ├── routes.ts
│   └── components/
│       └── ExampleFeatureFlagsPage/
│           ├── index.ts
│           └── ExampleFeatureFlagsPage.tsx
```

### 2. Plugin Definition

The plugin is defined in `plugin.ts` with feature flags:

```typescript
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
```

### 3. Using Feature Flags in Components

```typescript
import { useApi, featureFlagsApiRef } from '@backstage/core-plugin-api';

export const MyComponent = () => {
  const featureFlagsApi = useApi(featureFlagsApiRef);
  
  // Check if a feature flag is active
  const isAdvancedFeaturesEnabled = featureFlagsApi.isActive('enable-advanced-features');
  
  return (
    <div>
      {isAdvancedFeaturesEnabled && (
        <AdvancedFeatureComponent />
      )}
    </div>
  );
};
```

## Configuration

### app-config.yaml

Add feature flags to your configuration:

```yaml
featureFlags:
  enable-advanced-features: true
  enable-experimental-ui: false
  enable-beta-analytics: true
  enable-dark-mode-enhancements: false
```

### Environment-based Configuration

You can also use environment variables:

```yaml
featureFlags:
  enable-advanced-features: ${ENABLE_ADVANCED_FEATURES:-false}
  enable-experimental-ui: ${ENABLE_EXPERIMENTAL_UI:-false}
```

## Available Feature Flags

### 1. `enable-advanced-features`
- **Purpose**: Enables advanced functionality across the application
- **Impact**: 
  - Enhanced search capabilities
  - Advanced filtering options
  - Improved AI responses
  - Additional configuration options

### 2. `enable-experimental-ui`
- **Purpose**: Activates experimental user interface components
- **Impact**:
  - New animations and transitions
  - Enhanced visual effects
  - Experimental layout components
  - Beta design patterns

### 3. `enable-beta-analytics`
- **Purpose**: Provides access to beta analytics features
- **Impact**:
  - Analytics dashboard
  - Usage metrics
  - Performance monitoring
  - User behavior tracking

### 4. `enable-dark-mode-enhancements`
- **Purpose**: Enhanced dark mode with improved accessibility
- **Impact**:
  - Better contrast ratios
  - Improved readability
  - Enhanced color schemes
  - Accessibility improvements

## Testing Feature Flags

### 1. Manual Testing

1. Start your Backstage application:
   ```bash
   yarn start
   ```

2. Navigate to the Feature Flags page:
   ```
   http://localhost:3002/feature-flags
   ```

3. Modify `app-config.yaml` to change feature flag values

4. Restart the application to see changes

### 2. Automated Testing

Create tests for your feature flag logic:

```typescript
import { TestApiProvider } from '@backstage/test-utils';
import { featureFlagsApiRef } from '@backstage/core-plugin-api';

const mockFeatureFlagsApi = {
  isActive: jest.fn(),
};

// Test with feature enabled
mockFeatureFlagsApi.isActive.mockReturnValue(true);

const wrapper = ({ children }) => (
  <TestApiProvider apis={[[featureFlagsApiRef, mockFeatureFlagsApi]]}>
    {children}
  </TestApiProvider>
);
```

## Best Practices

### 1. Naming Conventions
- Use descriptive names: `enable-advanced-search` instead of `flag1`
- Use kebab-case: `enable-beta-analytics`
- Include the action: `enable-`, `disable-`, `show-`, `hide-`

### 2. Documentation
- Document each feature flag's purpose
- Include impact assessment
- Specify rollback procedures

### 3. Cleanup
- Remove unused feature flags regularly
- Set removal dates for temporary flags
- Monitor flag usage

### 4. Testing
- Test both enabled and disabled states
- Include feature flags in integration tests
- Test flag combinations

## Advanced Usage

### 1. Conditional Plugin Loading

```typescript
const app = createApp({
  plugins: [
    // Always loaded plugins
    catalogPlugin,
    
    // Conditionally loaded plugins
    ...(featureFlagsApi.isActive('enable-advanced-features') 
      ? [advancedFeaturesPlugin] 
      : []),
  ],
});
```

### 2. Feature Flag Middleware

```typescript
export const featureFlagMiddleware = (flagName: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (featureFlagsApi.isActive(flagName)) {
      next();
    } else {
      res.status(404).json({ error: 'Feature not available' });
    }
  };
};
```

### 3. User-specific Feature Flags

```typescript
const isFeatureEnabledForUser = (flagName: string, userId: string) => {
  const globalFlag = featureFlagsApi.isActive(flagName);
  const userFlag = getUserSpecificFlag(userId, flagName);
  return globalFlag && userFlag;
};
```

## Troubleshooting

### Common Issues

1. **Feature flag not working**
   - Check app-config.yaml syntax
   - Verify flag name spelling
   - Restart the application

2. **Plugin not loading**
   - Check plugin registration in App.tsx
   - Verify package.json dependencies
   - Check console for errors

3. **Navigation not showing**
   - Verify Root.tsx integration
   - Check route configuration
   - Ensure proper imports

### Debug Mode

Enable debug logging for feature flags:

```yaml
backend:
  debug: true
  
app:
  debug: true
```

## Migration Guide

### From Manual Toggles

If you're currently using manual toggles:

1. Identify existing toggle points
2. Replace with feature flag checks
3. Add flags to app-config.yaml
4. Test thoroughly

### Adding to Existing Plugins

To add feature flags to existing plugins:

1. Update plugin definition:
   ```typescript
   export const myPlugin = createPlugin({
     id: 'my-plugin',
     featureFlags: [
       { name: 'enable-my-feature' },
     ],
   });
   ```

2. Use in components:
   ```typescript
   const isEnabled = featureFlagsApi.isActive('enable-my-feature');
   ```

## Monitoring and Analytics

### Usage Tracking

Track feature flag usage:

```typescript
const trackFeatureUsage = (flagName: string, enabled: boolean) => {
  analytics.track('feature_flag_used', {
    flag: flagName,
    enabled,
    timestamp: new Date().toISOString(),
  });
};
```

### Performance Impact

Monitor performance impact of feature flags:

```typescript
const measureFeaturePerformance = (flagName: string, fn: () => void) => {
  const start = performance.now();
  fn();
  const end = performance.now();
  
  analytics.track('feature_performance', {
    flag: flagName,
    duration: end - start,
  });
};
```

## Security Considerations

1. **Sensitive Features**: Don't expose sensitive feature flags in frontend
2. **Access Control**: Implement proper access controls for flag management
3. **Audit Logging**: Log feature flag changes
4. **Validation**: Validate flag values and types

## Resources

- [Backstage Feature Flags Documentation](https://backstage.io/docs/features/feature-flags)
- [Feature Flag Best Practices](https://martinfowler.com/articles/feature-toggles.html)
- [Testing with Feature Flags](https://backstage.io/docs/features/feature-flags/testing)

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review Backstage documentation
3. Check GitHub issues
4. Contact the development team
