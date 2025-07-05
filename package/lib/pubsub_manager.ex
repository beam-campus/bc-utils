defmodule BCUtils.PubSubManager do
  @moduledoc """
  Manages Phoenix.PubSub startup to avoid conflicts when multiple applications
  in the same VM try to start the same PubSub instance.
  
  This module provides utilities to:
  - Check if a PubSub instance is already running
  - Conditionally start PubSub only if needed
  - Provide graceful fallbacks for shared PubSub instances
  - Health check existing PubSub instances
  
  ## Usage
  
  In your supervision tree:
  
      children = [
        BCUtils.PubSubManager.maybe_child_spec(:my_pubsub),
        # other children...
      ]
      |> Enum.filter(& &1)  # Remove nil entries
  
  ## Dependencies
  
  This module requires `phoenix_pubsub` to be available at runtime.
  Add it to your `mix.exs`:
  
      {:phoenix_pubsub, "~> 2.1"}
  
  """
  require Logger

  @doc """
  Returns a child spec for Phoenix.PubSub if not already started, otherwise nil.
  
  This is the recommended way to use this module in supervision trees.
  
  ## Examples
  
      # Will start PubSub if not running
      BCUtils.PubSubManager.maybe_child_spec(:my_pubsub)
      
      # Will return nil if already running
      BCUtils.PubSubManager.maybe_child_spec(:my_pubsub)
      
      # Usage in supervision tree
      children = [
        BCUtils.PubSubManager.maybe_child_spec(:ex_esdb_pubsub),
        # other children...
      ]
      |> Enum.filter(& &1)  # Remove nil entries
      
  ## Parameters
  
  - `pubsub_name` - The atom name for the PubSub instance, or nil
  - `opts` - Additional options to pass to Phoenix.PubSub (default: [])
  
  ## Returns
  
  - `{Phoenix.PubSub, keyword()}` - Child spec if PubSub needs to be started
  - `nil` - If PubSub is already running or pubsub_name is nil
  """
  @spec maybe_child_spec(atom() | nil, keyword()) :: {module(), keyword()} | nil
  def maybe_child_spec(pubsub_name, opts \\ [])
  def maybe_child_spec(nil, _opts), do: nil
  
  def maybe_child_spec(pubsub_name, opts) when is_atom(pubsub_name) do
    if phoenix_pubsub_available?() do
      case already_started?(pubsub_name) do
        true ->
          Logger.info("Phoenix.PubSub #{pubsub_name} already started, reusing existing instance")
          nil
          
        false ->
          Logger.info("Starting Phoenix.PubSub #{pubsub_name}")
          pubsub_module = get_pubsub_module()
          {pubsub_module, [name: pubsub_name] ++ opts}
      end
    else
      Logger.warning("Phoenix.PubSub not available, skipping PubSub start for #{pubsub_name}")
      nil
    end
  end

  @doc """
  Checks if a PubSub instance with the given name is already running.
  
  This checks both:
  1. Process registry (via Process.whereis/1)
  2. Process health (via Process.alive?/1)
  
  ## Examples
  
      BCUtils.PubSubManager.already_started?(:my_pubsub)
      #=> true | false
      
  """
  @spec already_started?(atom()) :: boolean()
  def already_started?(pubsub_name) when is_atom(pubsub_name) do
    process_running?(pubsub_name)
  end

  @doc """
  Ensures a PubSub instance is available, starting it if necessary.
  
  This is useful when you need to guarantee PubSub availability outside
  of a supervision tree context.
  
  ## Examples
  
      BCUtils.PubSubManager.ensure_started(:my_pubsub)
      #=> {:ok, #PID<0.123.0>}
      
      BCUtils.PubSubManager.ensure_started(:my_pubsub, adapter: Phoenix.PubSub.PG2)
      #=> {:ok, #PID<0.123.0>}
      
  ## Returns
  
  - `{:ok, pid}` if PubSub is running (existing or newly started)
  - `{:error, reason}` if unable to start or find PubSub
  - `{:error, :phoenix_pubsub_not_available}` if Phoenix.PubSub is not loaded
  """
  @spec ensure_started(atom(), keyword()) :: {:ok, pid()} | {:error, term()}
  def ensure_started(pubsub_name, opts \\ []) when is_atom(pubsub_name) do
    if phoenix_pubsub_available?() do
      case Process.whereis(pubsub_name) do
        nil ->
          # Not running, try to start it
          pubsub_module = get_pubsub_module()
          case pubsub_module.start_link([name: pubsub_name] ++ opts) do
            {:ok, pid} ->
              Logger.info("Started Phoenix.PubSub #{pubsub_name}")
              {:ok, pid}
            
            {:error, {:already_started, pid}} ->
              Logger.info("Phoenix.PubSub #{pubsub_name} was started by another process")
              {:ok, pid}
            
            {:error, reason} = error ->
              Logger.error("Failed to start Phoenix.PubSub #{pubsub_name}: #{inspect(reason)}")
              error
          end
        
        pid when is_pid(pid) ->
          Logger.debug("Phoenix.PubSub #{pubsub_name} already running")
          {:ok, pid}
      end
    else
      {:error, :phoenix_pubsub_not_available}
    end
  end

  @doc """
  Validates that a PubSub instance is healthy and responding.
  
  This performs a basic health check by attempting to subscribe and
  unsubscribe from a test topic.
  
  ## Examples
  
      BCUtils.PubSubManager.health_check(:my_pubsub)
      #=> :ok | {:error, :not_started} | {:error, :unresponsive}
      
  """
  @spec health_check(atom()) :: :ok | {:error, term()}
  def health_check(pubsub_name) when is_atom(pubsub_name) do
    if phoenix_pubsub_available?() do
      case Process.whereis(pubsub_name) do
        nil ->
          {:error, :not_started}
        
        pid when is_pid(pid) ->
          if Process.alive?(pid) do
            # Try a basic operation to ensure it's responsive
            try do
              pubsub_module = get_pubsub_module()
              pubsub_module.subscribe(pubsub_name, "health_check_topic")
              pubsub_module.unsubscribe(pubsub_name, "health_check_topic")
              :ok
            rescue
              error ->
                Logger.warning("PubSub health check failed: #{inspect(error)}")
                {:error, :unresponsive}
            end
          else
            {:error, :dead_process}
          end
      end
    else
      {:error, :phoenix_pubsub_not_available}
    end
  end

  @doc """
  Lists all currently running PubSub processes.
  
  This scans the process registry for processes that appear to be
  Phoenix.PubSub instances.
  
  ## Examples
  
      BCUtils.PubSubManager.list_running()
      #=> [:my_pubsub, :another_pubsub]
      
  """
  @spec list_running() :: [atom()]
  def list_running do
    if phoenix_pubsub_available?() do
      Process.registered()
      |> Enum.filter(&pubsub_process?/1)
    else
      []
    end
  end

  ## Private Functions

  defp process_running?(name) do
    case Process.whereis(name) do
      nil -> false
      pid when is_pid(pid) -> Process.alive?(pid)
    end
  end

  defp phoenix_pubsub_available? do
    Code.ensure_loaded?(Phoenix.PubSub)
  end

  defp get_pubsub_module do
    # This allows for future flexibility if Phoenix.PubSub API changes
    Phoenix.PubSub
  end

  # Basic heuristic to identify PubSub processes
  # This is imperfect but works for most common cases
  defp pubsub_process?(name) when is_atom(name) do
    name_str = Atom.to_string(name)
    String.contains?(name_str, "pubsub") or String.contains?(name_str, "PubSub")
  end
end
