defmodule BCUtils.BitFlagsTest do
  @moduledoc """
    This module contains tests for the BCUtils.BitFlags module.
  """
  use ExUnit.Case

  @tag :bc_bitflags
  @tag :bc_docs
  doctest BCUtils.BitFlags

  describe "set/2" do
    @tag :bc_bitflags
    test "GIVEN: original_state is `0b00100100` (integer: 36)
          WHEN the flag to be set is `0b01000000` (integer: 64)
          THEN the result is `0b01100100` (integer: 100)" do
      assert BitFlags.set(36, 64) == 100
    end
  end
end
