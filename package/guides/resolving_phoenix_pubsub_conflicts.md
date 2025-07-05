# Resolving Phoenix.PubSub Conflicts

## Problem

When multiple applications in the same BEAM VM attempt to start the same Phoenix.PubSub instance, you'll encounter an `:already_started` error. This commonly occurs when:

- One application includes another as a dependency
- Both applications try to start Phoenix.PubSub with the same name
- Multiple services share the same PubSub instance

## Solution: BCUtils.PubSubManager

`BCUtils.PubSubManager` provides utilities to gracefully handle Phoenix.PubSub conflicts by checking if an instance is already running before attempting to start it.

## Quick Start

### 1. Add Dependencies

```elixir
# In your mix.exs
defp deps do
  [
    {:bc_utils, "~> 0.6.0"},
    {:phoenix_pubsub, "~> 2.1"}
  ]
end
```

### 2. Update Your Supervision Tree

**Before** (causes conflicts):
```elixir
defmodule MyApp.Application do
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: :my_pubsub},  # Can cause :already_started error
      # other children...
    ]
    
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

**After** (conflict-free):
```elixir
defmodule MyApp.Application do
  def start(_type, _args) do
    children = [
      BCUtils.PubSubManager.maybe_child_spec(:my_pubsub),
      # other children...
    ]
    |> Enum.filter(& &1)  # Remove nil entries
    
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

## API Reference

### `maybe_child_spec(pubsub_name, opts \\ [])`

Returns a child spec for Phoenix.PubSub if not already started, otherwise `nil`.

**Parameters**:
- `pubsub_name` - Atom name for the PubSub instance, or `nil`
- `opts` - Additional options to pass to Phoenix.PubSub

**Returns**:
- `{Phoenix.PubSub, keyword()}` - Child spec if PubSub needs to be started
- `nil` - If PubSub is already running or pubsub_name is nil

**Example**:
```elixir
# In a supervision tree
children = [
  BCUtils.PubSubManager.maybe_child_spec(:my_app_pubsub),
  MyApp.SomeWorker,
  MyApp.AnotherWorker
]
|> Enum.filter(& &1)  # Remove nil entries

Supervisor.start_link(children, strategy: :one_for_one)
```

### `already_started?(pubsub_name)`

Checks if a PubSub instance is already running.

**Example**:
```elixir
if BCUtils.PubSubManager.already_started?(:my_pubsub) do
  IO.puts("PubSub is running")
else
  IO.puts("PubSub is not running")
end
```

### `ensure_started(pubsub_name, opts \\ [])`

Ensures a PubSub instance is available, starting it if necessary.

**Example**:
```elixir
case BCUtils.PubSubManager.ensure_started(:my_pubsub) do
  {:ok, pid} -> 
    IO.puts("PubSub ready: #{inspect(pid)}")
  {:error, reason} -> 
    IO.puts("Failed to start PubSub: #{inspect(reason)}")
end
```

### `health_check(pubsub_name)`

Validates that a PubSub instance is healthy and responding.

**Example**:
```elixir
case BCUtils.PubSubManager.health_check(:my_pubsub) do
  :ok -> 
    IO.puts("PubSub is healthy")
  {:error, :not_started} -> 
    IO.puts("PubSub is not running")
  {:error, :unresponsive} -> 
    IO.puts("PubSub is not responding")
end
```

### `list_running()`

Lists all currently running PubSub processes.

**Example**:
```elixir
running_pubsubs = BCUtils.PubSubManager.list_running()
IO.puts("Running PubSub instances: #{inspect(running_pubsubs)}")
```

## Common Use Cases

### Case 1: Application with Dependency

When your main application includes another application as a dependency, and both need PubSub:

```elixir
# Main Application
defmodule MainApp.Application do
  def start(_type, _args) do
    children = [
      BCUtils.PubSubManager.maybe_child_spec(:shared_pubsub),
      MainApp.SomeService
    ]
    |> Enum.filter(& &1)
    
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

# Dependency Application  
defmodule DepApp.Application do
  def start(_type, _args) do
    children = [
      BCUtils.PubSubManager.maybe_child_spec(:shared_pubsub),  # Same name!
      DepApp.SomeWorker
    ]
    |> Enum.filter(& &1)
    
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

**Result**: Only one PubSub instance is started, shared by both applications.

### Case 2: Microservices Sharing PubSub

When multiple services in the same VM need to share a PubSub instance:

```elixir
# Service A
defmodule ServiceA.Application do
  def start(_type, _args) do
    children = [
      BCUtils.PubSubManager.maybe_child_spec(:cluster_pubsub),
      ServiceA.MessageHandler
    ]
    |> Enum.filter(& &1)
    
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

