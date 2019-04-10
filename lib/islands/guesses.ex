# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the book "Functional Web Development" by Lance Halvorsen. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Islands.Guesses do
  use PersistConfig

  @book_ref Application.get_env(@app, :book_ref)

  @moduledoc """
  Creates a `guesses` struct for the _Game of Islands_.
  \n##### #{@book_ref}
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
end
