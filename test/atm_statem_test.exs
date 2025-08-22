defmodule AtmStatemTest do
  use ExUnit.Case
  doctest AtmStatem

  import ExUnit.CaptureLog

  setup do
    {:ok, pid} = AtmStatem.start()

    on_exit(fn ->
      assert capture_log(fn -> AtmStatem.stop() end) =~
               "[info] atm_statem terminated with reason - normal"

      refute Process.alive?(pid)
    end)
  end

  test "state machine with valid actions" do
    assert AtmStatem.message() == "Please insert card"
    assert AtmStatem.insert_card() == :pin
    assert AtmStatem.message() == "Please enter PIN"
    assert AtmStatem.insert_pin("111") == :cash
    assert AtmStatem.message() == "Insert cash amount"
    assert AtmStatem.insert_amount(100) == :idle
  end

  test "state machine with invalid actions" do
    assert AtmStatem.message() == "Please insert card"
    assert AtmStatem.insert_amount(100) == "Please insert card"
    assert AtmStatem.insert_card() == :pin
    assert AtmStatem.insert_amount(100) == "Please enter PIN"
    assert AtmStatem.insert_pin("0111") == :idle
  end
end
