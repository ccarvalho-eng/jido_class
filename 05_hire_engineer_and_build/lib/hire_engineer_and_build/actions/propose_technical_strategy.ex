defmodule HireEngineerAndBuild.Actions.ProposeTechnicalStrategy do
  @moduledoc """
  Produces the CTO's technical plan and reports an executive summary to the CEO.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "propose_technical_strategy",
    description: "Owns the technical roadmap for a milestone and reports a summary upward",
    schema: [
      milestone: [type: :string, required: true],
      product_goal: [type: :string, required: true]
    ]

  @impl true
  def run(%{milestone: milestone, product_goal: product_goal}, context) do
    roadmap = Map.get(context.state, :technical_roadmap, [])
    hiring_intent = Map.get(context.state, :hiring_intent, [])
    architecture_decisions = Map.get(context.state, :architecture_decisions, [])

    architecture_focus = "combat pipeline"
    first_hire = "gameplay engineer"

    signal =
      Signal.new!(
        "studio.technical_strategy_proposed",
        %{
          milestone: milestone,
          architecture_focus: architecture_focus,
          first_hire: first_hire,
          status: "technical_strategy_ready"
        },
        source: "/cto"
      )

    directive = Directive.emit_to_parent(context.agent, signal)

    {:ok,
     %{
       technical_roadmap:
         roadmap ++
           [
             %{
               milestone: milestone,
               architecture_focus: architecture_focus,
               product_goal: product_goal
             }
           ],
       hiring_intent: hiring_intent ++ [first_hire],
       architecture_decisions: architecture_decisions ++ [architecture_focus]
     }, List.wrap(directive)}
  end
end
