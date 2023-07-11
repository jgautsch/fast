defmodule Fast.Ecto.Changeset do
  import Ecto.Changeset

  alias Fast.Auth.DisposableEmail
  alias Fast.PhoneNumbers

  def maybe_set_field_update_time(
        %{changes: changes} = changeset,
        changed_field,
        changed_at_field,
        opts \\ []
      ) do
    only_on = Access.get(opts, :only_on, :any)

    field_is_changing =
      changes
      |> Map.keys()
      |> Enum.member?(changed_field)

    if field_is_changing && (only_on == :any || changeset.action in only_on) do
      {:ok, now} = Ecto.Type.cast(:utc_datetime, DateTime.utc_now())

      changeset
      |> put_change(changed_at_field, now)
    else
      changeset
    end
  end

  @doc """
  Trims the string value of the fields if they have a change for the given field key.

  Example Usage:

    changeset
    |> maybe_trim([:first_name, :last_name])

  """
  def maybe_trim(changeset, fields) do
    fields
    |> Enum.reduce(changeset, fn field, changeset ->
      update_change(changeset, field, fn
        str when is_binary(str) -> String.trim(str)
        val -> val
      end)
    end)
  end

  def downcase(changeset, field) do
    case get_field(changeset, field) do
      nil ->
        changeset

      str when is_binary(str) ->
        changeset
        |> put_change(field, String.downcase(str))
    end
  end

  def titlecase(changeset, field) do
    case get_field(changeset, field) do
      nil ->
        changeset

      str when is_binary(str) ->
        changeset
        |> put_change(field, Fast.String.titlecase(str))
    end
  end

  def inflect_title_acronyms(changeset, field) do
    case get_field(changeset, field) do
      nil ->
        changeset

      str when is_binary(str) ->
        changeset
        |> put_change(field, Fast.String.inflect_title_acronyms(str))
    end
  end

  def inflect_address_acronyms(changeset, field) do
    case get_field(changeset, field) do
      nil ->
        changeset

      str when is_binary(str) ->
        changeset
        |> put_change(field, Fast.String.inflect_address_acronyms(str))
    end
  end

  def validate_is_non_disposable_email(changeset, field, options \\ []) do
    Ecto.Changeset.validate_change(changeset, field, fn _, email_address ->
      case DisposableEmail.is_disposable?(email_address) do
        true -> [{field, options[:message] || "domain is not allowed"}]
        false -> []
      end
    end)
  end

  def validate_password_rules(%{changes: changes} = changeset, field, _opts \\ []) do
    if field not in Map.keys(changes) do
      changeset
    else
      changeset
      |> validate_length(field, min: 8)
      |> validate_contains_alphabetic_character(field)
      |> validate_contains_numeric_character(field)
      |> validate_contains_special_character(field)
    end
  end

  def validate_contains_alphabetic_character(changeset, field, opts \\ []) do
    message = Keyword.get(opts, :message, "must contain at least one alphabetic character")

    changeset
    |> validate_format(field, ~r/[a-zA-Z]+/, message: message)
  end

  def validate_contains_numeric_character(changeset, field, opts \\ []) do
    message = Keyword.get(opts, :message, "must contain at least 1 number character")

    changeset
    |> validate_format(field, ~r/[0-9]+/, message: message)
  end

  def validate_contains_special_character(changeset, field, opts \\ []) do
    message =
      Keyword.get(
        opts,
        :message,
        "must contain at least 1 special character (e.g. ! @ # $ % ^ & * etc.)"
      )

    changeset
    |> validate_format(field, ~r/[-!$%^&*()_+|~=`{}\[\]:\/;<>?,.@#]+/, message: message)
  end

  def validate_is_hex_color_code(changeset, field, opts \\ []) do
    # opts = Keyword.put_new(opts, :message, "invalid hex color")
    format = ~r/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/
    validate_format(changeset, field, format, opts)
  end

  def validate_phone_number(changeset, field, opts \\ []) do
    Ecto.Changeset.validate_change(changeset, field, fn
      _, nil = _phone_number ->
        []

      _, phone_number ->
        case PhoneNumbers.valid?(phone_number) do
          false -> [{field, opts[:message] || "invalid phone number"}]
          true -> []
        end
    end)
  end

  def normalize_phone_number(%{valid?: false} = changeset, _field), do: changeset

  def normalize_phone_number(%{valid?: true} = changeset, field) do
    normalized =
      changeset
      |> Ecto.Changeset.get_field(field)
      |> PhoneNumbers.unformat()

    changeset
    |> Ecto.Changeset.put_change(field, normalized)
  end

  def default_value(changeset, field, value) do
    put_new(changeset, field, value)
  end

  def put_new(changeset, field, value) do
    case get_field(changeset, field) do
      nil ->
        changeset
        |> put_change(field, value)

      _ ->
        changeset
    end
  end

  def put_hash(changeset, field, opts \\ [])

  def put_hash(
        %Ecto.Changeset{valid?: true, changes: changes} = changeset,
        field,
        opts
      ) do
    hash_key = Keyword.get(opts, :hash_key, :hashed_password)
    clear_fields = Keyword.get(opts, :clear, [])

    if field in Map.keys(changes) do
      value = Map.fetch!(changes, field)
      changes = Map.drop(changes, clear_fields)

      changeset
      |> Map.put(:changes, changes)
      |> change(Bcrypt.add_hash(value, hash_key: hash_key))
    else
      changeset
    end
  end

  def put_hash(changeset, _field, _opts), do: changeset

  def require_one_of(changeset, fields, opts \\ [])
  def require_one_of(changeset, [] = _fields, _opts), do: changeset

  def require_one_of(changeset, fields, opts) when not is_nil(fields) do
    trim = Keyword.get(opts, :trim, true)
    fields = List.wrap(fields)

    if Enum.all?(fields, &missing?(changeset, &1, trim)) do
      field_list =
        fields
        |> Enum.map(&inspect(&1))
        |> Enum.join(", ")

      default_message = "one of these must be present: #{field_list}"
      message = message(opts, default_message)
      Ecto.Changeset.add_error(changeset, hd(fields), message)
    else
      changeset
    end
  end

  defp missing?(changeset, field, trim) when is_atom(field) do
    case get_field(changeset, field) do
      %{__struct__: Ecto.Association.NotLoaded} ->
        raise ArgumentError,
              "attempting to validate association `#{field}` " <>
                "that was not loaded. Please preload your associations " <>
                "before calling validate_required/3 or pass the :required " <>
                "option to Ecto.Changeset.cast_assoc/3"

      value when is_binary(value) and trim ->
        String.trim_leading(value) == ""

      value when is_binary(value) ->
        value == ""

      nil ->
        true

      _ ->
        false
    end
  end

  defp missing?(_changeset, field, _trim) do
    raise ArgumentError,
          "validate_required/3 expects field names to be atoms, got: `#{inspect(field)}`"
  end

  defp message(opts, key \\ :message, default) do
    Keyword.get(opts, key, default)
  end
end
