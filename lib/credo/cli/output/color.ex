defmodule Credo.CLI.Output.Color do
  defstruct [:foreground, background: nil, background_modifier: nil]

  def build(:olive) do
    %__MODULE__{foreground: 100}
  end

  def build(color) do
    %__MODULE__{foreground: color}
  end

  @doc """
  Returns a suitable foreground color for a given `background_color`.

      iex> Credo.CLI.Output.Color.as_background(Credo.CLI.Output.Color.build(:yellow))
      %Credo.CLI.Output.Color{foreground: :black, background_color: yellow}

      iex> Credo.CLI.Output.Color.as_background(Credo.CLI.Output.Color.build(:blue))
      %Credo.CLI.Output.Color{foreground: :white, background_color: blue}

  """
  def as_background(%__MODULE__{foreground: color}) when color in [:cyan, :yellow] do
    %__MODULE__{background: color, foreground: :black, background_modifier: :bright}
  end

  def as_background(%__MODULE__{foreground: color}) do
    %__MODULE__{background: color, foreground: :white, background_modifier: :bright}
  end

  def to_ansi(%__MODULE__{background: nil} = color) do
    [to_ansi_color(color.foreground)]
  end

  def to_ansi(%__MODULE__{} = color) do
    [
      color.background_modifier,
      to_ansi_background(color.background),
      to_ansi_color(color.background),
      " ",
      to_ansi_color(color.foreground),
      foreground_modifier(color.background_modifier)
    ]
    |> Enum.filter(& &1)
  end

  defp foreground_modifier(nil), do: nil
  defp foreground_modifier(_background_modifier), do: :normal

  defp to_ansi_color(color) when is_integer(color), do: IO.ANSI.color(color)
  defp to_ansi_color(color), do: color

  defp to_ansi_background(color) when is_integer(color), do: IO.ANSI.color_background(color)
  defp to_ansi_background(color), do: "#{color}_background" |> String.to_existing_atom()
end
