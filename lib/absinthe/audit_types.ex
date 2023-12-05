defmodule FastWeb.Schema.AuditTypes do
  use Absinthe.Schema.Notation

  object :request_info do
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
end
