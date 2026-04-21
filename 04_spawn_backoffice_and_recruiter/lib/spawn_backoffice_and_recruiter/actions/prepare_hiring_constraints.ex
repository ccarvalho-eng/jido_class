defmodule SpawnBackofficeAndRecruiter.Actions.PrepareHiringConstraints do
  @moduledoc """
  Prepares hiring constraints for a role and reports them to the parent CEO.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "prepare_hiring_constraints",
    description: "Prepares hiring constraints in the backoffice agent",
    schema: [
      role: [type: :string, required: true]
    ]

  @impl true
  def run(%{role: role}, context) do
    reviews = Map.get(context.state, :pending_hiring_reviews, [])
    hiring_budget = Map.get(context.state, :hiring_budget, 4_000)

    signal =
      Signal.new!(
        "studio.hiring_constraints_prepared",
        %{role: role, status: "review_prepared", hiring_budget: hiring_budget},
        source: "/backoffice"
      )

    directive = Directive.emit_to_parent(context.agent, signal)

    {:ok, %{pending_hiring_reviews: reviews ++ [role]}, List.wrap(directive)}
  end
end
