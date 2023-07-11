defmodule Fast.Plug.RequestInfo do
  @behaviour Plug
  import Plug.Conn

  alias Fast.Audit.RequestInfo

  @default_geo_header "x-client-geo-latlong"

  def init(opts), do: opts

  def call(conn, opts) do
    [lat, lng] = get_geo_coords(conn, opts)
    client_location = get_geo_location(conn, opts)

    request_info = %RequestInfo{
      request_id: List.first(get_resp_header(conn, "x-request-id")),
      remote_ip: to_string(:inet_parse.ntoa(conn.remote_ip)),
      host: conn.host,
      origin: List.first(get_req_header(conn, "origin")),
      referer: List.first(get_req_header(conn, "referer")),
      latitude: lat,
      longitude: lng,
      client_location: client_location,
      user_agent: List.first(get_req_header(conn, "user-agent"))
    }

    assign(conn, :request_info, request_info)
  end

  defp get_geo_coords(%Plug.Conn{} = conn, opts) do
    header = Keyword.get(opts, :geo_header, @default_geo_header)

    case get_req_header(conn, header) do
      [latlong] when is_binary(latlong) ->
        if String.contains?(latlong, ",") do
          String.split(latlong, ",")
          |> Enum.map(&Float.parse/1)
          |> Enum.map(fn
            :error -> nil
            {f, _} -> f
          end)
        else
          [nil, nil]
        end

      _ ->
        [nil, nil]
    end
  end

  defp get_geo_location(%Plug.Conn{} = conn, opts) do
    header = Keyword.get(opts, :geo_header, @default_geo_header)

    case get_req_header(conn, header) do
      [] -> nil
      [""] -> nil
      [client_geo_location] -> client_geo_location
    end
  end
end
