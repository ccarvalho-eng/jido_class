defmodule EngineeringOrg.Actions.RequestExecutionLayer do
  @moduledoc """
  Spawns the engineering manager as the CTO's first execution-layer child.
  """

  alias EngineeringOrg.EngineeringManagerAgent
  alias Jido.Agent.Directive

  use Jido.Action,
    name: "request_execution_layer",
    description: "Spawns the engineering manager under the CTO",
    schema: []

  @impl true
  def run(_params, _context) do
    directive = Directive.spawn_agent(EngineeringManagerAgent, :engineering_manager)
    {:ok, %{execution_team: ["engineering_manager"]}, [directive]}
  end
end
