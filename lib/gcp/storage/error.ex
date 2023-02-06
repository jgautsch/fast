defmodule Fast.GCP.Storage.Client.Error do
  @type t :: {:error, binary, {:error, HTTPoison.Error.t()} | integer()}
end
