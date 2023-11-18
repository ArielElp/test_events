use tests::mock_erc20;
use starknet::ContractAddress;
use starknet::contract_address_const;
use starknet::testing::{pop_log, set_caller_address, pop_log_raw};
use core::debug::{ArrayGenericPrintImpl, PrintTrait, print_byte_array_as_string};
use core::test::test_utils::{assert_eq, assert_ne};
use openzeppelin::token::erc20::ERC20Component;
use openzeppelin::token::erc20::ERC20Component::{
    Approval, Transfer, ERC20CamelOnlyImpl, ERC20Impl, ERC20MetadataImpl, InternalImpl,
    SafeAllowanceImpl, SafeAllowanceCamelImpl
};
use core::fmt::{Formatter, Debug};
use tests::mock_erc20::mock_erc20::EventDebug;


fn OWNER() -> ContractAddress {
    contract_address_const::<'OWNER'>()
}

fn RECIPIENT() -> ContractAddress {
    contract_address_const::<'RECIPIENT'>()
}

fn ZERO() -> ContractAddress {
    contract_address_const::<0>()
}

const NAME: felt252 = 'my_token';
const SYMBOL: felt252 = 'tkn';
const SUPPLY: u256 = 2000;

#[test]
#[available_gas(200000000)]
fn test_transfer() {
    let mut state: mock_erc20::mock_erc20::ContractState =
        mock_erc20::mock_erc20::contract_state_for_testing();

    state.erc20.initializer(NAME, SYMBOL);
    state.erc20._mint(OWNER(), SUPPLY);
    pop_log_raw(ZERO()); // drop mint transfer event

    set_caller_address(OWNER());
    state.erc20.transfer(RECIPIENT(), 1000);

    let event = pop_log::<mock_erc20::mock_erc20::Event>(ZERO()).unwrap();
    let expected = mock_erc20::mock_erc20::Event::ERC20Event(
        ERC20Component::Event::Transfer(
            ERC20Component::Transfer { from: OWNER(), to: RECIPIENT(), value: 1000 }
        )
    );
    assert_eq(@event, @expected, 'badness');

    let mut formatter: Formatter = Default::default();
    (@expected).fmt(ref formatter);
    // let formatted = format!("{}", expected); DOEST NOT COMPILE
    print_byte_array_as_string(@formatter.buffer);
}

