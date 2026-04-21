defmodule BackofficePluginTest do
  use ExUnit.Case, async: false

  alias BackofficePlugin.FounderAgent
  alias BackofficePlugin.StudioJido
  alias Jido.AgentServer
  alias Jido.Signal

  test "plugin state is mounted under backoffice" do
    founder = FounderAgent.new()

    assert founder.state.backoffice.monthly_budget == 12_000
    assert founder.state.backoffice.hiring_budget == 4_000
    assert founder.state.backoffice.allocations == []
    assert founder.state.backoffice.approved_roles == []
    assert founder.state.backoffice.payroll_ready == false
  end

  test "plugin signal routes update backoffice state through AgentServer" do
    founder_id = unique_agent_id("backoffice-founder")

    on_exit(fn -> safe_stop(founder_id) end)

    {:ok, pid} = StudioJido.start_agent(FounderAgent, id: founder_id)

    {:ok, founder} =
      AgentServer.call(
        pid,
        Signal.new!(
          "backoffice.budget_allocated",
          %{category: "art", amount: 1_500},
          source: "/ops"
        )
      )

    assert founder.state.backoffice.allocations == [%{category: "art", amount: 1_500}]

    {:ok, founder} =
      AgentServer.call(
        pid,
        Signal.new!(
          "backoffice.hiring_approved",
          %{role: "engineer"},
          source: "/ops"
        )
      )

    assert founder.state.backoffice.approved_roles == ["engineer"]
  end

  test "founder keeps core studio behavior while the plugin handles operations" do
    founder_id = unique_agent_id("combined-founder")

    on_exit(fn -> safe_stop(founder_id) end)

    {:ok, pid} = StudioJido.start_agent(FounderAgent, id: founder_id)

    {:ok, _founder} =
      AgentServer.call(
        pid,
        Signal.new!(
          "studio.idea_submitted",
          %{
            name: "Orbit Cafe",
            genre: "cozy sim",
            hook: "Run a coffee shop on a drifting station"
          },
          source: "/founder/notebook"
        )
      )

    {:ok, founder} =
      AgentServer.call(
        pid,
        Signal.new!(
          "backoffice.payroll_marked_ready",
          %{},
          source: "/ops"
        )
      )

    assert founder.state.idea_backlog == [
             %{
               name: "Orbit Cafe",
               genre: "cozy sim",
               hook: "Run a coffee shop on a drifting station"
             }
           ]

    assert founder.state.backoffice.payroll_ready == true
  end

  defp unique_agent_id(prefix) do
    "#{prefix}-#{System.unique_integer([:positive])}"
  end

  defp safe_stop(agent_id) do
    case StudioJido.whereis(agent_id) do
      nil -> :ok
      _pid -> StudioJido.stop_agent(agent_id)
    end
  end
end
