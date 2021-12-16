defmodule Day16 do
  defmodule Parser do
    @doc ~S"""
        iex> "D2FE28" |> :binary.decode_hex() |> Day16.Parser.parse()
        {{6, 2021}, <<0::3>>}

        iex> "38006F45291200" |> :binary.decode_hex() |> Day16.Parser.parse()
        {{1, 6, [{6, 10}, {2, 20}]}, <<0::7>>}

        iex> "EE00D40C823060" |> :binary.decode_hex() |> Day16.Parser.parse()
        {{7, 3, [{2, 1}, {4, 2}, {1, 3}]}, <<0::5>>}

        iex> "8A004A801A8002F478" |> :binary.decode_hex() |> Day16.Parser.parse()
        {{4, 2, [{1, 2, [{5, 2, [{6, 15}]}]}]}, <<0::3>>}
    """
    def parse(<<version::3, 4::3, rest::bits>>) do
      {number, rest} = parse_literal(rest)
      {{version, number}, rest}
    end

    def parse(<<version::3, type_id::3, rest::bits>>) do
      {operator, rest} = parse_operator(rest)
      {{version, type_id, operator}, rest}
    end

    defp parse_literal_group(<<1::1, digits::4, rest::bits>>) do
      {next_digits, rest} = parse_literal_group(rest)
      {[digits | next_digits], rest}
    end

    defp parse_literal_group(<<0::1, digits::4, rest::bits>>) do
      {[digits], rest}
    end

    defp parse_literal(input) do
      {groups, rest} = parse_literal_group(input)
      {Integer.undigits(groups, 16), rest}
    end

    defp parse_operator(<<0::1, sub_packet_length::15, rest::bits>>) do
      <<sub_packet_bits::bits-size(sub_packet_length), rest::bits>> = rest

      sub_packets =
        sub_packet_bits
        |> Stream.unfold(fn
          <<>> -> nil
          bits -> parse(bits)
        end)
        |> Enum.to_list()

      {sub_packets, rest}
    end

    defp parse_operator(<<1::1, sub_packet_count::11, rest::bits>>) do
      {sub_packets, rest} =
        1..sub_packet_count
        |> Enum.reduce({[], rest}, fn _, {sub_packets, rest} ->
          {packet, rest} = parse(rest)
          {[packet | sub_packets], rest}
        end)

      {Enum.reverse(sub_packets), rest}
    end
  end

  defmodule Interpreter do
    def eval({_version, number}), do: number
    def eval({_version, 0, operands}), do: Enum.map(operands, &eval/1) |> Enum.sum()
    def eval({_version, 1, operands}), do: Enum.map(operands, &eval/1) |> Enum.product()
    def eval({_version, 2, operands}), do: Enum.map(operands, &eval/1) |> Enum.min()
    def eval({_version, 3, operands}), do: Enum.map(operands, &eval/1) |> Enum.max()
    def eval({_version, 5, [lhs, rhs]}), do: if(eval(lhs) > eval(rhs), do: 1, else: 0)
    def eval({_version, 6, [lhs, rhs]}), do: if(eval(lhs) < eval(rhs), do: 1, else: 0)
    def eval({_version, 7, [lhs, rhs]}), do: if(eval(lhs) == eval(rhs), do: 1, else: 0)
  end

  @doc ~S"""
      iex> Day16.part_one("8A004A801A8002F478")
      16

      iex> Day16.part_one("620080001611562C8802118E34")
      12

      iex> Day16.part_one("C0015000016115A2E0802F182340")
      23

      iex> Day16.part_one("A0016C880162017C3686B18A3D4780")
      31

      iex> Day16.part_one(Day16.input)
      981
  """
  def part_one(input) do
    {packet, _rest} = input |> :binary.decode_hex() |> Parser.parse()
    packet |> versions() |> List.flatten() |> Enum.sum()
  end

  @doc ~S"""
      iex> Day16.part_two("C200B40A82")
      3

      iex> Day16.part_two("04005AC33890")
      54

      iex> Day16.part_two("880086C3E88112")
      7

      iex> Day16.part_two("CE00C43D881120")
      9

      iex> Day16.part_two("D8005AC2A8F0")
      1

      iex> Day16.part_two("F600BC2D8F")
      0

      iex> Day16.part_two("9C005AC2F8F0")
      0

      iex> Day16.part_two("9C0141080250320F1802104A08")
      1

      iex> Day16.part_two(Day16.input)
      299227024091
  """
  def part_two(input) do
    {packet, _rest} = input |> :binary.decode_hex() |> Parser.parse()
    Interpreter.eval(packet)
  end

  defp versions({version, _type_id, packets}) when is_list(packets),
    do: [version, Enum.map(packets, &versions/1)]

  defp versions({version, _number}), do: version

  def input,
    do:
      "005532447836402684AC7AB3801A800021F0961146B1007A1147C89440294D005C12D2A7BC992D3F4E50C72CDF29EECFD0ACD5CC016962099194002CE31C5D3005F401296CAF4B656A46B2DE5588015C913D8653A3A001B9C3C93D7AC672F4FF78C136532E6E0007FCDFA975A3004B002E69EC4FD2D32CDF3FFDDAF01C91FCA7B41700263818025A00B48DEF3DFB89D26C3281A200F4C5AF57582527BC1890042DE00B4B324DBA4FAFCE473EF7CC0802B59DA28580212B3BD99A78C8004EC300761DC128EE40086C4F8E50F0C01882D0FE29900A01C01C2C96F38FCBB3E18C96F38FCBB3E1BCC57E2AA0154EDEC45096712A64A2520C6401A9E80213D98562653D98562612A06C0143CB03C529B5D9FD87CBA64F88CA439EC5BB299718023800D3CE7A935F9EA884F5EFAE9E10079125AF39E80212330F93EC7DAD7A9D5C4002A24A806A0062019B6600730173640575A0147C60070011FCA005000F7080385800CBEE006800A30C023520077A401840004BAC00D7A001FB31AAD10CC016923DA00686769E019DA780D0022394854167C2A56FB75200D33801F696D5B922F98B68B64E02460054CAE900949401BB80021D0562344E00042A16C6B8253000600B78020200E44386B068401E8391661C4E14B804D3B6B27CFE98E73BCF55B65762C402768803F09620419100661EC2A8CE0008741A83917CC024970D9E718DD341640259D80200008444D8F713C401D88310E2EC9F20F3330E059009118019A8803F12A0FC6E1006E3744183D27312200D4AC01693F5A131C93F5A131C970D6008867379CD3221289B13D402492EE377917CACEDB3695AD61C939C7C10082597E3740E857396499EA31980293F4FD206B40123CEE27CFB64D5E57B9ACC7F993D9495444001C998E66B50896B0B90050D34DF3295289128E73070E00A4E7A389224323005E801049351952694C000"
end
