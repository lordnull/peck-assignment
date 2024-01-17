defmodule Fmft.Datastore do
  use Agent
  import Kernel

  @default_file_path "Mobile_Food_Facility_Permit.csv"

  defstruct [file_path: @default_file_path, data_store: %{}]

  def read_file() do
    read_file(@default_file_path)
  end
  def read_file(file_path) do
    File.stream!(file_path) |> CSV.decode!() |> Enum.to_list()
  end

  def start_link() do
    start_link(%{})
  end
  def start_link(opts) do
    init_state = state_from_opts(opts)
    Agent.start_link(fn -> init_state |> init_ets end)
  end

  def state_from_opts(opts) do
    Enum.reduce(opts, __struct__(), fn ({k, v}, state) -> state_from_opts(k, v, state) end)
  end

  def state_from_opts(:file_path, file_path, state) do
    %{ state | file_path: file_path}
  end

  def init_ets(state) do
    rows = read_file(state.file_path)
    case rows do
      [] ->
        []
      [ header_names | tail ] ->
        Enum.each(tail, fn e -> into_datastore(e, header_names, state) end)
    end
  end

  defp into_datastore(csv_row, header_names, state) do
    data_as_keylist = Enum.zip(header_names, csv_row)
    %{data_store: datastore} = state
    case List.keyfind(data_as_keylist, "locationid", 1) do
      nil ->
        state
      location_id ->
        new_datastore = %{ datastore | location_id => data_as_keylist }
        %{ state | datastore: new_datastore}
    end
  end

end
