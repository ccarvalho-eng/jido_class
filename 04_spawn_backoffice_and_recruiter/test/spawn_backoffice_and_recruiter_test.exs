defmodule SpawnBackofficeAndRecruiterTest do
  use ExUnit.Case, async: false

  alias Jido.AgentServer
  alias Jido.Signal

  alias SpawnBackofficeAndRecruiter.{
    BackofficeAgent,
    CEOAgent,
    RecruiterAgent,
    StudioJido
  }

  test "ceo spawns backoffice and recruiter support agents" do
    ceo_id = unique_agent_id("ceo")

    on_exit(fn -> safe_stop_family(ceo_id) end)

    {:ok, pid} = StudioJido.start_agent(CEOAgent, id: ceo_id)

    {:ok, ceo} =
      AgentServer.call(
        pid,
        Signal.new!("studio.support_team_requested", %{}, source: "/ceo")
      )

    assert ceo.state.support_team == ["backoffice", "recruiter"]

    state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(pid)

        if Map.has_key?(state.children, :backoffice) and Map.has_key?(state.children, :recruiter) do
          state
        end
      end)

    assert state.children.backoffice.module == BackofficeAgent
    assert state.children.recruiter.module == RecruiterAgent
    assert state.children.backoffice.id == "#{ceo_id}/backoffice"
    assert state.children.recruiter.id == "#{ceo_id}/recruiter"

    assert state.agent.state.support_team_boot_events == [
             %{child_id: "#{ceo_id}/backoffice", tag: "backoffice"},
             %{child_id: "#{ceo_id}/recruiter", tag: "recruiter"}
           ]
  end

  test "support agents report their work back to the ceo" do
    ceo_id = unique_agent_id("ceo-reporting")

    on_exit(fn -> safe_stop_family(ceo_id) end)

    {:ok, pid} = StudioJido.start_agent(CEOAgent, id: ceo_id)

    {:ok, _ceo} =
      AgentServer.call(
        pid,
        Signal.new!("studio.support_team_requested", %{}, source: "/ceo")
      )

    parent_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(pid)

        if Map.has_key?(state.children, :backoffice) and Map.has_key?(state.children, :recruiter) do
          state
        end
      end)

    recruiter_pid = parent_state.children.recruiter.pid
    backoffice_pid = parent_state.children.backoffice.pid

    {:ok, _recruiter} =
      AgentServer.call(
        recruiter_pid,
        Signal.new!(
          "recruiter.role_opened",
          %{role: "gameplay engineer"},
          source: "/ceo"
        )
      )

    {:ok, _backoffice} =
      AgentServer.call(
        backoffice_pid,
        Signal.new!(
          "backoffice.hiring_review_requested",
          %{role: "gameplay engineer"},
          source: "/ceo"
        )
      )

    updated_parent_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(pid)

        recruiting = state.agent.state.recruiting_updates
        backoffice = state.agent.state.backoffice_updates

        if recruiting != [] and backoffice != [] do
          state
        end
      end)

    assert updated_parent_state.agent.state.recruiting_updates == [
             %{role: "gameplay engineer", status: "search_started"}
           ]

    assert updated_parent_state.agent.state.backoffice_updates == [
             %{role: "gameplay engineer", status: "review_prepared", hiring_budget: 4_000}
           ]
  end

  defp unique_agent_id(prefix) do
    "#{prefix}-#{System.unique_integer([:positive])}"
  end

  defp safe_stop_family(parent_id) do
    child_ids = ["#{parent_id}/backoffice", "#{parent_id}/recruiter"]

    Enum.each(child_ids, fn child_id ->
      case StudioJido.whereis(child_id) do
        nil -> :ok
        _pid -> StudioJido.stop_agent(child_id)
      end
    end)

    case StudioJido.whereis(parent_id) do
      nil -> :ok
      _pid -> StudioJido.stop_agent(parent_id)
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
