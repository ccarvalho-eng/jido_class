defmodule ProductDesignQaRhythm.Cadence do
  @moduledoc """
  Pure helpers for the recurring review loop managed by the product manager.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  @cycle_delay_ms 10

  def child_started(state, child_id, tag) do
    tag_name = normalize_tag(tag)
    events = Map.get(state, :child_boot_events, [])
    registry = Map.get(state, :child_registry, %{})
    cadence_events = Map.get(state, :cadence_events, [])
    cadence_started = Map.get(state, :cadence_started, false)

    updated_registry = Map.put(registry, tag_name, child_id)
    event = %{child_id: child_id, tag: tag_name}

    updates = %{
      child_boot_events: events ++ [event],
      child_registry: updated_registry
    }

    cond do
      cadence_started ->
        {updates, []}

      Map.has_key?(updated_registry, "designer") and Map.has_key?(updated_registry, "qa") ->
        signal =
          Signal.new!("product.review_cycle_tick", %{cycle: 1}, source: "/product_manager")

        cadence_event = %{cycle: 1, stage: "cadence_armed"}

        {Map.merge(updates, %{
           cadence_started: true,
           cadence_events: cadence_events ++ [cadence_event]
         }), [Directive.schedule(@cycle_delay_ms, signal)]}

      true ->
        {updates, []}
    end
  end

  def record_design_review(state, params) do
    feedback = Map.get(state, :design_feedback, [])
    reviews = Map.get(state, :cycle_reviews, %{})

    updated_reviews =
      Map.update(reviews, params.cycle, %{design: params, qa: nil}, fn review ->
        Map.put(review, :design, params)
      end)

    updates = %{
      design_feedback: feedback ++ [params],
      cycle_reviews: updated_reviews
    }

    {follow_up_updates, directives} =
      finalize_cycle(Map.merge(state, updates), params.cycle, "design_review_ready")

    {Map.merge(updates, follow_up_updates), directives}
  end

  def record_playtest_report(state, params) do
    reports = Map.get(state, :playtest_reports, [])
    reviews = Map.get(state, :cycle_reviews, %{})

    updated_reviews =
      Map.update(reviews, params.cycle, %{design: nil, qa: params}, fn review ->
        Map.put(review, :qa, params)
      end)

    updates = %{
      playtest_reports: reports ++ [params],
      cycle_reviews: updated_reviews
    }

    {follow_up_updates, directives} =
      finalize_cycle(Map.merge(state, updates), params.cycle, "playtest_reported")

    {Map.merge(updates, follow_up_updates), directives}
  end

  defp finalize_cycle(state, cycle, event_stage) do
    cadence_events = Map.get(state, :cadence_events, [])
    cycle_reviews = Map.get(state, :cycle_reviews, %{})
    completed_cycles = Map.get(state, :review_cycles_completed, 0)
    target_cycles = Map.get(state, :target_cycles, 0)
    review_history = Map.get(state, :review_history, [])

    cycle_state = Map.get(cycle_reviews, cycle, %{})

    updates = %{
      cadence_events: cadence_events ++ [%{cycle: cycle, stage: event_stage}]
    }

    case cycle_state do
      %{design: %{focus: focus}, qa: %{finding: finding, risk: risk}} ->
        next_completed_cycles = completed_cycles + 1
        next_cycle = cycle + 1

        status =
          if next_completed_cycles == target_cycles do
            "cadence_complete"
          else
            "ready_for_next_cycle"
          end

        snapshot = %{
          cycle: cycle,
          design_focus: focus,
          playtest_finding: finding,
          playtest_risk: risk,
          status: status
        }

        completion_event = %{cycle: cycle, stage: "review_cycle_completed"}

        directives =
          if next_completed_cycles < target_cycles do
            signal =
              Signal.new!("product.review_cycle_tick", %{cycle: next_cycle},
                source: "/product_manager"
              )

            [Directive.schedule(@cycle_delay_ms, signal)]
          else
            []
          end

        updates =
          Map.merge(updates, %{
            review_cycles_completed: next_completed_cycles,
            review_history: review_history ++ [snapshot],
            cadence_events: updates.cadence_events ++ [completion_event]
          })

        {updates, directives}

      _incomplete ->
        {updates, []}
    end
  end

  defp normalize_tag(tag) when is_atom(tag), do: Atom.to_string(tag)
  defp normalize_tag(tag), do: to_string(tag)
end
