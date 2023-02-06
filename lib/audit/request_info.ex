defmodule Fast.Audit.RequestInfo do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @primary_key false
  embedded_schema do
    field :request_id, :string
    field :ip_address, :string
    field :remote_ip, :string
    field :host, :string
    field :origin, :string
    field :referer, :string
    field :latitude, :float
    field :longitude, :float
    field :client_location, :string
    field :user_agent, :string
  end

  def changeset(request_info, attrs) do
    request_info
    |> cast(attrs, [
      :request_id,
      :ip_address,
      :remote_ip,
      :referer,
      :host,
      :latitude,
      :longitude,
      :user_agent
    ])
    |> validate_required([
      :request_id,
      :host,
      :user_agent
    ])
  end
end
