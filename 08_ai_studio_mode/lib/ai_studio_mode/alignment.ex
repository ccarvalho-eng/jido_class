defmodule AIStudioMode.Alignment do
  @moduledoc """
  Pure helpers for aggregating AI-assisted outputs in lesson 8.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  def leadership_child_started(state, child_id, tag) do
    tag_name = normalize_tag(tag)
    registry = Map.get(state, :child_registry, %{})
    events = Map.get(state, :child_boot_events, [])

    updates = %{
      child_registry: Map.put(registry, tag_name, child_id),
      child_boot_events: events ++ [%{child_id: child_id, tag: tag_name}]
    }

    case {tag_name, AIStudioMode.StudioJido.whereis(child_id)} do
      {"product_manager", pid} when is_pid(pid) ->
        signal = Signal.new!("product.ai_team_requested", %{}, source: "/ceo")
        {updates, [Directive.emit_to_pid(signal, pid)]}

      _ ->
        {updates, []}
    end
  end

  def product_child_started(state, child_id, tag) do
    tag_name = normalize_tag(tag)
    registry = Map.get(state, :child_registry, %{})
    events = Map.get(state, :child_boot_events, [])

    {%{
       child_registry: Map.put(registry, tag_name, child_id),
       child_boot_events: events ++ [%{child_id: child_id, tag: tag_name}]
     }, []}
  end

  def maybe_complete_product_alignment(state, round, agent) do
    existing = find_round(Map.get(state, :product_alignments, []), round)
    product = find_round(Map.get(state, :product_briefs, []), round)
    design = find_round(Map.get(state, :design_directions, []), round)
    qa = find_round(Map.get(state, :qa_summaries, []), round)

    cond do
      existing != nil ->
        {%{}, []}

      is_nil(product) or is_nil(design) or is_nil(qa) ->
        {%{}, []}

      true ->
        snapshot = %{
          round: round,
          product_brief: product.text,
          design_direction: design.text,
          qa_summary: qa.text,
          status: "product_alignment_ready"
        }

        signal =
          Signal.new!(
            "studio.product_alignment_received",
            snapshot,
            source: "/product_manager"
          )

        {%{product_alignments: Map.get(state, :product_alignments, []) ++ [snapshot]},
         List.wrap(Directive.emit_to_parent(agent, signal))}
    end
  end

  def maybe_complete_company_alignment(state, round) do
    existing = find_round(Map.get(state, :alignment_packets, []), round)
    technical = find_round(Map.get(state, :technical_updates, []), round)
    product = find_round(Map.get(state, :product_updates, []), round)

    cond do
      existing != nil ->
        %{}

      is_nil(technical) or is_nil(product) ->
        %{}

      true ->
        %{
          alignment_packets:
            Map.get(state, :alignment_packets, []) ++
              [
                %{
                  round: round,
                  technical_strategy: technical.technical_strategy,
                  product_brief: product.product_brief,
                  design_direction: product.design_direction,
                  qa_summary: product.qa_summary,
                  status: "alignment_packet_ready"
                }
              ]
        }
    end
  end

  def find_round(entries, round) when is_list(entries) do
    Enum.find(entries, &(&1.round == round))
  end

  defp normalize_tag(tag) when is_atom(tag), do: Atom.to_string(tag)
  defp normalize_tag(tag), do: to_string(tag)
end
