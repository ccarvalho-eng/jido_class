defmodule AIStudioModeTest do
  use ExUnit.Case, async: false

  alias AIStudioMode.{CEOAgent, CTOAgent, DesignerAgent, ProductManagerAgent, QAAgent, StudioJido}
  alias Jido.AgentServer
  alias Jido.Signal

  test "ceo brings the ai staff online and product adds designer and qa" do
    ceo_id = unique_agent_id("ceo-ai")

    on_exit(fn -> safe_stop_family(ceo_id) end)

    {:ok, ceo_pid} = StudioJido.start_agent(CEOAgent, id: ceo_id)

    {:ok, ceo} =
      AgentServer.call(
        ceo_pid,
        Signal.new!("studio.ai_staff_requested", %{}, source: "/ceo")
      )

    assert ceo.state.leadership_team == ["cto", "product_manager"]

    ceo_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(ceo_pid)

        if Map.has_key?(state.children, :cto) and Map.has_key?(state.children, :product_manager) do
          state
        end
      end)

    pm_pid = ceo_state.children.product_manager.pid

    pm_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(pm_pid)

        if Map.has_key?(state.children, :designer) and Map.has_key?(state.children, :qa) do
          state
        end
      end)

    assert ceo_state.children.cto.module == CTOAgent
    assert ceo_state.children.product_manager.module == ProductManagerAgent
    assert pm_state.children.designer.module == DesignerAgent
    assert pm_state.children.qa.module == QAAgent
  end

  test "ai planning round aggregates technical and product alignment through runtime instructions" do
    ceo_id = unique_agent_id("ceo-round")

    on_exit(fn -> safe_stop_family(ceo_id) end)

    {:ok, ceo_pid} =
      StudioJido.start_agent(CEOAgent,
        id: ceo_id,
        initial_state: %{ai_adapter: AIStudioMode.AIAdapters.FakeAdapter}
      )

    {:ok, _ceo} =
      AgentServer.call(
        ceo_pid,
        Signal.new!("studio.ai_staff_requested", %{}, source: "/ceo")
      )

    ceo_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(ceo_pid)

        if Map.has_key?(state.children, :cto) and Map.has_key?(state.children, :product_manager) do
          state
        end
      end)

    pm_pid = ceo_state.children.product_manager.pid

    _pm_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(pm_pid)

        if Map.has_key?(state.children, :designer) and Map.has_key?(state.children, :qa) do
          state
        end
      end)

    {:ok, _ceo} =
      AgentServer.call(
        ceo_pid,
        Signal.new!(
          "studio.ai_planning_round_requested",
          %{
            round: 1,
            milestone: "vertical slice",
            player_promise: "make combat onboarding readable"
          },
          source: "/ceo"
        )
      )

    final_ceo_state =
      wait_until(fn ->
        {:ok, state} = AgentServer.state(ceo_pid)

        if length(state.agent.state.alignment_packets) == 1 do
          state
        end
      end)

    cto_pid = final_ceo_state.children.cto.pid
    {:ok, cto_state} = AgentServer.state(cto_pid)
    {:ok, pm_state} = AgentServer.state(pm_pid)
    {:ok, designer_state} = AgentServer.state(pm_state.children.designer.pid)
    {:ok, qa_state} = AgentServer.state(pm_state.children.qa.pid)

    assert final_ceo_state.agent.state.alignment_packets == [
             %{
               round: 1,
               technical_strategy:
                 "CTO draft: technical plan aligned to make combat onboarding readable",
               product_brief:
                 "Product draft: scope brief anchored in make combat onboarding readable",
               design_direction:
                 "Design draft: interaction direction that reinforces make combat onboarding readable",
               qa_summary:
                 "QA draft: playtest summary focused on protecting make combat onboarding readable",
               status: "alignment_packet_ready"
             }
           ]

    assert cto_state.agent.state.drafts == [
             %{
               round: 1,
               text: "CTO draft: technical plan aligned to make combat onboarding readable"
             }
           ]

    assert pm_state.agent.state.product_alignments == [
             %{
               round: 1,
               product_brief:
                 "Product draft: scope brief anchored in make combat onboarding readable",
               design_direction:
                 "Design draft: interaction direction that reinforces make combat onboarding readable",
               qa_summary:
                 "QA draft: playtest summary focused on protecting make combat onboarding readable",
               status: "product_alignment_ready"
             }
           ]

    assert designer_state.agent.state.drafts == [
             %{
               round: 1,
               text:
                 "Design draft: interaction direction that reinforces make combat onboarding readable"
             }
           ]

    assert qa_state.agent.state.drafts == [
             %{
               round: 1,
               text:
                 "QA draft: playtest summary focused on protecting make combat onboarding readable"
             }
           ]
  end

  defp unique_agent_id(prefix) do
    "#{prefix}-#{System.unique_integer([:positive])}"
  end

  defp safe_stop_family(ceo_id) do
    child_ids = [
      "#{ceo_id}/product_manager/designer",
      "#{ceo_id}/product_manager/qa",
      "#{ceo_id}/product_manager",
      "#{ceo_id}/cto"
    ]

    Enum.each(child_ids, fn child_id ->
      case StudioJido.whereis(child_id) do
        nil -> :ok
        _pid -> StudioJido.stop_agent(child_id)
      end
    end)

    case StudioJido.whereis(ceo_id) do
      nil -> :ok
      _pid -> StudioJido.stop_agent(ceo_id)
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
