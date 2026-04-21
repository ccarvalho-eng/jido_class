defmodule AIStudioMode.AIAdapters.ReqLLMOllamaAdapter do
  @moduledoc """
  Optional adapter that talks to a local Ollama server through ReqLLM.
  """

  @behaviour AIStudioMode.AIAdapter

  @impl true
  def generate_text(_role, prompt, opts) do
    model_name = Map.get(opts, :model, "llama3")
    base_url = Map.get(opts, :base_url, "http://localhost:11434/v1")

    model =
      ReqLLM.model!(%{
        id: model_name,
        provider: :openai,
        base_url: base_url
      })

    case ReqLLM.generate_text(model, prompt) do
      {:ok, response} -> {:ok, extract_text(response)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp extract_text(response) do
    response
    |> Map.from_struct()
    |> then(fn payload ->
      payload[:text] || payload[:output_text] || inspect(response)
    end)
  rescue
    Protocol.UndefinedError ->
      Map.get(response, :text) || Map.get(response, :output_text) || inspect(response)
  end
end
