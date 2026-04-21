defmodule ProductDesignQaRhythm.ProductManagerAgent do
  @moduledoc """
  Product manager for lesson 7.

  This agent owns the recurring delivery loop across product, design, and QA.
  """

  use Jido.Agent,
    name: "product_manager",
    description: "Runs the recurring delivery rhythm for the studio",
    default_plugins: false,
    schema: [
      active_milestone: [type: :string, default: nil],
      player_promise: [type: :string, default: nil],
      target_cycles: [type: :integer, default: 0],
      review_cycles_completed: [type: :integer, default: 0],
      cadence_started: [type: :boolean, default: false],
      child_boot_events: [type: {:list, :map}, default: []],
      child_registry: [type: :map, default: %{}],
      cadence_events: [type: {:list, :map}, default: []],
      cycle_reviews: [type: :map, default: %{}],
      design_feedback: [type: {:list, :map}, default: []],
      playtest_reports: [type: {:list, :map}, default: []],
      review_history: [type: {:list, :map}, default: []]
    ]

  def signal_routes(_ctx) do
    [
      {"studio.delivery_rhythm_requested", ProductDesignQaRhythm.Actions.RequestDeliveryRhythm},
      {"jido.agent.child.started", ProductDesignQaRhythm.Actions.RecordRhythmChildStarted},
      {"product.review_cycle_tick", ProductDesignQaRhythm.Actions.RunReviewCycle},
      {"product.design_review_ready", ProductDesignQaRhythm.Actions.RecordDesignReviewReady},
      {"product.playtest_reported", ProductDesignQaRhythm.Actions.RecordPlaytestReported}
    ]
  end
end
