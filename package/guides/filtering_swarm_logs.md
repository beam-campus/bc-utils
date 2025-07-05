# Filtering Swarm Logs

## Problem

Swarm generates a lot of informational logging that can clutter your application logs, making it difficult to see important application messages. Common Swarm log noise includes:

- Node registration/unregistration messages
- Ring rebalancing information
- Distribution strategy updates
- Tracker synchronization messages

## Solution: Multi-Layer Filtering

We implement multiple layers of filtering to ensure only Swarm error messages are shown:

### 1. Application-Level Configuration

Set Swarm's own log level to `:error`:

```elixir
# config/config.exs or config/dev.exs
config :swarm,
  log_level: :error,
  logger: true
```

### 2. Compile-Time Purging

Remove lower-level messages at compile time for specific Swarm modules:

```elixir
# config/config.exs
config :logger,
  compile_time_purge_matching: [
    # Swarm modules - only show errors
    [module: Swarm.Distribution.Ring, level_lower_than: :error],
    [module: Swarm.Distribution.Strategy, level_lower_than: :error],
    [module: Swarm.Registry, level_lower_than: :error],
    [module: Swarm.Tracker, level_lower_than: :error],
    [module: Swarm.Distribution.StaticQuorumRing, level_lower_than: :error],
    [module: Swarm.Distribution.Handler, level_lower_than: :error],
    [module: Swarm.IntervalTreeClock, level_lower_than: :error],
    [module: Swarm, level_lower_than: :error]
  ]
```

### 3. Runtime Filtering with BCUtils.LoggerFilters

Use the custom logger filter from bc_utils for dynamic filtering:

```elixir
# config/dev.exs
config :logger, :console,
  format: "$time ($metadata) [$level] $message\\n",
  metadata: [:mfa],
  level: :info,
  # Filter out Swarm noise using BCUtils filter
  filters: [swarm_noise: {BCUtils.LoggerFilters, :filter_swarm}]
```

## BCUtils.LoggerFilters

The `BCUtils.LoggerFilters` module provides several pre-configured filters:

### `filter_swarm/1`

Filters out all Swarm messages except errors:

```elixir
config :logger, :console,
  filters: [swarm_filter: {BCUtils.LoggerFilters, :filter_swarm}]
```

### `filter_libcluster/1`

Similar filtering for LibCluster messages:

```elixir
config :logger, :console,
  filters: [libcluster_filter: {BCUtils.LoggerFilters, :filter_libcluster}]
```

### `filter_verbose_libs/1`

Combined filter for both Swarm and LibCluster:

```elixir
config :logger, :console,
  filters: [verbose_libs: {BCUtils.LoggerFilters, :filter_verbose_libs}]
```

### `errors_and_warnings_only/1`

More aggressive filtering - only allows errors and warnings from noisy libraries:

```elixir
config :logger, :console,
  filters: [errors_only: {BCUtils.LoggerFilters, :errors_and_warnings_only}]
```

## Complete Example Configuration

### ExESDB Server (config/dev.exs)

```elixir
import Config

# Swarm configuration - errors only
config :swarm,
  log_level: :error,
  logger: true

# Logger console configuration with Swarm filter
config :logger, :console,
  format: "$time ($metadata) [$level] $message\\n",
  metadata: [:mfa],
  level: :info,
  filters: [swarm_noise: {BCUtils.LoggerFilters, :filter_swarm}]

# Additional logger settings
config :logger,
  level: :info,
  backends: [:console],
  handle_otp_reports: true,
  handle_sasl_reports: false
```

### ExESDB Gateway (config/dev.exs)

```elixir
import Config

# Swarm configuration - errors only  
config :swarm,
  log_level: :error,
  logger: true

# Logger console configuration with Swarm filter
config :logger, :console,
  format: "$time ($metadata) [$level] $message\\n",
  metadata: [:mfa],
  level: :info,
  filters: [swarm_noise: {BCUtils.LoggerFilters, :filter_swarm}]
```

### Both Applications (config/config.exs)

```elixir
import Config

# Compile-time purging for Swarm modules
config :logger,
  compile_time_purge_matching: [
    [module: Swarm.Distribution.Ring, level_lower_than: :error],
    [module: Swarm.Distribution.Strategy, level_lower_than: :error],
    [module: Swarm.Registry, level_lower_than: :error],
    [module: Swarm.Tracker, level_lower_than: :error],
    [module: Swarm.Distribution.StaticQuorumRing, level_lower_than: :error],
    [module: Swarm.Distribution.Handler, level_lower_than: :error],
    [module: Swarm.IntervalTreeClock, level_lower_than: :error],
    [module: Swarm, level_lower_than: :error]
  ]
```

## Verification

To verify the configuration is working:

1. **Start your application** and observe the logs
2. **Look for Swarm messages** - you should only see error-level messages
3. **Test Swarm functionality** - workers should still register/unregister properly
4. **Check log volume** - overall log noise should be significantly reduced

### Testing Swarm Errors

To verify error messages still come through, you can temporarily create a Swarm error:

```elixir
# This should still show up in logs as an error
Swarm.register_name(:invalid_name, :invalid_pid)
```

## Troubleshooting

### Still Seeing Swarm Messages?

1. **Check configuration order** - Make sure logger filters are applied after other logger config
2. **Verify bc_utils version** - Ensure you're using a version that includes `BCUtils.LoggerFilters`
3. **Check for multiple logger configurations** - Some configs might override others

### Missing Important Swarm Information?

If you need to see more Swarm information temporarily:

```elixir
# Temporarily increase Swarm log level
config :swarm,
  log_level: :info  # or :debug for very verbose

# Or remove the filter temporarily
config :logger, :console,
  # filters: [swarm_noise: {BCUtils.LoggerFilters, :filter_swarm}]  # commented out
```

### Performance Impact

The logger filters have minimal performance impact:
- **Compile-time purging**: No runtime cost
- **Runtime filters**: Very small per-message overhead
- **Swarm config**: No additional overhead

## Environment-Specific Configuration

### Development
- Use runtime filters for flexibility
- Allow some Swarm warnings if debugging clustering

### Production
- Use compile-time purging for best performance
- Strict error-only filtering
- Consider structured logging for better analysis

### Testing
- May want to disable filters to ensure proper Swarm behavior
- Use debug level for integration tests

## Summary

This multi-layer approach ensures:
- ✅ **No Swarm noise** in normal operation
- ✅ **Important errors** still visible
- ✅ **Minimal performance impact**
- ✅ **Easy to adjust** per environment
- ✅ **Reusable** across BEAM Campus projects

The configuration significantly improves log readability while maintaining visibility into actual problems.
