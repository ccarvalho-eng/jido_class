defmodule EngineeringOrg.Actions.BootstrapEngineeringTeam do
  @moduledoc """
  Spawns the first two engineers beneath the engineering manager.
  """

  alias EngineeringOrg.EngineerAgent
  alias Jido.Agent.Directive

  use Jido.Action,
    name: "bootstrap_engineering_team",
    description: "Spawns a small engineering team for the current milestone",
    schema: [
      milestone: [type: :string, required: true]
    ]

  @impl true
  def run(%{milestone: milestone}, _context) do
    directives = [
      Directive.spawn_agent(EngineerAgent, :gameplay_engineer,
        opts: %{initial_state: %{discipline: "gameplay"}}
      ),
      Directive.spawn_agent(EngineerAgent, :ui_engineer,
        opts: %{initial_state: %{discipline: "ui"}}
      )
    ]

    {:ok,
     %{
       active_milestone: milestone,
       expected_disciplines: ["gameplay", "ui"],
       completed_reports: []
     }, directives}
  end
end
