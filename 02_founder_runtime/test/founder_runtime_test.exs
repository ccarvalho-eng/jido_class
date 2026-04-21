defmodule FounderRuntimeTest do
  use ExUnit.Case, async: false

  alias FounderRuntime.FounderAgent
  alias FounderRuntime.StudioJido
  alias Jido.AgentServer
  alias Jido.Signal

  test "founder processes studio signals through AgentServer.call/2" do
    founder_id = unique_agent_id("founder")

    on_exit(fn -> safe_stop(founder_id) end)

    {:ok, pid} = StudioJido.start_agent(FounderAgent, id: founder_id)

    assert pid == StudioJido.whereis(founder_id)

    {:ok, submitted_agent} =
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

    assert submitted_agent.state.idea_backlog == [
             %{
               name: "Orbit Cafe",
               genre: "cozy sim",
               hook: "Run a coffee shop on a drifting station"
             }
           ]

    {:ok, greenlit_agent} =
      AgentServer.call(
        pid,
        Signal.new!("studio.idea_greenlit", %{name: "Orbit Cafe"}, source: "/lead")
      )

    {:ok, planned_agent} =
      AgentServer.call(
        pid,
        Signal.new!("studio.milestone_planned", %{milestone: "build a playable prototype"},
          source: "/lead"
        )
      )

    assert greenlit_agent.state.active_idea == "Orbit Cafe"
    assert planned_agent.state.next_milestone == "build a playable prototype"
  end

  test "founder processes async milestone planning through cast/2" do
    founder_id = unique_agent_id("async-founder")

    on_exit(fn -> safe_stop(founder_id) end)

    {:ok, pid} = StudioJido.start_agent(FounderAgent, id: founder_id)

    :ok =
      AgentServer.cast(
        pid,
        Signal.new!(
          "studio.idea_submitted",
          %{
            name: "Dungeon Postal",
            genre: "management sim",
            hook: "Deliver mail in a cursed dungeon"
          },
          source: "/founder/notebook"
        )
      )

    :ok =
      AgentServer.cast(
        pid,
        Signal.new!("studio.idea_greenlit", %{name: "Dungeon Postal"}, source: "/lead")
      )

    :ok =
      AgentServer.cast(
        pid,
        Signal.new!("studio.milestone_planned", %{milestone: "prepare a vertical slice"},
          source: "/lead"
        )
      )

    state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(pid)

        if state.agent.state.next_milestone == "prepare a vertical slice" do
          state
        end
      end)

    assert state.agent.state.active_idea == "Dungeon Postal"
    assert state.agent.state.next_milestone == "prepare a vertical slice"
  end

  test "studio instance lists the running founder" do
    founder_id = unique_agent_id("listed-founder")

    on_exit(fn -> safe_stop(founder_id) end)

    {:ok, _pid} = StudioJido.start_agent(FounderAgent, id: founder_id)

    agents = StudioJido.list_agents()

    assert Enum.any?(agents, fn
             {id, _pid} ->
               id == founder_id

             agent when is_map(agent) ->
               Map.get(agent, :id) == founder_id or Map.get(agent, "id") == founder_id

             _other ->
               false
           end)
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

  defp wait_until(fun, attempts \\ 20)

  defp wait_until(fun, attempts) when attempts > 0 do
    case fun.() do
      nil ->
        Process.sleep(50)
        wait_until(fun, attempts - 1)

      value ->
        value
    end
  end

  defp wait_until(_fun, 0) do
    flunk("condition was not met before the timeout")
  end
end
