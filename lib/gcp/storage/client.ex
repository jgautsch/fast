defmodule Fast.GCP.Storage.Client do
  @moduledoc """
  Client for Google Cloud Storage JSON API V1.

  https://cloud.google.com/storage/docs/downloading-objects

  curl -X GET \
    -H "Authorization: Bearer [OAUTH2_TOKEN]" \
    -o "[SAVE_TO_LOCATION]" \
    "https://www.googleapis.com/storage/v1/b/[BUCKET_NAME]/o/[OBJECT_NAME]?alt=media"
  """

  alias Fast.GCP.Storage.Client.Success
  alias Fast.GCP.Storage.Client.Error

  def download_blob(bucket_name, remote_file_name) do
    encoded_file_name = URI.encode_www_form(remote_file_name)
    get("/#{bucket_name}/o/#{encoded_file_name}?alt=media")
  end

  def list_objects(bucket_name) do
    get("/#{bucket_name}/o")
  end

  @spec get(binary, keyword) :: Success.t() | Error.t()
  def get(path, options \\ []), do: call(:get, path, options)

  def post(path, data, options \\ []), do: call(:post, path, data, options)

  def put(path, data, options \\ []), do: call(:put, path, data, options)

  defp call(method, path, options) do
    headers = [auth_header()]

    apply(HTTPoison, method, [url(path), headers, options])
    |> handle_response
  end

  defp call(method, path, data, options) do
    headers = [auth_header(), {"content-type", "application/json"}]

    apply(HTTPoison, method, [url(path), encode!(data), headers, options])
    |> handle_response()
  end

  defp url(path), do: Path.join([endpoint(), path])

  defp endpoint,
    do:
      Application.get_env(
        :google_cloud_storage,
        :endpoint,
        "https://www.googleapis.com/storage/v1/b"
      )

  defp token_mod, do: Application.get_env(:google_cloud_storage, :token, Goth.Token)

  defp auth_header do
    {:ok, token} = token_mod().for_scope(oauth_scope())
    {"Authorization", "#{token.type} #{token.token}"}
  end

  defp oauth_scope() do
    "https://www.googleapis.com/auth/devstorage.read_only"
  end

  defp handle_response({:ok, response}), do: handle_status(response)
  defp handle_response(err), do: err

  defp handle_status(response) do
    case response.status_code do
      code when code in 200..299 ->
        {:ok, response.body, code}

      err ->
        {:error, response.body, err}
    end
  end

  defp encode!(""), do: ""
  defp encode!(data), do: Jason.encode!(data)
end