# Service B
defmodule ServiceB.Application do  
  def start(_type, _args) do
    children = [
      BCUtils.PubSubManager.maybe_child_spec(:cluster_pubsub),  # Reuses existing
      ServiceB.EventProcessor
    ]
    |> Enum.filter(& &1)
    
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

### Case 3: Development vs Production

Use different PubSub configurations based on environment:

```elixir
defmodule MyApp.Application do
  def start(_type, _args) do
    pubsub_name = Application.get_env(:my_app, :pubsub_name, :my_app_pubsub)
    
    children = [
      BCUtils.PubSubManager.maybe_child_spec(pubsub_name),
      MyApp.Worker
    ]
    |> Enum.filter(& &1)
    
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

**Config**:
```elixir
# config/dev.exs
config :my_app, pubsub_name: :dev_pubsub

# config/prod.exs  
config :my_app, pubsub_name: :prod_pubsub

# config/test.exs
config :my_app, pubsub_name: :test_pubsub
```

## Advanced Usage

### Custom PubSub Options

Pass additional options to Phoenix.PubSub:

```elixir
children = [
  BCUtils.PubSubManager.maybe_child_spec(
    :my_pubsub,
    adapter: Phoenix.PubSub.PG2,
    pool_size: 10
  )
]
|> Enum.filter(& &1)
```

### Health Monitoring

Add PubSub health checks to your application monitoring:

```elixir
defmodule MyApp.HealthCheck do
  def check_pubsub do
    case BCUtils.PubSubManager.health_check(:my_pubsub) do
      :ok -> 
        %{status: :healthy, timestamp: DateTime.utc_now()}
      {:error, reason} -> 
        %{status: :unhealthy, reason: reason, timestamp: DateTime.utc_now()}
    end
  end
end
```

### Conditional Logic

Handle cases where PubSub availability affects application behavior:

```elixir
defmodule MyApp.Worker do
  def start_link(opts) do
    pubsub_available = BCUtils.PubSubManager.already_started?(:my_pubsub)
    
    if pubsub_available do
      GenServer.start_link(__MODULE__, {:with_pubsub, opts}, name: __MODULE__)
    else
      GenServer.start_link(__MODULE__, {:without_pubsub, opts}, name: __MODULE__)
    end
  end
  
  def init({:with_pubsub, opts}) do
    Phoenix.PubSub.subscribe(:my_pubsub, "important_events")
    {:ok, %{pubsub: true, opts: opts}}
  end
  
  def init({:without_pubsub, opts}) do
    {:ok, %{pubsub: false, opts: opts}}
  end
end
```

## Testing

### Unit Tests

Test PubSub manager functionality:

```elixir
defmodule BCUtils.PubSubManagerTest do
  use ExUnit.Case
  
  test "maybe_child_spec returns nil when PubSub already running" do
    # Start PubSub manually
    {:ok, _pid} = Phoenix.PubSub.start_link(name: :test_pubsub)
    
    # Should return nil since it's already running
    assert BCUtils.PubSubManager.maybe_child_spec(:test_pubsub) == nil
    
    # Cleanup
    GenServer.stop(:test_pubsub)
  end
  
  test "maybe_child_spec returns child spec when PubSub not running" do
    # Should return child spec
    child_spec = BCUtils.PubSubManager.maybe_child_spec(:not_running_pubsub)
    assert {Phoenix.PubSub, _opts} = child_spec
  end
end
```

### Integration Tests

Test application startup with shared PubSub:

```elixir
defmodule MyApp.IntegrationTest do
  use ExUnit.Case
  
  test "multiple applications can share PubSub" do
    # Start first application
    {:ok, _pid1} = MyApp.Application.start(:normal, [])
    
    # Start second application (should not conflict)
    {:ok, _pid2} = MyOtherApp.Application.start(:normal, [])
    
    # Verify both can use PubSub
    assert BCUtils.PubSubManager.already_started?(:shared_pubsub)
    assert :ok = BCUtils.PubSubManager.health_check(:shared_pubsub)
  end
end
```

## Error Handling

### When Phoenix.PubSub is Not Available

If `phoenix_pubsub` is not included in dependencies:

```elixir
# Returns nil gracefully
child_spec = BCUtils.PubSubManager.maybe_child_spec(:my_pubsub)
assert child_spec == nil

