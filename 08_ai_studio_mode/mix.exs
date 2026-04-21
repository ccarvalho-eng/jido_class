defmodule AIStudioMode.MixProject do
  use Mix.Project

  def project do
    [
      app: :ai_studio_mode,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {AIStudioMode.Application, []}
    ]
  end

  defp deps do
    [
      {:jido, "~> 2.2"},
      {:req_llm, "~> 1.10"}
    ]
  end
end
