defmodule Fast.Repo do
  @moduledoc """
  Shared functionality for a Repo.
  """

  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    adapter = Keyword.get(opts, :adapter, Ecto.Adapters.Postgres)
    repo_module = Keyword.get(opts, :repo_module)

    quote location: :keep do
      use Ecto.Repo,
        otp_app: unquote(otp_app),
        adapter: unquote(adapter)

      @repo unquote(repo_module) || __MODULE__

      @doc """
      A small wrapper around `Repo.transaction/2`.

      Commits the transsaction if the lambda returns `{:ok, result}`, rolling it
      back if the lambda returns `{:error, reason}`. In both cases, the function
      returns the result of the lambda.
      """
      @spec transact((() -> any()), keyword()) :: {:ok, any()} | {:error, any()}
      def transact(fun, opts \\ []) do
        @repo.transaction(
          fn ->
            case fun.() do
              {:ok, value} -> {:ok, value}
              :ok -> :ok
              {:error, reason} -> @repo.rollback(reason)
              :error -> @repo.rollback(:transaction_rollback_error)
            end
          end,
          opts
        )
      end

      def stream_preload(stream, size, preloads) do
        stream
        |> Stream.chunk_every(size)
        |> Stream.flat_map(fn chunk ->
          @repo.preload(chunk, preloads)
        end)
      end

      def explain(query) do
        {sql, params} = Ecto.Adapters.SQL.to_sql(:all, @repo, query)
        {:ok, %{rows: rows}} = @repo.query("EXPLAIN ANALYZE " <> sql, params)
        IO.puts(Enum.join(rows, "\n"))
      end

      def all_by_ids(queryable, ids, opts \\ []) when is_list(ids) do
        import Ecto.Query

        from(r in queryable)
        |> where([r], r.id in ^ids)
        |> select([r], {r.id, r})
        |> @repo.all(opts)
        |> Enum.into(%{})
      end
    end
  end
end
