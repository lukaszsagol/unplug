defmodule Unplug.Responder.Handshake do
  require Logger
  @magic_string "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

  def call(headers) do
    Logger.info("Headers: #{inspect headers}")
    verify_headers(headers)
    |> generate_response(headers)
  end

  def generate_response(true, headers) do
    response = [""]
    |> put_ws_accept_header(headers)
    |> put_ws_extensions(headers)
    |> put_connection_header
    |> put_upgrade_header
    |> put_http_code

    {:reply, Enum.join(response, "\r\n")}
  end

  def generate_response(false, _) do
    {:close, "HTTP/1.1 400 Bad Request"}
  end

  defp put_http_code(response) do
    ["HTTP/1.1 101 Switching Protocols" | response]
  end

  defp put_upgrade_header(response) do
    ["Upgrade: websocket" | response]
  end

  defp put_connection_header(response) do
    ["Connection: Upgrade" | response]
  end

  defp put_ws_accept_header(response, headers) do
    ["Sec-WebSocket-Accept: #{generate_sec(headers)}"| response]
  end

  defp put_ws_extensions(response, headers = %{'Sec-Websocket-Extensions' => ext}) do
    ["Sec-WebSocket-Extensions: #{ext}" | response]
  end

  defp verify_headers(headers) do
    {_, correct} = {headers, true}
    |> verify_upgrade_header
    |> verify_connection_header
    |> verify_ws_version_header

    correct
  end

  defp verify_upgrade_header({headers, value}) do
    Logger.info("Upgrade: #{headers[:Upgrade]}")
    {headers, value && headers[:Upgrade] == 'websocket'}
  end

  defp verify_connection_header({headers, value}) do
    Logger.info("Connection: #{headers[:Connection]}")
    {headers, value && headers[:Connection] == 'Upgrade'}
  end

  defp verify_ws_version_header({headers, value}) do
    Logger.info("Version: #{headers['Sec-Websocket-Version']}")
    {headers, value && headers['Sec-Websocket-Version'] == '13'}
  end

  defp generate_sec(%{'Sec-Websocket-Key' => key}) do
    string = "#{key}#{@magic_string}"
    :crypto.hash(:sha, string)
    |> Base.encode64
  end
end
