defmodule MetriTest do
  use ExUnit.Case
  doctest Metri

  test "greets the world" do
    assert Metri.hello() == :world
  end
end
