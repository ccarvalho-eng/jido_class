defmodule AIStudioMode.AIAdapter do
  @moduledoc """
  Small boundary for model access in lesson 8.
  """

  @callback generate_text(role :: String.t(), prompt :: String.t(), opts :: map()) ::
              {:ok, String.t()} | {:error, term()}
end
