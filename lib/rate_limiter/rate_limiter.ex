defmodule Fast.RateLimiter do
  @moduledoc """
  Wrapper around ExRated that allows env based config.
  """

  @app_name :fast

  def check_rate(bucket_id, window_ms, max_num_calls) do
    res = ExRated.check_rate(bucket_id, window_ms, max_num_calls)

    case disabled?() do
      true -> {:ok, -1}
      false -> res
    end
  end

  def disabled? do
    Application.get_env(@app_name, :disable_rate_limiter, false)
  end
end
