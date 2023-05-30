defmodule Fast.Utils.GoogleCloudLogger do
  @moduledoc """
  This simply extends `LoggerJSON.Formatters.GoogleCloudLogger` to
  include a log `@type` value for error logs that indicates to
  Stackdriver logging to consider the logentry a ReportedErrorEvent.
  """

  @behaviour LoggerJSON.Formatter

  @impl true
  def init(opts), do: LoggerJSON.Formatters.GoogleCloudLogger.init(opts)

  @impl true
  def format_event(:error, msg, ts, md, md_keys, formatter_state) do
    base =
      LoggerJSON.Formatters.GoogleCloudLogger.format_event(
        :error,
        msg,
        ts,
        md,
        md_keys,
        formatter_state
      )

    Map.merge(
      base,
      %{
        "@type" =>
          "type.googleapis.com/google.devtools.clouderrorreporting.v1beta1.ReportedErrorEvent"
      }
    )
  end

  @impl true
  def format_event(level, msg, ts, md, md_keys, formatter_state) do
    LoggerJSON.Formatters.GoogleCloudLogger.format_event(
      level,
      msg,
      ts,
      md,
      md_keys,
      formatter_state
    )
  end
end
