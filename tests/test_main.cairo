%lang starknet
from src.main import balance, increase_balance, get_owner
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from openzeppelin.access.ownable.library import Ownable


const TEST_ACC1 = 0x00348f5537be66815eb7de63295fcb5d8b8b2ffe09bb712af4966db7cbb04a95;
const TEST_ACC2 = 0x3fe90a1958bb8468fb1b62970747d8a00c435ef96cda708ae8de3d07f1bb56b;

@external
func test_increase_balance{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    let (result_before) = balance.read();
    // get caller
    let (caller) =  get_caller_address();

    // get owner
    let (owner) = get_owner();
    
    assert owner = caller;
    assert result_before = 0;

    increase_balance(42);

    let (result_after) = balance.read();
    assert result_after = 42;
    return ();
}

@external
func test_cannot_increase_balance_with_negative_value{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    let (result_before) = balance.read();
    assert result_before = 0;

    %{ expect_revert("TRANSACTION_FAILED", "Amount must be positive") %}
    increase_balance(-42);

    return ();
}

@external
func test_revert_attempt_to_increase_balance_with_non_owner_as_caller{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    // assign TEST_ACC1 as caller
    %{ start_prank(ids.TEST_ACC1) %}

    // revert non-owner/TEST_ACC1 attempt to increase balance
    %{ expect_revert("TRANSACTION_FAILED", "Ownable: caller is not the owner") %}
    increase_balance(5);

    // assign TEST_ACC2 as caller 
    %{ start_prank(ids.TEST_ACC2) %}

    // revert non-owner/TEST_ACC2 attempt to increase balance
    %{ expect_revert("TRANSACTION_FAILED", "Ownable: caller is not the owner") %}
    increase_balance(10);

    return ();
}



