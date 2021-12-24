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

    {:ok, square_70} = Coord.new(7, 10)
    {:ok, square_84} = Coord.new(9, 4)
    misses = %{square_70: square_70, square_84: square_84}

    {:ok, square_24} = Coord.new(3, 4)
    {:ok, square_25} = Coord.new(3, 5)
    hits = %{square_24: square_24, square_25: square_25}

    poison = ~s<{"misses":[],"hits":[{"row":1,"col":1},{"row":2,"col":2}]}>
    jason = ~s<{"hits":[{"col":1,"row":1},{"col":2,"row":2}],"misses":[]}>

    decoded = %{
      "hits" => [%{"col" => 1, "row" => 1}, %{"col" => 2, "row" => 2}],
      "misses" => []
    }

    %{
      json: %{poison: poison, jason: jason, decoded: decoded},
      coords: coords,
      guesses: guesses,
      misses: misses,
      hits: hits
    }
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
    test "returns a guesses struct" do
      assert %Guesses{hits: _hits, misses: _misses} = Guesses.new()
    end
  end

  describe "Guesses.add/3" do
    test "adds new hits only ensuring uniqueness", %{coords: coords} do
      guesses =
        Guesses.new()
        |> Guesses.add(:hit, coords.one)
        |> Guesses.add(:hit, coords.two)
        |> Guesses.add(:hit, coords.one)

      assert MapSet.member?(guesses.hits, coords.one)
      assert MapSet.member?(guesses.hits, coords.two)
      assert MapSet.size(guesses.hits) == 2
    end

    test "adds new misses only ensuring uniqueness", %{coords: coords} do
      guesses =
        Guesses.new()
        |> Guesses.add(:miss, coords.one)
        |> Guesses.add(:miss, coords.two)
        |> Guesses.add(:miss, coords.one)

      assert MapSet.member?(guesses.misses, coords.one)
      assert MapSet.member?(guesses.misses, coords.two)
      assert MapSet.size(guesses.misses) == 2
    end

    test "returns {:error, reason} given bad args", %{coords: coords} do
      assert Guesses.new() |> Guesses.add(:what, coords.one) ==
               {:error, :invalid_guesses_args}

      assert Guesses.new() |> Guesses.add(:hit, {1, 1}) ==
               {:error, :invalid_guesses_args}
    end
  end

  describe "Guesses.hit_squares/1" do
    test "returns a map of square numbers", %{hits: hits} do
      guesses =
        Guesses.new()
        |> Guesses.add(:hit, hits.square_24)
        |> Guesses.add(:hit, hits.square_25)

      assert Guesses.hit_squares(guesses) in [
               %{squares: [24, 25]},
               %{squares: [25, 24]}
             ]
    end
  end

  describe "Guesses.miss_squares/1" do
    test "returns a map of square numbers", %{misses: misses} do
      guesses =
        Guesses.new()
        |> Guesses.add(:miss, misses.square_70)
        |> Guesses.add(:miss, misses.square_84)

      assert Guesses.miss_squares(guesses) in [
               %{squares: [70, 84]},
               %{squares: [84, 70]}
             ]
    end
  end
end
