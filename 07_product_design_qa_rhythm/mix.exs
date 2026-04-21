defmodule ProductDesignQaRhythm.MixProject do
  use Mix.Project

  def project do
    [
      app: :product_design_qa_rhythm,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ProductDesignQaRhythm.Application, []}
    ]
  end

  defp deps do
    [
      {:jido, "~> 2.2"}
    ]
  end
end
