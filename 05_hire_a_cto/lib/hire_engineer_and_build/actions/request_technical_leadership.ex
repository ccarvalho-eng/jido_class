defmodule HireEngineerAndBuild.Actions.RequestTechnicalLeadership do
  @moduledoc """
  Spawns the CTO as the company's technical leader.
  """

  alias HireEngineerAndBuild.CTOAgent
  alias Jido.Agent.Directive

  use Jido.Action,
    name: "request_technical_leadership",
    description: "Spawns the CTO as the technical boundary for the studio",
    schema: []

  @impl true
  def run(_params, _context) do
    directive = Directive.spawn_agent(CTOAgent, :cto)
    {:ok, %{leadership_team: ["cto"]}, [directive]}
  end
end
