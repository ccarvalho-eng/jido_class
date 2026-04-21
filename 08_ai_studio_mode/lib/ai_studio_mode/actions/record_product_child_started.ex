defmodule AIStudioMode.Actions.RecordProductChildStarted do
  @moduledoc """
  Records designer and QA startup events.
  """

  alias AIStudioMode.Alignment

  use Jido.Action,
    name: "record_product_child_started",
    description: "Stores product-team startup events",
    schema: [
      child_id: [type: :string, required: true],
      tag: [type: :any, required: true]
    ]

  @impl true
  def run(%{child_id: child_id, tag: tag}, context) do
    {updates, directives} = Alignment.product_child_started(context.state, child_id, tag)
    {:ok, updates, directives}
  end
end
