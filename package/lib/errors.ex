defmodule BCUtils.Errors do
  @moduledoc """
  Standardized error handling for BCUtils modules.
  
  This module provides common error types and utilities for consistent
  error handling across the BCUtils library.
  
  ## Error Types
  
  - `BCUtils.Errors.InvalidInput` - For invalid input parameters
  - `BCUtils.Errors.ConfigurationError` - For configuration-related errors
  - `BCUtils.Errors.TerminalError` - For terminal/display-related errors
  - `BCUtils.Errors.ProcessError` - For process/system-related errors
  
  ## Usage
  
  ```elixir
  # Define custom errors
  defmodule MyModule do
    alias BCUtils.Errors
    
    def my_function(invalid_param) when not is_binary(invalid_param) do
      {:error, Errors.InvalidInput.new("Parameter must be a string", %{received: invalid_param})}
    end
  end
  
  # Handle errors consistently
  case MyModule.my_function(123) do
    {:ok, result} -> result
    {:error, %Errors.InvalidInput{} = error} -> 
      Logger.error("Invalid input: #{Errors.message(error)}")
    {:error, error} -> 
      Logger.error("Unexpected error: #{inspect(error)}")
  end
  ```
  """
  
  @type error_context :: map()
  @type error_reason :: String.t()
  
  defmodule InvalidInput do
    @moduledoc "Error for invalid input parameters"
    
    defexception [:message, :context, :received_value]
    
    @type t :: %__MODULE__{
      message: String.t(),
      context: map(),
      received_value: any()
    }
    
    def new(message, context \\ %{}) do
      %__MODULE__{
        message: message,
        context: context,
        received_value: Map.get(context, :received)
      }
    end
  end
  
  defmodule ConfigurationError do
    @moduledoc "Error for configuration-related issues"
    
    defexception [:message, :config_key, :expected_type, :received_value]
    
    @type t :: %__MODULE__{
      message: String.t(),
      config_key: atom() | String.t(),
      expected_type: String.t(),
      received_value: any()
    }
    
    def new(message, config_key, expected_type \\ nil, received_value \\ nil) do
      %__MODULE__{
        message: message,
        config_key: config_key,
        expected_type: expected_type,
        received_value: received_value
      }
    end
  end
  
  defmodule TerminalError do
    @moduledoc "Error for terminal/display-related issues"
    
    defexception [:message, :terminal_capability, :fallback_available]
    
    @type t :: %__MODULE__{
      message: String.t(),
      terminal_capability: String.t(),
      fallback_available: boolean()
    }
    
    def new(message, capability \\ "unknown", fallback_available \\ false) do
      %__MODULE__{
        message: message,
        terminal_capability: capability,
        fallback_available: fallback_available
      }
    end
  end
  
  defmodule ProcessError do
    @moduledoc "Error for process/system-related issues"
    
    defexception [:message, :process_info, :system_info]
    
    @type t :: %__MODULE__{
      message: String.t(),
      process_info: map(),
      system_info: map()
    }
    
    def new(message, process_info \\ %{}, system_info \\ %{}) do
      %__MODULE__{
        message: message,
        process_info: process_info,
        system_info: system_info
      }
    end
  end
  
  @doc """
  Extracts error message from any BCUtils error struct.
  
  ## Examples
  
      iex> error = BCUtils.Errors.InvalidInput.new("Bad parameter")
      iex> BCUtils.Errors.message(error)
      "Bad parameter"
  """
  @spec message(struct()) :: String.t()
  def message(%{message: msg}) when is_binary(msg), do: msg
  def message(error), do: inspect(error)
  
  @doc """
  Creates a formatted error report for logging or debugging.
  
  ## Examples
  
      iex> error = BCUtils.Errors.ConfigurationError.new("Invalid config", :theme, "atom", "string")
      iex> BCUtils.Errors.format_error(error)
      "ConfigurationError: Invalid config\\nConfig Key: theme\\nExpected: atom\\nReceived: \\"string\\""
  """
  @spec format_error(struct()) :: String.t()
  def format_error(%InvalidInput{} = error) do
    base = "InvalidInput: #{error.message}"
    context_info = if map_size(error.context) > 0 do
      "\\nContext: #{inspect(error.context)}"
    else
      ""
    end
    base <> context_info
  end
  
  def format_error(%ConfigurationError{} = error) do
    base = "ConfigurationError: #{error.message}"
    key_info = if error.config_key, do: "\\nConfig Key: #{error.config_key}", else: ""
    type_info = if error.expected_type, do: "\\nExpected: #{error.expected_type}", else: ""
    value_info = if error.received_value, do: "\\nReceived: #{inspect(error.received_value)}", else: ""
    base <> key_info <> type_info <> value_info
  end
  
  def format_error(%TerminalError{} = error) do
    base = "TerminalError: #{error.message}"
    capability_info = "\\nCapability: #{error.terminal_capability}"
    fallback_info = "\\nFallback Available: #{error.fallback_available}"
    base <> capability_info <> fallback_info
  end
  
  def format_error(%ProcessError{} = error) do
    base = "ProcessError: #{error.message}"
    process_info = if map_size(error.process_info) > 0 do
      "\\nProcess Info: #{inspect(error.process_info)}"
    else
      ""
    end
    system_info = if map_size(error.system_info) > 0 do
      "\\nSystem Info: #{inspect(error.system_info)}"
    else
      ""
    end
    base <> process_info <> system_info
  end
  
  def format_error(error), do: inspect(error)
  
  @doc """
  Wraps a function result in an ok/error tuple if not already wrapped.
  
  ## Examples
  
      iex> BCUtils.Errors.wrap_result("success")
      {:ok, "success"}
      
      iex> BCUtils.Errors.wrap_result({:error, "failed"})
      {:error, "failed"}
  """
  @spec wrap_result(any()) :: {:ok, any()} | {:error, any()}
  def wrap_result({:ok, _} = result), do: result
  def wrap_result({:error, _} = result), do: result
  def wrap_result(result), do: {:ok, result}
  
  @doc """
  Safely executes a function and wraps any exceptions as error tuples.
  
  ## Examples
  
      iex> BCUtils.Errors.safe_execute(fn -> 1 + 1 end)
      {:ok, 2}
      
      iex> BCUtils.Errors.safe_execute(fn -> raise "oops" end)
      {:error, %RuntimeError{message: "oops"}}
  """
  @spec safe_execute((-> any())) :: {:ok, any()} | {:error, Exception.t()}
  def safe_execute(fun) when is_function(fun, 0) do
    try do
      {:ok, fun.()}
    rescue
      exception -> {:error, exception}
    end
  end
end
