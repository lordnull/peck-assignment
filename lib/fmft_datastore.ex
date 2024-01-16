defmodule Fmft.Datastore do
  def default_file_path do
    "Mobile_Food_Facility_Permit.csv"
  end

  def read_file(file_path) do
    file_path =
      case file_path do
        nil ->
          default_file_path()

        _ ->
          file_path
      end

    File.stream!(file_path) |> CSV.decode() |> Enum.to_list()
  end
end
