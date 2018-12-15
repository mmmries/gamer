defmodule GamerTest do
  use ExUnit.Case
  doctest Gamer

  test "greets the world" do
    assert Gamer.hello() == :world
  end
end
