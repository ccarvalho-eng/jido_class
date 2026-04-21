defmodule HireEngineerAndBuild.Actions.RecordChildStarted do
  @moduledoc """
  Records lifecycle signals when a leadership child comes online.
  """

  use Jido.Action,
    name: "record_child_started",
    description: "Stores leadership startup events emitted by child agents",
    schema: [
      child_id: [type: :string, required: true],
      tag: [type: :any, required: true]
    ]

  @impl true
  def run(%{child_id: child_id, tag: tag}, context) do
    events = Map.get(context.state, :leadership_boot_events, [])
    event = %{child_id: child_id, tag: normalize_tag(tag)}

    {:ok, %{leadership_boot_events: events ++ [event]}}
  end

  defp normalize_tag(tag) when is_atom(tag), do: Atom.to_string(tag)
  defp normalize_tag(tag), do: to_string(tag)
end
