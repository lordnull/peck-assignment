defmodule Fmft.Datastore do
  # Using agent as a simple state holder of the dataset.
  # This is to avoid constantly dipping to the filesystem.
  use Agent
  # Importing this to get access to the defstruct macro.
  import Kernel

  # Avoiding hard-coded default values.
  @default_file_path "Mobile_Food_Facility_Permit.csv"

  # Easy way to define the state for this module's agent.
  defstruct [file_path: @default_file_path, data_store: %{}]

  # primarily a debug function to ensure the default file is
  # readable.
  def read_file() do
    read_file(@default_file_path)
  end
  # Like the above, but will accept any file.
  def read_file(file_path) do
    File.stream!(file_path) |> CSV.decode!() |> Enum.to_list()
  end

  @doc """
  Start the datastore agent using the default file_path of
  "Mobile_Food_Facility_Permit.csv".
  """
  def start_link() do
    start_link(%{})
  end
  @doc """
  Start the datastore agent using the given options as a map. The
  only option currently supported is 'file_path'.
  """
  def start_link(opts) do
    init_state = state_from_opts(opts)
    Agent.start_link(fn -> init_state |> init_datastore end)
  end

  # Helper functions for above. Simply zipping along the options to
  # build up a state.
  defp state_from_opts(opts) do
    Enum.reduce(opts, __struct__(), fn ({k, v}, state) -> state_from_opts(k, v, state) end)
  end

  defp state_from_opts(:file_path, file_path, state) do
    %{ state | file_path: file_path}
  end

  def init_datastore(state) do
    rows = read_file(state.file_path)
    case rows do
      [] ->
        []
      [ header_names | tail ] ->
        Enum.each(tail, fn e -> into_datastore(e, header_names, state) end)
    end
  end

  # In the future, I would have this load into an ets table,
  # and set it to 'protected' status. This way, the agent can periodically
  # refresh it's backing data, other processes can access the data
  # without blocking eachother, and we can more easily use match
  # syntax on the ets table to get exactly what we want.
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
