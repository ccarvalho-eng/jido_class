defmodule EngineeringOrg.Actions.CompleteAssignedTask do
  @moduledoc """
  Completes an assigned engineering task and reports the result to the manager.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "complete_assigned_task",
    description: "Records an engineering task locally and emits a completion report upward",
    schema: [
      task: [type: :string, required: true],
      deliverable: [type: :string, required: true]
    ]

  @impl true
  def run(%{task: task, deliverable: deliverable}, context) do
    discipline = Map.get(context.state, :discipline)
    assigned_tasks = Map.get(context.state, :assigned_tasks, [])
    completed_deliverables = Map.get(context.state, :completed_deliverables, [])

    signal =
      Signal.new!(
        "engineering.task_completed",
        %{discipline: discipline, task: task, deliverable: deliverable},
        source: "/engineer/#{discipline}"
      )

    directive = Directive.emit_to_parent(context.agent, signal)

    {:ok,
     %{
       assigned_tasks: assigned_tasks ++ [task],
       completed_deliverables: completed_deliverables ++ [deliverable]
     }, List.wrap(directive)}
  end
end
