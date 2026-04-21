defmodule FounderRuntime.MixProject do
  use Mix.Project

  def project do
    [
      app: :founder_runtime,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {FounderRuntime.Application, []}
    ]
  end

  defp deps do
    [
      {:jido, "~> 2.2"}
    ]
  end
end
