defmodule SpawnBackofficeAndRecruiter.BackofficeAgent do
  @moduledoc """
  Backoffice support agent for lesson 4.
  """

  use Jido.Agent,
    name: "backoffice",
    description: "Handles hiring constraints and admin preparation",
    default_plugins: false,
    schema: [
      hiring_budget: [type: :integer, default: 4_000],
      pending_hiring_reviews: [type: {:list, :string}, default: []]
    ]

  def signal_routes(_ctx) do
    [
      {"backoffice.hiring_review_requested",
       SpawnBackofficeAndRecruiter.Actions.PrepareHiringConstraints}
    ]
  end
end
