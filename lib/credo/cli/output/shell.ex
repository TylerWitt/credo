defmodule Credo.CLI.Output.Shell do
  @moduledoc false

  # This module is used by `Credo.CLI.Output.UI` to write to the shell.

  use GenServer

  alias Credo.CLI.Output.Color

  def start_link(opts \\ []) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def puts do
    puts("")
  end

  @doc "Write the given `value` to `:stdout`."
  def puts(value) do
    GenServer.call(__MODULE__, {:puts, value})
  end

  def use_colors(use_colors) do
    GenServer.call(__MODULE__, {:use_colors, use_colors})
  end

  def suppress_output(callback_fn) do
    GenServer.call(__MODULE__, {:suppress_output, true})
    callback_fn.()
    GenServer.call(__MODULE__, {:suppress_output, false})
  end

  @doc "Like `puts/1`, but writes to `:stderr`."
  def warn(value) do
    GenServer.call(__MODULE__, {:warn, value})
  end

  # callbacks

  def init(_) do
    {:ok, %{use_colors: true, suppress_output: false}}
  end

  def handle_call({:suppress_output, suppress_output}, _from, current_state) do
    new_state = Map.put(current_state, :suppress_output, suppress_output)

    {:reply, nil, new_state}
  end

  def handle_call({:use_colors, use_colors}, _from, current_state) do
    new_state = Map.put(current_state, :use_colors, use_colors)

    {:reply, nil, new_state}
  end

  def handle_call({:puts, _value}, _from, %{suppress_output: true} = current_state) do
    {:reply, nil, current_state}
  end

  def handle_call(
        {:puts, value},
        _from,
        %{use_colors: true, suppress_output: false} = current_state
      ) do
    value
    |> cast_colors()
    |> do_puts()

    {:reply, nil, current_state}
  end

  def handle_call(
        {:puts, value},
        _from,
        %{use_colors: false, suppress_output: false} = current_state
      ) do
    value
    |> remove_colors()
    |> do_puts()

    {:reply, nil, current_state}
  end

  def handle_call({:warn, _value}, _from, %{suppress_output: true} = current_state) do
    {:reply, nil, current_state}
  end

  def handle_call(
        {:warn, value},
        _from,
        %{use_colors: true, suppress_output: false} = current_state
      ) do
    value
    |> cast_colors()
    |> do_warn()

    {:reply, nil, current_state}
  end

  def handle_call(
        {:warn, value},
        _from,
        %{use_colors: false, suppress_output: false} = current_state
      ) do
    value
    |> remove_colors()
    |> do_warn()

    {:reply, nil, current_state}
  end

  defp cast_colors(value) do
    value
    |> List.wrap()
    |> List.flatten()
    |> Enum.flat_map(
      fn
        %Color{} = color -> Color.to_ansi(color)
        item -> [item]
      end
    )
  end

  defp remove_colors(value) do
    value
    |> List.wrap()
    |> List.flatten()
    |> Enum.reject(&match?(%Color{}, &1))
  end

  defp do_puts(value) do
    IO.puts(IO.ANSI.format(value))
  end

  defp do_warn(value) do
    IO.warn(IO.ANSI.format(value))
  end
end