# Returns error
{:error, :phoenix_pubsub_not_available} = 
  BCUtils.PubSubManager.ensure_started(:my_pubsub)
```

### Recovery from Failed PubSub

Handle cases where PubSub fails after startup:

```elixir
defmodule MyApp.PubSubSupervisor do
  use Supervisor
  
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  def init(opts) do
    children = [
      BCUtils.PubSubManager.maybe_child_spec(:my_pubsub),
      {MyApp.PubSubMonitor, :my_pubsub}
    ]
    |> Enum.filter(& &1)
    
    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule MyApp.PubSubMonitor do
  use GenServer
  
  def start_link(pubsub_name) do
    GenServer.start_link(__MODULE__, pubsub_name)
  end
  
  def init(pubsub_name) do
    schedule_health_check()
    {:ok, %{pubsub_name: pubsub_name}}
  end
  
  def handle_info(:health_check, %{pubsub_name: name} = state) do
    case BCUtils.PubSubManager.health_check(name) do
      :ok -> 
        :ok
      {:error, _reason} -> 
        Logger.warning("PubSub #{name} unhealthy, attempting restart")
        BCUtils.PubSubManager.ensure_started(name)
    end
    
    schedule_health_check()
    {:noreply, state}
  end
  
  defp schedule_health_check do
    Process.send_after(self(), :health_check, 30_000)  # 30 seconds
  end
end
```

## Migration Guide

### From Manual Conflict Handling

If you previously handled PubSub conflicts manually:

**Before**:
```elixir
def start_pubsub(name) do
  case Phoenix.PubSub.start_link(name: name) do
    {:ok, pid} -> {:ok, pid}
    {:error, {:already_started, pid}} -> {:ok, pid}
    error -> error
  end
end
```

**After**:
```elixir
# In supervision tree
BCUtils.PubSubManager.maybe_child_spec(name)

# Or for manual start
BCUtils.PubSubManager.ensure_started(name)
```

### From Hard-coded PubSub

Replace direct Phoenix.PubSub references:

**Before**:
```elixir
children = [
  {Phoenix.PubSub, name: :my_pubsub},
  MyApp.Worker
]
```

**After**:
```elixir
children = [
  BCUtils.PubSubManager.maybe_child_spec(:my_pubsub),
  MyApp.Worker
]
|> Enum.filter(& &1)
```

## Best Practices

### 1. Consistent Naming

Use consistent PubSub names across your applications:

```elixir
# Good: Use application-specific names
:my_app_pubsub
:user_service_pubsub
:billing_pubsub

# Better: Use configurable names
Application.get_env(:my_app, :pubsub_name, :my_app_pubsub)
```

### 2. Resource Management

Monitor PubSub resource usage:

```elixir
defmodule MyApp.PubSubMetrics do
  def collect_metrics do
    pubsubs = BCUtils.PubSubManager.list_running()
    
    Enum.map(pubsubs, fn name ->
      %{
        name: name,
        status: BCUtils.PubSubManager.health_check(name),
        pid: Process.whereis(name),
        message_count: get_message_count(name)
      }
    end)
  end
  
  defp get_message_count(name) do
    case Process.whereis(name) do
      nil -> 0
      pid -> 
        {:message_queue_len, count} = Process.info(pid, :message_queue_len)
        count
    end
  end
end
```

### 3. Graceful Degradation

Design your application to work without PubSub when necessary:

```elixir
defmodule MyApp.EventBus do
  def broadcast(topic, message) do
    if BCUtils.PubSubManager.already_started?(:my_pubsub) do
      Phoenix.PubSub.broadcast(:my_pubsub, topic, message)
    else
      Logger.warning("PubSub not available, message not broadcast: #{inspect(message)}")
      :pubsub_unavailable
    end
  end
  
  def subscribe(topic) do
    if BCUtils.PubSubManager.already_started?(:my_pubsub) do
      Phoenix.PubSub.subscribe(:my_pubsub, topic)
    else
      Logger.warning("PubSub not available, cannot subscribe to: #{topic}")
      {:error, :pubsub_unavailable}
    end
  end
end
```

## Conclusion

`BCUtils.PubSubManager` provides a robust solution for handling Phoenix.PubSub conflicts in multi-application environments. By using the conditional startup pattern, you can:

- Eliminate `:already_started` errors
- Share PubSub instances efficiently
- Maintain clean, conflict-free supervision trees
- Add health monitoring and diagnostics
- Ensure graceful degradation when PubSub is unavailable

The utility is designed to be transparent to your application logic while providing the flexibility to handle complex deployment scenarios.
