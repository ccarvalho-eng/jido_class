defmodule FounderRuntime.FounderAgent do
  @moduledoc """
  Founder agent for lesson 2, now driven through runtime signals.
  """

  use Jido.Agent,
    name: "runtime_founder",
    description: "The founder as a live Jido agent that reacts to studio events",
    default_plugins: false,
    schema: [
      studio_name: [type: :string, default: "Starboard Studio"],
      active_idea: [type: :string, default: nil],
      idea_backlog: [type: {:list, :map}, default: []],
      next_milestone: [type: :string, default: nil]
    ]

  def signal_routes(_ctx) do
    [
      {"studio.idea_submitted", FounderRuntime.Actions.AddIdea},
      {"studio.idea_greenlit", FounderRuntime.Actions.GreenlightIdea},
      {"studio.milestone_planned", FounderRuntime.Actions.PlanMilestone}
    ]
  end
end

defmodule FounderRuntime.Actions.AddIdea do
  @moduledoc """
  Adds a new game idea when the founder receives a studio submission signal.
  """

  use Jido.Action,
    name: "add_idea",
    description: "Adds a game idea to the runtime founder backlog",
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

defmodule FounderRuntime.Actions.GreenlightIdea do
  @moduledoc """
  Selects the active game idea from the founder backlog.
  """

  use Jido.Action,
    name: "greenlight_idea",
    description: "Selects the active idea for the runtime founder",
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

defmodule FounderRuntime.Actions.PlanMilestone do
  @moduledoc """
  Sets the next milestone from a runtime signal.
  """

  use Jido.Action,
    name: "plan_milestone",
    description: "Plans the founder's next milestone",
    schema: [
      milestone: [type: :string, required: true]
    ]

  @impl true
  def run(%{milestone: milestone}, _context) do
    {:ok, %{next_milestone: milestone}}
  end
end
