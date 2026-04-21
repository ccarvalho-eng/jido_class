defmodule ProductDesignQaRhythm.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ProductDesignQaRhythm.StudioJido
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: ProductDesignQaRhythm.Supervisor
    )
  end
end
