defmodule JidoClass.FounderAgent do
  @moduledoc """
  Lesson 1 founder agent for the autonomous game studio tutorial.
  """

  use Jido.Agent,
    name: "founder",
    description: "Keeps the studio's early ideas and first milestone organized",
    default_plugins: false,
    schema: [
      studio_name: [type: :string, default: "Starboard Studio"],
      active_idea: [type: :string, default: nil],
      idea_backlog: [type: {:list, :map}, default: []],
      next_milestone: [type: :string, default: nil]
    ]
end

defmodule JidoClass.Actions.AddIdea do
  @moduledoc """
  Adds a new game idea to the founder backlog.
  """

  use Jido.Action,
    name: "add_idea",
    description: "Adds a game idea to the studio backlog",
    schema: [
      name: [type: :string, required: true],
      genre: [type: :string, required: true],
      hook: [type: :string, required: true]
    ]

  @impl true
  def run(params, context) do
    backlog = Map.get(context.state, :idea_backlog, [])

    idea = %{
      name: params.name,
      genre: params.genre,
      hook: params.hook
    }

    {:ok, %{idea_backlog: backlog ++ [idea]}}
  end
end

defmodule JidoClass.Actions.GreenlightIdea do
  @moduledoc """
  Selects one of the founder's ideas as the active game project.
  """

  use Jido.Action,
    name: "greenlight_idea",
    description: "Selects the studio's active game idea",
    schema: [
      name: [type: :string, required: true]
    ]

  @impl true
  def run(%{name: name}, context) do
    backlog = Map.get(context.state, :idea_backlog, [])

    case Enum.find(backlog, &(&1.name == name)) do
      nil ->
        {:error, Jido.Error.validation_error("Idea is not in the backlog", idea_name: name)}

      idea ->
        {:ok, %{active_idea: idea.name}}
    end
  end
end

defmodule JidoClass.Actions.PlanMilestone do
  @moduledoc """
  Sets the next milestone for the studio.
  """

  use Jido.Action,
    name: "plan_milestone",
    description: "Sets the studio's next delivery milestone",
    schema: [
      milestone: [type: :string, required: true]
    ]

  @impl true
  def run(%{milestone: milestone}, _context) do
    {:ok, %{next_milestone: milestone}}
  end
end
