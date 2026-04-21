defmodule ProductDesignQaRhythm.Actions.PrepareDesignReview do
  @moduledoc """
  Produces one design response for the current review cycle.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "prepare_design_review",
    description: "Creates a design brief for the current review cycle",
    schema: [
      cycle: [type: :integer, required: true],
      milestone: [type: :string, required: true],
      player_promise: [type: :string, required: true]
    ]

  @impl true
  def run(%{cycle: cycle, milestone: milestone, player_promise: player_promise}, context) do
    focus =
      case cycle do
        1 -> "first-session clarity"
        _ -> "combat readability"
      end

    artifact = "#{milestone}: reinforce #{player_promise}"

    signal =
      Signal.new!(
        "product.design_review_ready",
        %{cycle: cycle, focus: focus, artifact: artifact},
        source: "/designer"
      )

    directive = Directive.emit_to_parent(context.agent, signal)

    review_brief = %{cycle: cycle, focus: focus, artifact: artifact}

    {:ok, %{review_briefs: Map.get(context.state, :review_briefs, []) ++ [review_brief]},
     List.wrap(directive)}
  end
end
