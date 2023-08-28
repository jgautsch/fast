defmodule Fast.RateLimiterTest do
  use ExUnit.Case, async: false
  alias Fast.RateLimiter

  @bucket "test"

  describe inspect(&RateLimiter.check_rate/3) do
    setup do
      val = Application.get_env(:fast, :disable_rate_limiter)
      RateLimiter.reset(@bucket)

      on_exit(fn ->
        RateLimiter.reset(@bucket)
        Application.put_env(:fast, :disable_rate_limiter, val)
      end)

      :ok
    end

    test "returns {:ok, :disabled} when rate limiter is disabled" do
      Application.put_env(:fast, :disable_rate_limiter, true)

      assert {:ok, :disabled} == RateLimiter.check_rate(@bucket, 1000, 5)
    end

    test "returns {:ok, remaining} when rate limiter is enabled and limit is not exceeded" do
      Application.put_env(:fast, :disable_rate_limiter, false)

      for i <- 1..5 do
        assert {:ok, i} == RateLimiter.check_rate(@bucket, 1000, 5)
      end
    end

    test "returns {:error, count} when rate limiter is enabled and limit is exceeded" do
      Application.put_env(:fast, :disable_rate_limiter, false)

      RateLimiter.check_rate(@bucket, 1000, 1)
      assert {:error, 1} == RateLimiter.check_rate(@bucket, 1000, 1)
    end
  end

  describe inspect(&RateLimiter.reset/1) do
    setup do
      RateLimiter.reset(@bucket)
      RateLimiter.check_rate(@bucket, 1000, 2)
      :ok
    end

    test "resets the rate limiter" do
      assert {:ok, 2} == RateLimiter.check_rate(@bucket, 1000, 2)
      assert {:error, 2} == RateLimiter.check_rate(@bucket, 1000, 2)
      assert :ok = RateLimiter.reset(@bucket)
      assert {:ok, 1} == RateLimiter.check_rate(@bucket, 1000, 2)
    end
  end
end
