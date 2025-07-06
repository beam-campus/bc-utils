defmodule BCUtils.Telemetry do
  @moduledoc """
  Telemetry integration for BCUtils modules.

  This module provides helper functions to set up telemetry events 
  for monitoring and performance analysis within the BCUtils library.
  
  ## Usage
  
  ### Event Setup
  
  ```elixir
  :telemetry.attach(
    "my-event-handler",
    [:bc_utils, :module, :function, :start],
    &MyModule.handle_event/4,
    %{some: "metadata"}
  )
  ```
  
  ### Event Emission
  
  ```elixir
  def my_function(arg1, arg2) do
    start_time = System.monotonic_time()
    :telemetry.execute(
      [:bc_utils, :my_module, :my_function, :start],
      %{system_time: System.system_time(), arg1: arg1, arg2: arg2},
      %{start_time: start_time}
    )
    
    # Perform operation...
    
    :telemetry.execute(
      [:bc_utils, :my_module, :my_function, :stop],
      %{duration: System.monotonic_time() - start_time},
      %{arg1: arg1, arg2: arg2}
    )
  end
  ```
  
  ## Best Practices
  
  - Use descriptive event names
  - Tag events with function/module names
  - Include relevant metadata and measurements
  - Consider performance impact of telemetry hooks
  """

  @doc """
  Publishes a start event for telemetry.

  ## Parameters

  - `name` - The name (list) identifying the telemetry event
  - `metadata` - Metadata map for additional context
  """
  @spec start_event([atom()], map()) :: :ok
  def start_event(name, metadata \\ %{}) when is_list(name) and is_map(metadata) do
    :telemetry.execute(name ++ [:start], %{system_time: System.system_time()}, metadata)
  end

  @doc """
  Publishes a stop event for telemetry.

  ## Parameters

  - `name` - The name (list) identifying the telemetry event
  - `metadata` - Metadata map for additional context
  - `start_time` - The start time of the operation for duration calculation
  """
  @spec stop_event([atom()], map(), integer()) :: :ok
  def stop_event(name, metadata, start_time) when is_list(name) and is_map(metadata) do
    duration = System.monotonic_time() - start_time
    :telemetry.execute(name ++ [:stop], %{duration: duration}, metadata)
  end

  @doc """
  Attaches a telemetry handler.

  ## Parameters

  - `handler_id` - Unique identifier for the event handler
  - `event_name` - The name (list) of the telemetry event to handle
  - `handler_fn` - The function to call when the event occurs
  - `handler_config` - Additional handler configuration
  """
  @spec attach_handler(String.t(), [atom()], function(), map()) :: :ok | {:error, any()}
  def attach_handler(handler_id, event_name, handler_fn, handler_config \\ %{})
      when is_binary(handler_id) and is_list(event_name) and is_function(handler_fn, 4) and is_map(handler_config) do
    :telemetry.attach(handler_id, event_name, handler_fn, handler_config)
  end

  @doc """
  Detaches a telemetry handler.

  ## Parameters

  - `handler_id` - Unique identifier for the event handler
  """
  @spec detach_handler(String.t()) :: :ok | {:error, any()}
  def detach_handler(handler_id) when is_binary(handler_id) do
    :telemetry.detach(handler_id)
  end
end
