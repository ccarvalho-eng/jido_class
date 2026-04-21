defmodule EngineeringOrgTest do
  use ExUnit.Case, async: false

  alias EngineeringOrg.{CTOAgent, EngineerAgent, EngineeringManagerAgent, StudioJido}
  alias Jido.AgentServer
  alias Jido.Signal

  test "cto adds an engineering manager as the first execution layer" do
    cto_id = unique_agent_id("cto")

    on_exit(fn -> safe_stop_family(cto_id) end)

    {:ok, pid} = StudioJido.start_agent(CTOAgent, id: cto_id)

    {:ok, cto} =
      AgentServer.call(
        pid,
        Signal.new!("studio.execution_layer_requested", %{}, source: "/cto")
      )

    assert cto.state.execution_team == ["engineering_manager"]

    runtime_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(pid)

        if Map.has_key?(state.children, :engineering_manager) and
             state.agent.state.execution_boot_events != [] do
          state
        end
      end)

    assert runtime_state.children.engineering_manager.module == EngineeringManagerAgent
    assert runtime_state.children.engineering_manager.id == "#{cto_id}/engineering_manager"

    assert runtime_state.agent.state.execution_boot_events == [
             %{child_id: "#{cto_id}/engineering_manager", tag: "engineering_manager"}
           ]
  end

  test "engineering manager fans work out to engineers and aggregates delivery back to the cto" do
    cto_id = unique_agent_id("cto-org")

    on_exit(fn -> safe_stop_family(cto_id) end)

    {:ok, cto_pid} = StudioJido.start_agent(CTOAgent, id: cto_id)

    {:ok, _cto} =
      AgentServer.call(
        cto_pid,
        Signal.new!("studio.execution_layer_requested", %{}, source: "/cto")
      )

    cto_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(cto_pid)

        if Map.has_key?(state.children, :engineering_manager) do
          state
        end
      end)

    manager_pid = cto_state.children.engineering_manager.pid

    {:ok, _manager} =
      AgentServer.call(
        manager_pid,
        Signal.new!(
          "engineering.team_bootstrap_requested",
          %{milestone: "vertical slice"},
          source: "/cto"
        )
      )

    manager_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(manager_pid)

        if Map.has_key?(state.children, :gameplay_engineer) and
             Map.has_key?(state.children, :ui_engineer) and
             state.agent.state.engineer_boot_events != [] do
          state
        end
      end)

    gameplay_pid = manager_state.children.gameplay_engineer.pid
    ui_pid = manager_state.children.ui_engineer.pid

    assert manager_state.children.gameplay_engineer.module == EngineerAgent
    assert manager_state.children.ui_engineer.module == EngineerAgent

    {:ok, _engineer} =
      AgentServer.call(
        gameplay_pid,
        Signal.new!(
          "engineer.task_assigned",
          %{task: "combat timing pass", deliverable: "combat loop feels responsive"},
          source: "/engineering_manager"
        )
      )

    {:ok, _engineer} =
      AgentServer.call(
        ui_pid,
        Signal.new!(
          "engineer.task_assigned",
          %{task: "hud readability pass", deliverable: "combat hud is legible"},
          source: "/engineering_manager"
        )
      )

    final_manager_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(manager_pid)

        if state.agent.state.completed_reports |> length() == 2 do
          state
        end
      end)

    final_cto_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(cto_pid)

        if state.agent.state.milestone_snapshots != [] do
          state
        end
      end)

    assert final_manager_state.agent.state.completed_reports == [
             %{
               discipline: "gameplay",
               deliverable: "combat loop feels responsive",
               task: "combat timing pass"
             },
             %{
               discipline: "ui",
               deliverable: "combat hud is legible",
               task: "hud readability pass"
             }
           ]

    assert final_cto_state.agent.state.milestone_snapshots == [
             %{
               milestone: "vertical slice",
               engineers_completed: 2,
               disciplines: ["gameplay", "ui"],
               status: "execution_snapshot_ready"
             }
           ]
  end

  defp unique_agent_id(prefix) do
    "#{prefix}-#{System.unique_integer([:positive])}"
  end

  defp safe_stop_family(cto_id) do
    child_ids = [
      "#{cto_id}/engineering_manager/gameplay_engineer",
      "#{cto_id}/engineering_manager/ui_engineer",
      "#{cto_id}/engineering_manager"
    ]

    Enum.each(child_ids, fn child_id ->
      case StudioJido.whereis(child_id) do
        nil -> :ok
        _pid -> StudioJido.stop_agent(child_id)
      end
    end)

    case StudioJido.whereis(cto_id) do
      nil -> :ok
      _pid -> StudioJido.stop_agent(cto_id)
    end
  end

  defp wait_until(fun, attempts \\ 40)

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
