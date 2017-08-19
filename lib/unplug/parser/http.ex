defmodule Unplug.Parser.HTTP do
  def parse(msg) do
    decode({:start, msg}, %{})
  end

  defp decode({:start, msg}, headers) do
    :erlang.decode_packet(:httph, msg, [])
    |> decode(headers)
  end

  defp decode({:ok, {:http_header, _, field, _, value},  rest}, headers) do
    headers = Map.put(headers, field, value)

    :erlang.decode_packet(:httph, rest, [])
    |> decode(headers)
  end

  defp decode({:ok, :http_eoh, _rest}, headers) do
    {:ok, headers}
  end
end
