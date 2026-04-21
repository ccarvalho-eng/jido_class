defmodule EngineeringOrg.Actions.RecordEngineerTaskCompleted do
  @moduledoc """
  Aggregates engineer reports and emits a milestone snapshot when all expected
  disciplines have reported in.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "record_engineer_task_completed",
    description: "Aggregates engineer reports under the engineering manager",
    schema: [
      discipline: [type: :string, required: true],
      task: [type: :string, required: true],
      deliverable: [type: :string, required: true]
    ]

  @impl true
  def run(params, context) do
    reports = Map.get(context.state, :completed_reports, [])
    milestone = Map.get(context.state, :active_milestone)
    expected_disciplines = Map.get(context.state, :expected_disciplines, [])
    updated_reports = reports ++ [params]

    directive =
      maybe_emit_snapshot(updated_reports, expected_disciplines, milestone, context.agent)

    {:ok, %{completed_reports: updated_reports}, List.wrap(directive)}
  end

  defp maybe_emit_snapshot(reports, expected_disciplines, milestone, agent) do
    disciplines = Enum.map(reports, & &1.discipline)

    if milestone != nil and disciplines == expected_disciplines do
      Signal.new!(
        "engineering.milestone_delivery_snapshot",
        %{
          milestone: milestone,
          engineers_completed: length(reports),
          disciplines: disciplines,
          status: "execution_snapshot_ready"
        },
        source: "/engineering_manager"
      )
      |> then(&Directive.emit_to_parent(agent, &1))
    end
  end
end
