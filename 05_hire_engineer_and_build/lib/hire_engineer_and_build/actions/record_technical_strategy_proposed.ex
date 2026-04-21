defmodule HireEngineerAndBuild.Actions.RecordTechnicalStrategyProposed do
  @moduledoc """
  Stores the executive summary that comes back from the CTO.
  """

  use Jido.Action,
    name: "record_technical_strategy_proposed",
    description: "Records the CTO's executive-level strategy summary",
    schema: [
      milestone: [type: :string, required: true],
      architecture_focus: [type: :string, required: true],
      first_hire: [type: :string, required: true],
      status: [type: :string, required: true]
    ]

  @impl true
  def run(params, context) do
    updates = Map.get(context.state, :executive_updates, [])
    {:ok, %{executive_updates: updates ++ [params]}}
  end
end
