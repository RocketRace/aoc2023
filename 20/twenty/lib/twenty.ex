defmodule Twenty do
  @type machine() :: :broadcaster | String.t()
  @type machines() :: %{
          String.t() =>
            {:flip, boolean(), [machine()]}
            | {:conjunction, %{machine() => boolean()}, [machine()]},
          broadcaster: [machine()]
        }

  @spec parse() :: machines()
  def parse do
    {:ok, file} = File.open(Path.relative_to_cwd("../input"), [:utf8])

    machines =
      for line <- String.split(IO.read(file, :eof), "\n", trim: true) do
        [name, out] = String.split(line, " -> ")

        outs = String.split(out, ", ")

        if name == "broadcaster" do
          {:broadcaster, outs}
        else
          {type, name} = String.split_at(name, 1)

          {name,
           if type == "&" do
             {:conjunction, %{}, outs}
           else
             {:flip, false, outs}
           end}
        end
      end
      |> Map.new()
      |> Map.put("rx", {:rx, []})

    reverse_connections =
      for {name, val} <- machines do
        case val do
          {_, _, outs} -> Enum.map(outs, fn out -> {out, name} end)
          outs when is_list(outs) -> Enum.map(outs, fn out -> {out, name} end)
          _rx -> []
        end
      end
      |> Enum.concat()

    Enum.reduce(reverse_connections, machines, fn {machine, input}, machines ->
      if machines[machine] != nil do
        Map.update!(machines, machine, fn val ->
          case val do
            {:conjunction, memory, outs} ->
              {:conjunction, Map.put(memory, input, false), outs}

            {:rx, inputs} ->
              {:rx, [input | inputs]}

            other ->
              other
          end
        end)
      else
        machines
      end
    end)
  end

  defp new_signal(outs, from, high?) do
    Enum.map(outs, fn to -> {from, to, high?} end)
  end

  @spec pulse(machines(), machine(), machine(), high?: boolean()) ::
          {[{machine(), machine(), boolean()}], map()}
  def pulse(machines, from, to, high?: high?) do
    if machines[to] != nil and to != "rx" do
      Map.get_and_update!(machines, to, fn machine ->
        case machine do
          {:flip, on?, outs} ->
            if high? do
              {[], {:flip, on?, outs}}
            else
              {new_signal(outs, to, not on?), {:flip, not on?, outs}}
            end

          {:conjunction, state, outs} ->
            updated = Map.put(state, from, high?)
            output? = not Enum.all?(updated, fn {_, high?} -> high? end)

            {new_signal(outs, to, output?), {:conjunction, updated, outs}}

          # ignore rx for the time being
          rx ->
            rx
        end
      end)
    else
      {[], machines}
    end
  end

  def tick_all(machines, signals, target) do
    Enum.reduce(signals, {[], machines, %{false: 0, true: 0}}, fn {from, to, high?},
                                                                  {signals, machines, counts} ->
      {new_signals, machines} = pulse(machines, from, to, high?: high?)

      counts =
        if target != nil and to == target and not high? do
          merge_counts(counts, %{target => 1})
        else
          counts
        end

      {signals ++ new_signals, machines, Map.update!(counts, high?, fn n -> n + 1 end)}
    end)
  end

  def merge_counts(left, right) do
    Map.merge(left, right, fn _, a, b -> a + b end)
  end

  def resolve_tick(machines, counts, signals, target \\ nil) do
    {new_signals, machines, new_counts} = tick_all(machines, signals, target)
    counts = merge_counts(counts, new_counts)

    if Enum.empty?(new_signals) do
      {machines, counts}
    else
      resolve_tick(machines, counts, new_signals, target)
    end
  end

  def part1 do
    times = 1000
    machines = parse()

    {_, %{false: lows, true: highs}} =
      Enum.reduce(0..(times - 1)//1, {machines, %{false: 0, true: 0, rx: 0}}, fn _,
                                                                                 {machines,
                                                                                  counts} ->
        signals = new_signal(machines.broadcaster, :button, false)
        {machines, new_counts} = resolve_tick(machines, %{false: 1, true: 0}, signals)
        {machines, merge_counts(counts, new_counts)}
      end)

    lows * highs
  end

  def press_and_wait(machines, target, counter) do
    signals = new_signal(machines.broadcaster, :button, false)
    {machines, counts} = resolve_tick(machines, %{}, signals, target)

    if counts[target] == nil do
      press_and_wait(machines, target, counter + 1)
    else
      counter
    end
  end

  def part2 do
    machines = parse()

    {:rx, [conj]} = machines["rx"]
    {:conjunction, memory, _} = machines[conj]

    cycles =
      for target <- Map.keys(memory) do
        press_and_wait(machines, target, 1)
      end

    Enum.reduce(cycles, 1, fn cycle, lcm ->
      Integer.floor_div(lcm * cycle, Integer.gcd(lcm, cycle))
    end)

    # worked first try so i won't complain
  end
end
