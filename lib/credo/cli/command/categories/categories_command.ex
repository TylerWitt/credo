defmodule Credo.CLI.Command.Categories.CategoriesCommand do
  @moduledoc false

  alias Credo.CLI.Command.Categories.CategoriesOutput
  alias Credo.CLI.Switch
  alias Credo.CLI.Output.Color

  use Credo.CLI.Command,
    short_description: "Show and explain all issue categories",
    cli_switches: [
      Switch.string("format"),
      Switch.boolean("help", alias: :h)
    ]

  @categories [
    %{
      id: :readability,
      name: "readability",
      color: Color.build(:blue),
      title: "Code Readability",
      description: """
      Readability checks do not concern themselves with the technical correctness
      of your code, but how easy it is to digest.
      """
    },
    %{
      id: :design,
      name: "design",
      color: Color.build(:olive),
      title: "Software Design",
      description: """
      While refactor checks show you possible problems, these checks try to
      highlight possibilities, like - potentially intended - duplicated code or
      TODO and FIXME comments.
      """
    },
    %{
      id: :refactor,
      name: "refactor",
      color: Color.build(:yellow),
      title: "Refactoring opportunities",
      description: """
      The Refactor checks show you opportunities to avoid future problems and
      technical debt.
      """
    },
    %{
      id: :warning,
      name: "warning",
      color: Color.build(:red),
      title: "Warnings - please take a look",
      description: """
      These checks warn you about things that are potentially dangerous, like a
      missed call to `IEx.pry` you put in during a debugging session or a call
      to String.downcase without using the result.
      """
    },
    %{
      id: :consistency,
      name: "consistency",
      color: Color.build(:cyan),
      title: "Consistency",
      description: """
      These checks take a look at your code and ensure a consistent coding style.
      Using tabs or spaces? Both is fine, just don't mix them or Credo will tell
      you.
      """
    }
  ]

  @doc false
  def call(exec, _opts) do
    CategoriesOutput.print_categories(exec, @categories)

    exec
  end
end
