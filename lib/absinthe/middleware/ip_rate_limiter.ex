defmodule Fast.Absinthe.Middleware.IpRateLimiter do
  @behaviour Absinthe.Middleware

  require Logger

  alias Fast.Audit.RequestInfo
  alias Fast.RateLimiter

  def call(resolution, opts) do
    action = Keyword.fetch!(opts, :action)
    window_ms = Keyword.fetch!(opts, :window_ms)
    max_num_calls = Keyword.fetch!(opts, :max_num_calls)

    case resolution.context[:request_info] do
      %RequestInfo{remote_ip: remote_ip} when is_binary(remote_ip) ->
        key = "#{action}:#{remote_ip}"

        case RateLimiter.check_rate(key, window_ms, max_num_calls) do
          {:ok, _num_calls} -> resolution
          {:error, _count} -> put_rate_limit_exceeded(resolution, action)
        end

      _ ->
        Logger.warn("[Fast.Absinthe.Middleware.IpRateLimiter]: Request info not found in context")
        resolution
    end
  end

  defp put_rate_limit_exceeded(resolution, action) do
    resolution
    |> Absinthe.Resolution.put_result(
      {:error,
       %{
         message: "Rate limit exceeded for action: #{action}",
         extensions: %{code: "RATE_LIMIT_EXCEEDED"}
       }}
    )
  end
end
