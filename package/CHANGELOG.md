# Changelog

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
