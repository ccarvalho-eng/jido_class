defmodule ProductDesignQaRhythm.DesignerAgent do
  @moduledoc """
  Designer for lesson 7.

  This agent shapes the player-facing response for each review cycle.
  """

  use Jido.Agent,
    name: "designer",
    description: "Owns player-facing design iterations during the review rhythm",
    default_plugins: false,
    schema: [
      review_briefs: [type: {:list, :map}, default: []]
    ]

  def signal_routes(_ctx) do
    [
      {"design.review_cycle_requested", ProductDesignQaRhythm.Actions.PrepareDesignReview}
    ]
  end
end
