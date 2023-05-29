defmodule Fast.RepoTest do
  use ExUnit.Case, async: true

  defmodule Mock.Ecto.Repo do
    def transaction(fun, _opts), do: fun.()
    def rollback(reason), do: {:error, reason}
    def query(_sql, _params), do: {:ok, %{rows: []}}
    def preload(_query, _preloads), do: {:ok, []}
    def all(_query, _opts), do: {:ok, []}
  end

  defmodule Test.Repo do
    use Fast.Repo, otp_app: :fast, repo_module: Mock.Ecto.Repo
  end

  describe "transact/2" do
    test "commits the transaction if the lambda returns {:ok, result}" do
      assert {:ok, 123} ==
               Test.Repo.transact(fn ->
                 {:ok, 123}
               end)
    end

    test "rolls back the transaction if the lambda returns {:error, reason}" do
      assert {:error, :reason} ==
               Test.Repo.transact(fn ->
                 {:error, :reason}
               end)
    end

    test "rolls back the transaction if the lambda returns :error" do
      assert {:error, :transaction_rollback_error} ==
               Test.Repo.transact(fn ->
                 :error
               end)
    end
  end
end
