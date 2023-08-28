defmodule Fast.RateLimiter do
  @moduledoc """
  Wrapper around ExRated that allows env based config.
  """

  @app_name :fast

  @spec check_rate(String.t(), non_neg_integer(), non_neg_integer()) ::
          {:ok, :disabled | non_neg_integer()} | {:error, non_neg_integer()}
  def check_rate(bucket_id, window_ms, max_num_calls) do
    case disabled?() do
      true -> {:ok, :disabled}
      _ -> ExRated.check_rate(bucket_id, window_ms, max_num_calls)
    end
  end

  @spec reset(String.t()) :: :ok
  def reset(bucket_id) do
    ExRated.delete_bucket(bucket_id)
  end

  def disabled? do
    Application.get_env(@app_name, :disable_rate_limiter, false)
  end
end
