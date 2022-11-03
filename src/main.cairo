%lang starknet
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero
from openzeppelin.access.ownable.library import Ownable


@storage_var
func balance() -> (res: felt) {
}

@external
func increase_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: felt, 
   

) -> ( caller: felt, res: felt) {
    with_attr error_message("Amount must be positive. Got: {amount}.") {
        assert_nn(amount);
    }

      let (owner) = Ownable.owner();
        let (caller) = get_caller_address();
        with_attr error_message("Ownable: caller is the zero address") {
            assert_not_zero(caller);
        }
        with_attr error_message("Ownable: caller is not the owner") {
            assert owner = caller;
        }

    let (res) = balance.read();
    balance.write(res + amount);
    return (caller, res,);
}

@view
func get_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let (res) = balance.read();
    return (res,);
}

@view 
func get_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
    let (owner) = Ownable.owner();

    return (owner,);
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    balance.write(0);
    let (caller) = get_caller_address();
    Ownable.initializer(caller);
    return ();
}
