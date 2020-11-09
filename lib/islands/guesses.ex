# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the book "Functional Web Development" by Lance Halvorsen. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Islands.Guesses do
  @moduledoc """
  Creates a `guesses` struct for the _Game of Islands_.

  ##### Based on the book [Functional Web Development](https://pragprog.com/book/lhelph/functional-web-development-with-elixir-otp-and-phoenix) by Lance Halvorsen.
  """

  alias __MODULE__
  alias Islands.{Coord, Island}

  @derive [Poison.Encoder]
  @derive Jason.Encoder
  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  @type t :: %Guesses{hits: Island.coords(), misses: Island.coords()}
  @type type :: :hit | :miss

  @spec new :: t
  def new, do: %Guesses{hits: MapSet.new(), misses: MapSet.new()}

  @spec add(t, type, Coord.t()) :: t | {:error, atom}
  def add(guesses, type, guess)

  def add(%Guesses{} = guesses, :hit, %Coord{} = guess) do
    update_in(guesses.hits, &MapSet.put(&1, guess))
  end

  def add(%Guesses{} = guesses, :miss, %Coord{} = guess) do
    update_in(guesses.misses, &MapSet.put(&1, guess))
  end

  def add(_guesses, _type, _guess), do: {:error, :invalid_guesses_args}

  @spec hit_squares(t) :: %{:squares => [Coord.square()]}
  def hit_squares(%Guesses{hits: hits} = _guesses) do
    %{squares: Enum.map(hits, &Coord.to_square/1)}
  end

  @spec miss_squares(t) :: %{:squares => [Coord.square()]}
  def miss_squares(%Guesses{misses: misses} = _guesses) do
    %{squares: Enum.map(misses, &Coord.to_square/1)}
  end
end
