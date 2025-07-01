# Working with BitFlags in BCUtils

The `BCUtils.BitFlags` module provides a comprehensive set of functions for working with bitwise flags in Elixir. This module is particularly useful for event-sourced systems and finite state machines where multiple states can be represented efficiently using bit manipulation.

## Table of Contents

- [Overview](#overview)
- [Basic Concepts](#basic-concepts)
- [Core Functions](#core-functions)
- [Advanced Operations](#advanced-operations)
- [Flag Management](#flag-management)
- [State Representation](#state-representation)
- [Practical Examples](#practical-examples)
- [Event Sourcing Patterns](#event-sourcing-patterns)
- [Best Practices](#best-practices)
- [Function Reference](#function-reference)

## Overview

The `BCUtils.BitFlags` module offers:

- **Efficient state representation** using bitwise operations
- **Multiple flag manipulation** functions
- **State querying** and validation capabilities
- **Human-readable conversions** with flag maps
- **Event sourcing support** for aggregate state management
- **Performance-optimized operations** using Elixir's bitwise operators

## Basic Concepts

### What are BitFlags?

BitFlags represent multiple boolean states in a single integer using binary representation. Each bit position corresponds to a specific flag or state.

```elixir
# Binary representation: 0b01100100 = 100 in decimal
# Bit positions:         76543210
#                        01100100
# This represents flags at positions 2, 5, and 6 being set
```

### Powers of Two

Flags are typically defined as powers of 2 to ensure each flag occupies a unique bit position:

```elixir
@flags %{
  0   => "None",           # 0b00000000
  1   => "Ready",          # 0b00000001  
  2   => "In Progress",    # 0b00000010
  4   => "Completed",      # 0b00000100
  8   => "Cancelled",      # 0b00001000
  16  => "Failed",         # 0b00010000
  32  => "Archived",       # 0b00100000
  64  => "Ready to Archive", # 0b01000000
  128 => "Ready to Publish", # 0b10000000
}
```

### Why Use BitFlags?

1. **Memory Efficiency**: Store multiple boolean states in a single integer
2. **Performance**: Bitwise operations are extremely fast
3. **Atomic Operations**: Update multiple flags in a single operation
4. **Event Sourcing**: Efficiently represent aggregate state in event streams
5. **Finite State Machines**: Model complex state transitions

## Core Functions

### Setting Flags

#### Single Flag

```elixir
# Set a single flag
state = 0           # 0b00000000
state = BitFlags.set(state, 4)  # 0b00000100 (Completed)
# Result: 4

# Set another flag
state = BitFlags.set(state, 32) # 0b00100100 (Completed + Archived)
# Result: 36
```

#### Multiple Flags

```elixir
# Set multiple flags at once
state = 0
state = BitFlags.set_all(state, [1, 4, 32])
# Result: 37 (Ready + Completed + Archived)
```

### Unsetting Flags

#### Single Flag

```elixir
# Unset a single flag
state = 100         # 0b01100100 (Completed + Archived + Ready to Archive)
state = BitFlags.unset(state, 64)  # Remove "Ready to Archive"
# Result: 36 (0b00100100)
```

#### Multiple Flags

```elixir
# Unset multiple flags
state = 228         # 0b11100100
state = BitFlags.unset_all(state, [64, 128])  # Remove archive flags
# Result: 36
```

### Querying Flags

#### Check Single Flag

```elixir
state = 100         # 0b01100100

BitFlags.has?(state, 4)    # true  (Completed is set)
BitFlags.has?(state, 8)    # false (Cancelled is not set)
BitFlags.has_not?(state, 8) # true  (Cancelled is not set)
```

#### Check Multiple Flags

```elixir
state = 100         # 0b01100100

# Check if ALL flags are set
BitFlags.has_all?(state, [4, 32])     # true  (both Completed and Archived)
BitFlags.has_all?(state, [4, 8])      # false (Cancelled is not set)

# Check if ANY flag is set
BitFlags.has_any?(state, [8, 16])     # false (neither Cancelled nor Failed)
BitFlags.has_any?(state, [4, 8])      # true  (Completed is set)
```

## Advanced Operations

### Flag Decomposition

Extract all power-of-two components from a number:

```elixir
# Decompose a number into its power-of-2 components
BitFlags.decompose(100)
# Result: [4, 32, 64] (the powers of 2 that sum to 100)

BitFlags.decompose(15)
# Result: [1, 2, 4, 8] (all flags from 1 to 8)
```

### State Analysis

Find the highest and lowest set flags:

```elixir
flag_map = %{
  1   => "Ready",
  2   => "In Progress", 
  4   => "Completed",
  8   => "Cancelled",
  16  => "Failed",
  32  => "Archived",
  64  => "Ready to Archive",
  128 => "Ready to Publish"
}

state = 100  # 0b01100100 (Completed + Archived + Ready to Archive)

BitFlags.highest(state, flag_map)
# Result: "Ready to Archive" (highest bit set)

BitFlags.lowest(state, flag_map)  
# Result: "Completed" (lowest bit set)
```

## Flag Management

### Creating Flag Maps

Define meaningful names for your flags:

```elixir
defmodule TaskFlags do
  @flag_map %{
    0   => "None",
    1   => "Created",
    2   => "Assigned", 
    4   => "In Progress",
    8   => "Under Review",
    16  => "Completed",
    32  => "Approved",
    64  => "Published",
    128 => "Archived"
  }

  def flag_map, do: @flag_map

  # Define semantic constants
  def none, do: 0
  def created, do: 1
  def assigned, do: 2
  def in_progress, do: 4
  def under_review, do: 8
  def completed, do: 16
  def approved, do: 32
  def published, do: 64
  def archived, do: 128
end
```

### State Representation

Convert between numeric and human-readable formats:

```elixir
state = 100  # Binary: 0b01100100

# Convert to list of active flags
BitFlags.to_list(state, TaskFlags.flag_map())
# Result: ["Completed", "Approved", "Published"]

# Convert to comma-separated string
BitFlags.to_string(state, TaskFlags.flag_map())
# Result: "Completed, Approved, Published"
```

## Practical Examples

### Task Management System

```elixir
defmodule TaskManager do
  alias BCUtils.BitFlags
  
  @flags %{
    0   => "None",
    1   => "Created",
    2   => "Assigned",
    4   => "In Progress", 
    8   => "Under Review",
    16  => "Completed",
    32  => "Approved",
    64  => "Published",
    128 => "Archived"
  }

  def new_task do
    # Start with "Created" flag
    BitFlags.set(0, 1)
  end

  def assign_task(state) do
    # Add "Assigned" flag
    BitFlags.set(state, 2)
  end

  def start_work(state) do
    # Add "In Progress", remove "Assigned" if present
    state
    |> BitFlags.set(4)
    |> BitFlags.unset(2)
  end

  def submit_for_review(state) do
    # Add "Under Review", remove "In Progress"
    state
    |> BitFlags.set(8)
    |> BitFlags.unset(4)
  end

  def complete_task(state) do
    # Add "Completed", remove "Under Review"
    state
    |> BitFlags.set(16)
    |> BitFlags.unset(8)
  end

  def approve_task(state) do
    # Add "Approved" - requires "Completed"
    if BitFlags.has?(state, 16) do
      BitFlags.set(state, 32)
    else
      {:error, "Task must be completed before approval"}
    end
  end

  def publish_task(state) do
    # Add "Published" - requires "Approved"
    if BitFlags.has?(state, 32) do
      BitFlags.set(state, 64)
    else
      {:error, "Task must be approved before publishing"}
    end
  end

  def archive_task(state) do
    # Add "Archived" - can only archive completed tasks
    if BitFlags.has_any?(state, [16, 64]) do
      BitFlags.set(state, 128)
    else
      {:error, "Task must be completed or published before archiving"}
    end
  end

  def can_edit?(state) do
    # Can edit if not completed, published, or archived
    not BitFlags.has_any?(state, [16, 64, 128])
  end

  def is_in_workflow?(state) do
    # Check if task is actively being worked on
    BitFlags.has_any?(state, [2, 4, 8])
  end

  def get_status(state) do
    # Get human-readable status
    BitFlags.to_string(state, @flags)
  end

  def get_current_stage(state) do
    # Get the highest priority stage
    BitFlags.highest(state, @flags)
  end
end

# Usage example
task = TaskManager.new_task()              # 1 (Created)
task = TaskManager.assign_task(task)       # 3 (Created + Assigned)
task = TaskManager.start_work(task)        # 5 (Created + In Progress)
task = TaskManager.submit_for_review(task) # 9 (Created + Under Review)
task = TaskManager.complete_task(task)     # 17 (Created + Completed)

TaskManager.get_status(task)
# Result: "Created, Completed"

TaskManager.can_edit?(task)
# Result: false
```

### User Permissions System

```elixir
defmodule UserPermissions do
  alias BCUtils.BitFlags
  
  @permissions %{
    1   => "Read",
    2   => "Write", 
    4   => "Delete",
    8   => "Admin",
    16  => "Moderator",
    32  => "Super Admin",
    64  => "System Access",
    128 => "Audit Access"
  }

  def permissions_map, do: @permissions

  # Permission constants
  def read, do: 1
  def write, do: 2
  def delete, do: 4
  def admin, do: 8
  def moderator, do: 16
  def super_admin, do: 32
  def system_access, do: 64
  def audit_access, do: 128

  # Permission groups
  def basic_user, do: BitFlags.set_all(0, [read()])
  def editor, do: BitFlags.set_all(0, [read(), write()])
  def content_manager, do: BitFlags.set_all(0, [read(), write(), delete()])
  def admin_user, do: BitFlags.set_all(0, [read(), write(), delete(), admin()])
  def full_admin, do: BitFlags.set_all(0, [read(), write(), delete(), admin(), super_admin()])

  def grant_permission(user_permissions, permission) do
    BitFlags.set(user_permissions, permission)
  end

  def revoke_permission(user_permissions, permission) do
    BitFlags.unset(user_permissions, permission)
  end

  def grant_permissions(user_permissions, permissions) do
    BitFlags.set_all(user_permissions, permissions)
  end

  def revoke_permissions(user_permissions, permissions) do
    BitFlags.unset_all(user_permissions, permissions)
  end

  def has_permission?(user_permissions, permission) do
    BitFlags.has?(user_permissions, permission)
  end

  def has_any_permission?(user_permissions, permissions) do
    BitFlags.has_any?(user_permissions, permissions)
  end

  def has_all_permissions?(user_permissions, permissions) do
    BitFlags.has_all?(user_permissions, permissions)
  end

  def can_read?(permissions), do: has_permission?(permissions, read())
  def can_write?(permissions), do: has_permission?(permissions, write())
  def can_delete?(permissions), do: has_permission?(permissions, delete())
  def is_admin?(permissions), do: has_permission?(permissions, admin())
  def is_super_admin?(permissions), do: has_permission?(permissions, super_admin())

  def get_permissions_list(user_permissions) do
    BitFlags.to_list(user_permissions, @permissions)
  end

  def permissions_summary(user_permissions) do
    BitFlags.to_string(user_permissions, @permissions)
  end
end

# Usage example
user = UserPermissions.basic_user()       # 1 (Read only)
user = UserPermissions.grant_permission(user, UserPermissions.write()) # 3 (Read + Write)

UserPermissions.can_write?(user)          # true
UserPermissions.can_delete?(user)         # false
UserPermissions.permissions_summary(user) # "Read, Write"
```

### Feature Flags System

```elixir
defmodule FeatureFlags do
  alias BCUtils.BitFlags
  
  @features %{
    1   => "Beta Features",
    2   => "Dark Mode",
    4   => "Analytics",
    8   => "Push Notifications", 
    16  => "Advanced Search",
    32  => "Export Functionality",
    64  => "API Access",
    128 => "Premium Features"
  }

  def features_map, do: @features

  def beta_features, do: 1
  def dark_mode, do: 2
  def analytics, do: 4
  def push_notifications, do: 8
  def advanced_search, do: 16
  def export_functionality, do: 32
  def api_access, do: 64
  def premium_features, do: 128

  def enable_feature(user_flags, feature) do
    BitFlags.set(user_flags, feature)
  end

  def disable_feature(user_flags, feature) do
    BitFlags.unset(user_flags, feature)
  end

  def is_enabled?(user_flags, feature) do
    BitFlags.has?(user_flags, feature)
  end

  def enable_premium_tier(user_flags) do
    premium_flags = [
      advanced_search(),
      export_functionality(),
      api_access(),
      premium_features()
    ]
    BitFlags.set_all(user_flags, premium_flags)
  end

  def disable_premium_tier(user_flags) do
    premium_flags = [
      advanced_search(),
      export_functionality(), 
      api_access(),
      premium_features()
    ]
    BitFlags.unset_all(user_flags, premium_flags)
  end

  def has_premium_access?(user_flags) do
    BitFlags.has?(user_flags, premium_features())
  end

  def get_enabled_features(user_flags) do
    BitFlags.to_list(user_flags, @features)
  end
end
```

## Event Sourcing Patterns

### Aggregate State Management

```elixir
defmodule OrderAggregate do
  alias BCUtils.BitFlags
  
  @states %{
    1   => "Created",
    2   => "Payment Pending",
    4   => "Payment Confirmed", 
    8   => "Processing",
    16  => "Shipped",
    32  => "Delivered",
    64  => "Cancelled",
    128 => "Refunded"
  }

  defstruct [:id, :state, :events]

  def new(id) do
    %__MODULE__{
      id: id,
      state: 1,  # Created
      events: []
    }
  end

  # Event handlers
  def apply_event(%__MODULE__{} = aggregate, {:payment_requested, _}) do
    new_state = BitFlags.set(aggregate.state, 2)  # Payment Pending
    %{aggregate | state: new_state}
  end

  def apply_event(%__MODULE__{} = aggregate, {:payment_confirmed, _}) do
    new_state = 
      aggregate.state
      |> BitFlags.unset(2)  # Remove Payment Pending
      |> BitFlags.set(4)    # Add Payment Confirmed
    %{aggregate | state: new_state}
  end

  def apply_event(%__MODULE__{} = aggregate, {:processing_started, _}) do
    new_state = BitFlags.set(aggregate.state, 8)  # Processing
    %{aggregate | state: new_state}
  end

  def apply_event(%__MODULE__{} = aggregate, {:order_shipped, _}) do
    new_state = 
      aggregate.state
      |> BitFlags.unset(8)  # Remove Processing
      |> BitFlags.set(16)   # Add Shipped
    %{aggregate | state: new_state}
  end

  def apply_event(%__MODULE__{} = aggregate, {:order_delivered, _}) do
    new_state = BitFlags.set(aggregate.state, 32)  # Delivered
    %{aggregate | state: new_state}
  end

  def apply_event(%__MODULE__{} = aggregate, {:order_cancelled, _}) do
    new_state = BitFlags.set(aggregate.state, 64)  # Cancelled
    %{aggregate | state: new_state}
  end

  def apply_event(%__MODULE__{} = aggregate, {:refund_processed, _}) do
    new_state = BitFlags.set(aggregate.state, 128)  # Refunded
    %{aggregate | state: new_state}
  end

  # State queries
  def can_cancel?(%__MODULE__{state: state}) do
    # Can cancel if not shipped, delivered, or already cancelled
    not BitFlags.has_any?(state, [16, 32, 64])
  end

  def can_refund?(%__MODULE__{state: state}) do
    # Can refund if payment confirmed and not already refunded
    BitFlags.has?(state, 4) and not BitFlags.has?(state, 128)
  end

  def is_active?(%__MODULE__{state: state}) do
    # Active if not cancelled, delivered, or refunded
    not BitFlags.has_any?(state, [32, 64, 128])
  end

  def get_status(%__MODULE__{state: state}) do
    BitFlags.to_string(state, @states)
  end

  def get_current_stage(%__MODULE__{state: state}) do
    BitFlags.highest(state, @states)
  end
end

# Usage in event sourcing
order = OrderAggregate.new("order-123")
order = OrderAggregate.apply_event(order, {:payment_requested, %{}})
order = OrderAggregate.apply_event(order, {:payment_confirmed, %{}})

OrderAggregate.get_status(order)
# Result: "Created, Payment Confirmed"

OrderAggregate.can_cancel?(order)  # true
OrderAggregate.is_active?(order)   # true
```

### Event Store Integration

```elixir
defmodule EventStore do
  alias BCUtils.BitFlags

  def save_aggregate_state(aggregate_id, state_flags) do
    # Save the numeric state representation
    # This is very efficient for storage and querying
    :ets.insert(:aggregate_states, {aggregate_id, state_flags})
  end

  def load_aggregate_state(aggregate_id) do
    case :ets.lookup(:aggregate_states, aggregate_id) do
      [{^aggregate_id, state_flags}] -> {:ok, state_flags}
      [] -> {:error, :not_found}
    end
  end

  def query_aggregates_by_state(required_flags) do
    # Find all aggregates that have ALL required flags
    :ets.select(:aggregate_states, [
      {{:"$1", :"$2"}, 
       [{:==, {:band, :"$2", required_flags}, required_flags}], 
       [:"$1"]}
    ])
  end

  def query_aggregates_with_any_state(flag_options) do
    # Find aggregates that have ANY of the specified flags
    :ets.select(:aggregate_states, [
      {{:"$1", :"$2"}, 
       [{:>, {:band, :"$2", flag_options}, 0}], 
       [:"$1"]}
    ])
  end
end

# Usage
EventStore.save_aggregate_state("order-1", 37)  # Created + Payment Confirmed + Shipped
EventStore.save_aggregate_state("order-2", 69)  # Created + Payment Confirmed + Cancelled

# Find all orders that are shipped (flag 16)
shipped_orders = EventStore.query_aggregates_by_state(16)

# Find all orders that are either cancelled or refunded
problem_orders = EventStore.query_aggregates_with_any_state(64 + 128)  # 192
```

## Best Practices

### 1. Use Powers of Two

Always use powers of 2 for your flag values:

```elixir
# Good
@flags %{
  1   => "Active",     # 2^0
  2   => "Verified",   # 2^1  
  4   => "Premium",    # 2^2
  8   => "Admin",      # 2^3
  16  => "Suspended",  # 2^4
}

# Bad - these will conflict
@flags %{
  1 => "Active",
  3 => "Verified",   # 3 = 1 + 2, conflicts!
  5 => "Premium",    # 5 = 1 + 4, conflicts!
}
```

### 2. Define Constants

Create readable constants for your flags:

```elixir
defmodule UserStatus do
  # Define flag constants
  def active, do: 1
  def verified, do: 2
  def premium, do: 4
  def admin, do: 8
  def suspended, do: 16

  # Use constants in operations
  def promote_to_admin(user_flags) do
    user_flags
    |> BitFlags.set(admin())
    |> BitFlags.set(verified())  # Admins must be verified
  end
end
```

### 3. Validate State Transitions

Ensure state transitions are valid:

```elixir
defmodule SafeTaskManager do
  alias BCUtils.BitFlags

  def complete_task(state) do
    cond do
      BitFlags.has?(state, 128) ->  # Already archived
        {:error, "Cannot complete archived task"}
      
      not BitFlags.has?(state, 4) ->  # Not in progress
        {:error, "Task must be in progress to complete"}
      
      true ->
        {:ok, BitFlags.set(state, 16)}  # Set completed
    end
  end
end
```

### 4. Use Meaningful Flag Names

Choose descriptive names that clearly indicate the state:

```elixir
# Good
@order_states %{
  1   => "Pending Payment",
  2   => "Payment Confirmed", 
  4   => "In Fulfillment",
  8   => "Shipped",
  16  => "Delivered",
  32  => "Cancelled",
  64  => "Refunded"
}

# Less clear
@order_states %{
  1   => "State1",
  2   => "State2",
  4   => "State3"
}
```

### 5. Document Flag Combinations

Document which flag combinations are valid:

```elixir
defmodule DocumentStatus do
  @moduledoc """
  Document status flags:
  
  Valid combinations:
  - Draft (1): New document
  - Draft + Under Review (1 + 8): Being reviewed
  - Published (16): Live document
  - Published + Featured (16 + 32): Featured content
  - Archived (64): No longer active
  
  Invalid combinations:
  - Draft + Published: Cannot be both
  - Archived + any other: Archived is terminal state
  """
  
  @flags %{
    1  => "Draft",
    2  => "Needs Review", 
    4  => "Approved",
    8  => "Under Review",
    16 => "Published",
    32 => "Featured",
    64 => "Archived"
  }

  def valid_state?(state) do
    cond do
      BitFlags.has_all?(state, [1, 16]) -> false  # Draft + Published
      BitFlags.has?(state, 64) and state != 64 -> false  # Archived + others
      true -> true
    end
  end
end
```

### 6. Performance Considerations

BitFlags are very efficient, but consider these optimizations:

```elixir
# Cache frequently used flag combinations
@admin_flags BitFlags.set_all(0, [1, 2, 4, 8])  # Computed at compile time

# Use pattern matching when possible
def handle_user_action(user_flags) when band(user_flags, 8) != 0 do
  # User is admin - inline bitwise check
  :admin_action
end

# Batch operations when updating multiple flags
def update_user_status(user_flags, changes) do
  {to_set, to_unset} = Enum.split_with(changes, fn {_flag, action} -> action == :set end)
  
  flags_to_set = Enum.map(to_set, fn {flag, _} -> flag end)
  flags_to_unset = Enum.map(to_unset, fn {flag, _} -> flag end)
  
  user_flags
  |> BitFlags.set_all(flags_to_set)
  |> BitFlags.unset_all(flags_to_unset)
end
```

### 7. Testing BitFlag Operations

Create comprehensive tests for your flag operations:

```elixir
defmodule TaskManagerTest do
  use ExUnit.Case
  alias BCUtils.BitFlags

  describe "task state transitions" do
    test "new task starts with created flag" do
      task = TaskManager.new_task()
      assert BitFlags.has?(task, TaskManager.created())
      assert not BitFlags.has?(task, TaskManager.completed())
    end

    test "cannot complete task that is not in progress" do
      task = TaskManager.new_task()
      assert {:error, _} = TaskManager.complete_task(task)
    end

    test "can complete task that is in progress" do
      task = 
        TaskManager.new_task()
        |> TaskManager.start_work()
        
      assert {:ok, completed_task} = TaskManager.complete_task(task)
      assert BitFlags.has?(completed_task, TaskManager.completed())
    end
  end
end
```

## Function Reference

### Basic Operations

| Function | Description | Example |
|----------|-------------|---------|
| `set(target, flag)` | Set a single flag | `BitFlags.set(0, 4)` → `4` |
| `unset(target, flag)` | Unset a single flag | `BitFlags.unset(7, 4)` → `3` |
| `set_all(target, flags)` | Set multiple flags | `BitFlags.set_all(0, [1, 4])` → `5` |
| `unset_all(target, flags)` | Unset multiple flags | `BitFlags.unset_all(7, [1, 2])` → `4` |

### Query Operations

| Function | Description | Example |
|----------|-------------|---------|
| `has?(target, flag)` | Check if flag is set | `BitFlags.has?(5, 4)` → `true` |
| `has_not?(target, flag)` | Check if flag is not set | `BitFlags.has_not?(5, 2)` → `true` |
| `has_all?(target, flags)` | Check if all flags are set | `BitFlags.has_all?(7, [1, 2])` → `true` |
| `has_any?(target, flags)` | Check if any flag is set | `BitFlags.has_any?(5, [2, 4])` → `true` |

### Conversion Operations

| Function | Description | Example |
|----------|-------------|---------|
| `to_list(target, flag_map)` | Convert to list of descriptions | `BitFlags.to_list(5, map)` → `["Flag1", "Flag3"]` |
| `to_string(target, flag_map)` | Convert to comma-separated string | `BitFlags.to_string(5, map)` → `"Flag1, Flag3"` |
| `decompose(target)` | Get power-of-2 components | `BitFlags.decompose(7)` → `[1, 2, 4]` |

### Analysis Operations

| Function | Description | Example |
|----------|-------------|---------|
| `highest(target, flag_map)` | Get highest set flag description | `BitFlags.highest(6, map)` → `"Flag3"` |
| `lowest(target, flag_map)` | Get lowest set flag description | `BitFlags.lowest(6, map)` → `"Flag2"` |

### Binary Representation Quick Reference

| Decimal | Binary | Flags Set |
|---------|--------|-----------|
| 0 | 0b00000000 | None |
| 1 | 0b00000001 | Flag 0 |
| 2 | 0b00000010 | Flag 1 |
| 3 | 0b00000011 | Flags 0, 1 |
| 4 | 0b00000100 | Flag 2 |
| 5 | 0b00000101 | Flags 0, 2 |
| 7 | 0b00000111 | Flags 0, 1, 2 |
| 15 | 0b00001111 | Flags 0, 1, 2, 3 |

---

*This guide covers the complete functionality of the `BCUtils.BitFlags` module. BitFlags are particularly powerful for event sourcing, state machines, and any scenario where you need to efficiently represent multiple boolean states.*
