defmodule ProductDesignQaRhythmTest do
  use ExUnit.Case, async: false

  alias Jido.AgentServer
  alias Jido.Signal
  alias ProductDesignQaRhythm.{DesignerAgent, ProductManagerAgent, QAAgent, StudioJido}

  test "product manager brings design and qa online and arms the first review cycle" do
    product_id = unique_agent_id("product-manager")

    on_exit(fn -> safe_stop_family(product_id) end)

    {:ok, pm_pid} = StudioJido.start_agent(ProductManagerAgent, id: product_id)

    {:ok, manager} =
      AgentServer.call(
        pm_pid,
        Signal.new!(
          "studio.delivery_rhythm_requested",
          %{
            milestone: "vertical slice",
            player_promise: "make the first ten minutes readable and sticky",
            target_cycles: 2
          },
          source: "/ceo"
        )
      )

    assert manager.state.active_milestone == "vertical slice"
    assert manager.state.target_cycles == 2

    runtime_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(pm_pid)

        if Map.has_key?(state.children, :designer) and
             Map.has_key?(state.children, :qa) and
             state.agent.state.cadence_started do
          state
        end
      end)

    assert runtime_state.children.designer.module == DesignerAgent
    assert runtime_state.children.qa.module == QAAgent

    assert runtime_state.agent.state.child_boot_events == [
             %{child_id: "#{product_id}/designer", tag: "designer"},
             %{child_id: "#{product_id}/qa", tag: "qa"}
           ]

    assert Enum.any?(runtime_state.agent.state.cadence_events, fn event ->
             event == %{cycle: 1, stage: "cadence_armed"}
           end)
  end

  test "scheduled review cycles leave a visible product, design, and qa trail" do
    product_id = unique_agent_id("delivery-rhythm")

    on_exit(fn -> safe_stop_family(product_id) end)

    {:ok, pm_pid} = StudioJido.start_agent(ProductManagerAgent, id: product_id)

    {:ok, _manager} =
      AgentServer.call(
        pm_pid,
        Signal.new!(
          "studio.delivery_rhythm_requested",
          %{
            milestone: "vertical slice",
            player_promise: "make the first ten minutes readable and sticky",
            target_cycles: 2
          },
          source: "/ceo"
        )
      )

    final_pm_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(pm_pid)

        if state.agent.state.review_cycles_completed == 2 and
             length(state.agent.state.review_history) == 2 do
          state
        end
      end)

    designer_pid = final_pm_state.children.designer.pid
    qa_pid = final_pm_state.children.qa.pid

    {:ok, designer_state} = AgentServer.state(designer_pid)
    {:ok, qa_state} = AgentServer.state(qa_pid)

    assert length(designer_state.agent.state.review_briefs) == 2
    assert length(qa_state.agent.state.playtest_runs) == 2

    assert final_pm_state.agent.state.review_history == [
             %{
               cycle: 1,
               design_focus: "first-session clarity",
               playtest_finding: "players miss the promised hook in the first session",
               playtest_risk: "high",
               status: "ready_for_next_cycle"
             },
             %{
               cycle: 2,
               design_focus: "combat readability",
               playtest_finding: "players lose combat readability once the screen gets busy",
               playtest_risk: "medium",
               status: "cadence_complete"
             }
           ]

    assert final_pm_state.agent.state.review_cycles_completed == 2
    assert length(final_pm_state.agent.state.design_feedback) == 2
    assert length(final_pm_state.agent.state.playtest_reports) == 2

    assert Enum.member?(final_pm_state.agent.state.cadence_events, %{
             cycle: 1,
             stage: "review_cycle_started"
           })

    assert Enum.member?(final_pm_state.agent.state.cadence_events, %{
             cycle: 1,
             stage: "review_cycle_completed"
           })

    assert Enum.member?(final_pm_state.agent.state.cadence_events, %{
             cycle: 2,
             stage: "review_cycle_started"
           })

    assert Enum.member?(final_pm_state.agent.state.cadence_events, %{
             cycle: 2,
             stage: "review_cycle_completed"
           })
  end

  defp unique_agent_id(prefix) do
    "#{prefix}-#{System.unique_integer([:positive])}"
  end

  defp safe_stop_family(product_id) do
    child_ids = [
      "#{product_id}/designer",
      "#{product_id}/qa"
    ]

    Enum.each(child_ids, fn child_id ->
      case StudioJido.whereis(child_id) do
        nil -> :ok
        _pid -> StudioJido.stop_agent(child_id)
      end
    end)

    case StudioJido.whereis(product_id) do
      nil -> :ok
      _pid -> StudioJido.stop_agent(product_id)
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
