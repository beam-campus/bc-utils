# Changelog

## v0.10.0 - 2025-07-05

### Enhanced

#### Improved Logging Filter Documentation and Usage
- **Enhanced Examples**: Updated filtering examples for better ExESDB integration patterns
- **Multi-Layer Filtering**: Documented comprehensive filtering strategies combining application-level config with runtime filters
- **Production Patterns**: Added production-ready configurations for distributed applications using Swarm and LibCluster
- **ExESDB Integration**: Documented how BCUtils.LoggerFilters integrates with ExESDB's consensus layer logging

### Technical Improvements
- **Better Module Detection**: Enhanced `is_swarm_module?/1` and `is_libcluster_module?/1` for more reliable filtering
- **Metadata Handling**: Improved handling of log events without MFA metadata
- **Performance**: Optimized filter functions for minimal runtime overhead

### Documentation
- **Updated Guide**: Enhanced "Filtering Swarm Logs" guide with ExESDB-specific patterns
- **Usage Examples**: Added comprehensive examples for distributed event store applications
- **Best Practices**: Documented environment-specific filtering strategies (dev/test/prod)

### Benefits for ExESDB Users
- **Cleaner Logs**: Significant reduction in Swarm and LibCluster noise during cluster formation
- **Better Debugging**: Focus on application logic instead of clustering protocol chatter
- **Production Ready**: Minimal logging overhead while preserving error visibility
- **Consensus Layer Ready**: Works seamlessly with Ra/Khepri-based applications like ExESDB

### Usage with ExESDB

```elixir
# In ExESDB config - BCUtils filters work alongside ExESDB's own filters
config :logger, :console,
  level: :info,
  filters: [
    # BCUtils filters for clustering libraries
    swarm_noise: {BCUtils.LoggerFilters, :filter_swarm},
    libcluster_noise: {BCUtils.LoggerFilters, :filter_libcluster},
    # ExESDB's own filters for consensus libraries (defined in ExESDB.LoggerFilters)
    ra_noise: {ExESDB.LoggerFilters, :filter_ra},
    khepri_noise: {ExESDB.LoggerFilters, :filter_khepri}
  ]
```

## v0.9.0 - 2025-07-05

### Fixed

#### Enhanced Swarm Logging Filters
- **BCUtils.LoggerFilters**: Fixed `filter_swarm/1` to properly handle `Swarm.Logger` module
- Added explicit handling for `Swarm.Logger` in addition to other Swarm modules
- Updated compile-time purging configurations to include `Swarm.Logger`
- Resolves issue where Swarm info/debug/warning messages were still appearing despite filtering

### Technical Details
- The `Swarm.Logger` module was generating logs that weren't caught by the original `Elixir.Swarm*` pattern matching
- Added specific check: `module == Swarm.Logger` to the `is_swarm_module?/1` function
- Updated both ExESDB Server and Gateway configurations to include `[module: Swarm.Logger, level_lower_than: :error]`

## v0.8.0 - 2025-07-05

### Added

#### Phoenix.PubSub Conflict Resolution
- **BCUtils.PubSubManager**: New module to handle Phoenix.PubSub conflicts when multiple applications try to start the same PubSub instance
- Added `maybe_child_spec/2` for conditional PubSub startup in supervision trees
- Added `already_started?/1`, `ensure_started/2`, `health_check/1`, and `list_running/0` utilities
- Added `phoenix_pubsub ~> 2.1` as optional dependency
- **Documentation**: New guide "Resolving Phoenix.PubSub Conflicts" with comprehensive usage examples

#### Swarm Logging Noise Reduction
- **BCUtils.LoggerFilters**: New module with pre-configured filters to reduce logging noise from verbose libraries
- Added `filter_swarm/1` to filter out non-error Swarm messages
- Added `filter_libcluster/1` for LibCluster noise reduction
- Added `filter_verbose_libs/1` as combined filter for multiple noisy libraries
- Added `errors_and_warnings_only/1` for aggressive filtering
- **Documentation**: New guide "Filtering Swarm Logs" with multi-layer filtering strategies

### Benefits
- **Eliminates Conflicts**: No more `:already_started` errors when multiple apps use Phoenix.PubSub
- **Resource Efficient**: Single PubSub instance shared across applications
- **Cleaner Logs**: Significant reduction in Swarm logging noise while preserving error visibility
- **Production Ready**: Minimal performance impact with comprehensive error handling
- **Reusable**: Available to all BEAM Campus projects via bc_utils

### Usage Examples

#### PubSub Conflict Resolution
```elixir
# In supervision tree - automatically handles conflicts
children = [
  BCUtils.PubSubManager.maybe_child_spec(:my_pubsub),
  # other children...
]
|> Enum.filter(& &1)  # Remove nil entries
```

#### Swarm Log Filtering
```elixir
# In config/dev.exs - only show Swarm errors
config :logger, :console,
  filters: [swarm_noise: {BCUtils.LoggerFilters, :filter_swarm}]
```

## v0.1.0

- Initial release
- introduced BCUtils.Banner
