defmodule Islands.GuessesTest do
  use ExUnit.Case, async: true

  alias Islands.{Coord, Guesses}

  doctest Guesses

  setup_all do
    {:ok, coord1} = Coord.new(1, 1)
    {:ok, coord2} = Coord.new(2, 2)
    coords = %{one: coord1, two: coord2}

    guesses =
      Guesses.new()
      |> Guesses.add(:hit, coords.one)
      |> Guesses.add(:hit, coords.two)

    poison =
      ~s<{\"misses\":[],\"hits\":[{\"row\":1,\"col\":1},{\"row\":2,\"col\":2}]}>

    jason =
      ~s<{\"hits\":[{\"col\":1,\"row\":1},{\"col\":2,\"row\":2}],\"misses\":[]}>

    decoded = %{
      "hits" => [%{"col" => 1, "row" => 1}, %{"col" => 2, "row" => 2}],
      "misses" => []
    }

    {:ok,
     json: %{poison: poison, jason: jason, decoded: decoded},
     coords: coords,
     guesses: guesses}
  end

  describe "A guesses struct" do
    test "can be encoded by Poison", %{guesses: guesses, json: json} do
      assert Poison.encode!(guesses) == json.poison
      assert Poison.decode!(json.poison) == json.decoded
    end

    test "can be encoded by Jason", %{guesses: guesses, json: json} do
      assert Jason.encode!(guesses) == json.jason
      assert Jason.decode!(json.jason) == json.decoded
    end
  end

  describe "Guesses.new/0" do
    test "returns a struct" do
      assert %Guesses{hits: _hits, misses: _misses} = Guesses.new()
    end
  end

  describe "Guesses.add/3" do
    test "adds hits ensuring uniqueness", %{coords: coords} do
      guesses =
        Guesses.new()
        |> Guesses.add(:hit, coords.one)
        |> Guesses.add(:hit, coords.two)
        |> Guesses.add(:hit, coords.one)

      assert MapSet.member?(guesses.hits, coords.one)
      assert MapSet.member?(guesses.hits, coords.two)
      assert MapSet.size(guesses.hits) == 2
    end

    test "adds misses ensuring uniqueness", %{coords: coords} do
      guesses =
        Guesses.new()
        |> Guesses.add(:miss, coords.one)
        |> Guesses.add(:miss, coords.two)
        |> Guesses.add(:miss, coords.one)

      assert MapSet.member?(guesses.misses, coords.one)
      assert MapSet.member?(guesses.misses, coords.two)
      assert MapSet.size(guesses.misses) == 2
    end

    test "returns {:error, ...} given bad args", %{coords: coords} do
      assert Guesses.new() |> Guesses.add(:what, coords.one) ==
               {:error, :invalid_guesses_args}

      assert Guesses.new() |> Guesses.add(:hit, {1, 1}) ==
               {:error, :invalid_guesses_args}
    end
  end
end
