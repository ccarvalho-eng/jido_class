defmodule EngineeringOrg.EngineerAgent do
  @moduledoc """
  Engineer worker agent for lesson 6.

  Engineers keep narrowly scoped execution state and report finished work upward.
  """

  use Jido.Agent,
    name: "engineer",
    description: "Specialized worker for a focused engineering discipline",
    default_plugins: false,
    schema: [
      discipline: [type: :string, default: nil],
      assigned_tasks: [type: {:list, :string}, default: []],
      completed_deliverables: [type: {:list, :string}, default: []]
    ]

  def signal_routes(_ctx) do
    [
      {"engineer.task_assigned", EngineeringOrg.Actions.CompleteAssignedTask}
    ]
  end
end
