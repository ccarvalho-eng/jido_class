defmodule SpawnBackofficeAndRecruiter.Actions.RequestSupportTeam do
  @moduledoc """
  Spawns the first support-team agents for the CEO.
  """

  alias Jido.Agent.Directive
  alias SpawnBackofficeAndRecruiter.{BackofficeAgent, RecruiterAgent}

  use Jido.Action,
    name: "request_support_team",
    description: "Spawns backoffice and recruiter support agents",
    schema: []

  @impl true
  def run(_params, _context) do
    directives = [
      Directive.spawn_agent(BackofficeAgent, :backoffice),
      Directive.spawn_agent(RecruiterAgent, :recruiter)
    ]

    {:ok, %{support_team: ["backoffice", "recruiter"]}, directives}
  end
end
