# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the book "Functional Web Development" by Lance Halvorsen. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Islands.Guesses do
  @moduledoc """
  A guesses struct and functions for the _Game of Islands_.

  The guesses struct contains the fields `hits` and `misses` representing the
  guesses of an opponent in the _Game of Islands_.

  ##### Based on the book [Functional Web Development](https://pragprog.com/titles/lhelph/functional-web-development-with-elixir-otp-and-phoenix/) by Lance Halvorsen.
  """

  alias __MODULE__
  alias Islands.{Coord, Island}

  @derive Jason.Encoder
  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  @typedoc "A guesses struct for the Game of Islands"
  @type t :: %Guesses{hits: Island.coords(), misses: Island.coords()}
  @typedoc "Type of guess"
  @type type :: :hit | :miss

  @doc """
  Creates a new guesses struct.

  ## Examples

      iex> Islands.Guesses.new()
      %Islands.Guesses{
        hits: MapSet.new(),
        misses: MapSet.new()
      }
  """
  @spec new :: t
  def new, do: %Guesses{hits: MapSet.new(), misses: MapSet.new()}

  @doc """
  Adds a hit `guess` to the `:hits` set or a miss `guess` to the `:misses` set.
  """
  @spec add(t, type, Coord.t()) :: t | {:error, atom}
  def add(guesses, type, guess)

  def add(%Guesses{} = guesses, :hit, %Coord{} = guess) do
    update_in(guesses.hits, &MapSet.put(&1, guess))
  end

  def add(%Guesses{} = guesses, :miss, %Coord{} = guess) do
    update_in(guesses.misses, &MapSet.put(&1, guess))
  end

  def add(_guesses, _type, _guess), do: {:error, :invalid_guesses_args}

  @doc """
  Returns a map assigning to :squares the list of square numbers
  from the `guesses`'s hits.
  """
  @spec hit_squares(t) :: %{:squares => [Coord.square()]}
  def hit_squares(%Guesses{hits: hits} = _guesses) do
    %{squares: Enum.map(hits, &Coord.to_square/1)}
  end

  @doc """
  Returns a map assigning to :squares the list of square numbers
  from the `guesses`'s misses.
  """
  @spec miss_squares(t) :: %{:squares => [Coord.square()]}
  def miss_squares(%Guesses{misses: misses} = _guesses) do
    %{squares: Enum.map(misses, &Coord.to_square/1)}
  end
end
