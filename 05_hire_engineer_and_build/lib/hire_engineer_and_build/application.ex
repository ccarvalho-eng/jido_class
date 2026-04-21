defmodule HireEngineerAndBuild.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HireEngineerAndBuild.StudioJido
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: HireEngineerAndBuild.Supervisor)
  end
end
