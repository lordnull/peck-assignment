defmodule Fmft.Datastore do
  # Using agent as a simple state holder of the dataset.
  # This is to avoid constantly dipping to the filesystem.
  use Agent
  # Importing this to get access to the defstruct macro.
  import Kernel

  # Avoiding hard-coded default values.
  @default_file_path "Mobile_Food_Facility_Permit.csv"

  # Easy way to define the state for this module's agent.
  defstruct [file_path: @default_file_path, datastore: %{}]

  def find_trucks(agent_pid, latitude, logitude) do
    # I have a hunch it will take less time to do the calculation of
    # distance than to copy the state to whatever is requesting the
    # info. Refactoring to use ets makes it a moot point, though.
    Agent.get(agent_pid, fn state -> find_trucks_internal(latitude, logitude, state.datastore) end)
  end

  defp find_trucks_internal(latitude, longitude, data_store) do
    # A very basic sort of the dataset. Not bothering to do a square root for
    # the exact distance because we don't need precise, just size comparison.
    Enum.sort_by(data_store, fn {_id, data} ->
      truck_lat = safe_lat_or_long(List.keyfind(data, "Latitude", 0, 10_000.0))
      truck_long = safe_lat_or_long(List.keyfind(data, "Longitude", 0, 10_000.0))
      dist_squared(latitude, longitude, truck_lat, truck_long)
    end,
    &(&1 >= &2))
  end

  # If I gave myself more time, I would have done more to ensure the csv we
  # imported initially was actually sanitized properly, thus containing
  # a proper record with floats for the latitude and longitude.
  defp safe_lat_or_long({_, string}) do
    safe_lat_or_long(string)
  end
  defp safe_lat_or_long(string) do
    case Float.parse(string) do
      :error ->
        10_000.0
      {f, _} ->
        f
    end
  end

  defp dist_squared(lat1, long1, lat2, long2) do
    Float.pow((lat2 - lat1), 2) + Float.pow((long2 - long1), 2)
  end

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
        Enum.reduce(tail, state, fn(e, state_acc) -> into_datastore(e, header_names, state_acc) end)
    end
  end

  # In the future, I would have this load into an ets table,
  # and set it to 'protected' status. This way, the agent can periodically
  # refresh it's backing data, other processes can access the data
  # without blocking eachother, and we can more easily use match
  # syntax on the ets table to get exactly what we want.
  defp into_datastore(csv_row, header_names, state) do
    data_as_keylist = Enum.zip(header_names, csv_row)
    %{datastore: datastore} = state
    case List.keyfind(data_as_keylist, "locationid", 0) do
      nil ->
        state
      {_, location_id} ->
        new_datastore = Map.put(datastore, location_id, data_as_keylist)
        %{ state | datastore: new_datastore}
    end
  end

end
