defmodule BcUtilsTest do
  use ExUnit.Case
  doctest BcUtils

  test "greets the world" do
    assert BcUtils.hello() == :world
  end
end
