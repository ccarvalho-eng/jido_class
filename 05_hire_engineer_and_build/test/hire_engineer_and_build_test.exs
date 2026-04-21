defmodule HireEngineerAndBuildTest do
  use ExUnit.Case, async: false

  alias HireEngineerAndBuild.{CEOAgent, CTOAgent, StudioJido}
  alias Jido.AgentServer
  alias Jido.Signal

  test "ceo hires a cto as the technical boundary for the company" do
    ceo_id = unique_agent_id("ceo")

    on_exit(fn -> safe_stop_family(ceo_id) end)

    {:ok, pid} = StudioJido.start_agent(CEOAgent, id: ceo_id)

    {:ok, ceo} =
      AgentServer.call(
        pid,
        Signal.new!("studio.technical_leadership_requested", %{}, source: "/ceo")
      )

    assert ceo.state.leadership_team == ["cto"]

    runtime_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(pid)

        if Map.has_key?(state.children, :cto) and state.agent.state.leadership_boot_events != [] do
          state
        end
      end)

    assert runtime_state.children.cto.module == CTOAgent
    assert runtime_state.children.cto.id == "#{ceo_id}/cto"

    assert runtime_state.agent.state.leadership_boot_events == [
             %{child_id: "#{ceo_id}/cto", tag: "cto"}
           ]
  end

  test "cto owns the technical strategy and only reports an executive summary back to the ceo" do
    ceo_id = unique_agent_id("ceo-cto")

    on_exit(fn -> safe_stop_family(ceo_id) end)

    {:ok, pid} = StudioJido.start_agent(CEOAgent, id: ceo_id)

    {:ok, _ceo} =
      AgentServer.call(
        pid,
        Signal.new!("studio.technical_leadership_requested", %{}, source: "/ceo")
      )

    parent_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(pid)

        if Map.has_key?(state.children, :cto) do
          state
        end
      end)

    cto_pid = parent_state.children.cto.pid

    {:ok, _cto} =
      AgentServer.call(
        cto_pid,
        Signal.new!(
          "cto.technical_strategy_requested",
          %{
            milestone: "vertical slice",
            product_goal: "make combat feel responsive"
          },
          source: "/ceo"
        )
      )

    updated_parent_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(pid)

        if state.agent.state.executive_updates != [] do
          state
        end
      end)

    cto_runtime_state = wait_until(fn -> match_cto_plan(cto_pid) end)

    assert updated_parent_state.agent.state.executive_updates == [
             %{
               milestone: "vertical slice",
               architecture_focus: "combat pipeline",
               first_hire: "gameplay engineer",
               status: "technical_strategy_ready"
             }
           ]

    assert updated_parent_state.agent.state.technical_brief == "wait for the cto"

    assert cto_runtime_state.agent.state.technical_roadmap == [
             %{
               milestone: "vertical slice",
               architecture_focus: "combat pipeline",
               product_goal: "make combat feel responsive"
             }
           ]

    assert cto_runtime_state.agent.state.hiring_intent == ["gameplay engineer"]
  end

  defp match_cto_plan(cto_pid) do
    {:ok, state} = AgentServer.state(cto_pid)

    if state.agent.state.technical_roadmap != [] and state.agent.state.hiring_intent != [] do
      state
    end
  end

  defp unique_agent_id(prefix) do
    "#{prefix}-#{System.unique_integer([:positive])}"
  end

  defp safe_stop_family(parent_id) do
    child_ids = ["#{parent_id}/cto"]

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
