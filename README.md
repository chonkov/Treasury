# Treasury Contract

This is a smart contract for managing a treasury that deposits funds into Uniswap and Aave. The contract allows the owner to set ratios for distribution between Uniswap and Aave, deposit USDC, and withdraw USDT and DAI.

## Features

- Deposit USDC into the contract
- Distribute deposited funds between Uniswap and Aave based on set ratios
- Swap USDC for USDT on Uniswap
- Deposit USDC into Aave and receive DAI
- Withdraw USDT and DAI from the contract
- Calculate the total yield of the treasury

## Dependencies

- OpenZeppelin Contracts: ERC20, SafeERC20, and Ownable
- Uniswap V2 Router02 Interface
- Aave Lending Pool Interface

## Constructor

The constructor takes the following parameters:

- `uniswapRouter_`: Address of the Uniswap V2 Router02 contract
- `aaveLendingPool_`: Address of the Aave Lending Pool contract
- `usdcToken_`: Address of the USDC token contract
- `usdtToken_`: Address of the USDT token contract
- `daiToken_`: Address of the DAI token contract

## Functions

### `setRatios(uint256 _uniswapRatio, uint256 _aaveRatio)`

Sets the distribution ratios for Uniswap and Aave. The sum of both ratios must not exceede 100.

### `deposit(uint256 amount)`

Deposits USDC into the contract and distributes the funds between Uniswap and Aave based on the set ratios. Swaps USDC for USDT on Uniswap and deposits USDC into Aave to receive DAI.

### `withdraw(uint256 amount)`

Withdraws USDT and DAI from the contract based on the set ratios.

### `calculateYield()`

Calculates the total yield of the treasury by adding the USDT and DAI balances.

## Interaction Flow

1. Users deposits USDC into the treasury contract

2. The deposited funds are divided according to the ratios and sent to Uniswap and Aave

3. On Uniswap, USDC is swapped for USDT

4. On Aave, USDC is deposited for DAI

5. The owner of the treasury can withdraw funds anytime, according to the set ratios

# Treasury Architecture

### In the 'Treasury.png' file a simple overview of the architecture is provided

1. Users deposit USDC in the treasury

2. The treasury deposits USDC into Uniswap V2 Router and Aave Lending Pool

3. The owner of the treasury can withdraw funds and set new ratios even when contract is deployed

### Detailed description of the functionality

#### `deposit(uitn256 amount)`

1. If users don't use a smart contract to interact with the 'deposit' function, they will have to make 2 transactions - approve the tokens and call deposit, in order for the contract to do not revert when 'safeTransferFrom' is called

2. According to the ratios, the amount of USDC to send to both Uniswap and Aave is computed. Note: the min amount of tokens to be sent should be 100, of course otherwise not the whole amount will be deposited

3. Allowance is increased in order for the Uniswap Router and Aave Lending Pool to be able to transfer the tokens from the treasury

4. Swap path for Router is computed

5. Swap and deposit are executed

### `withdraw(uint256 amount)`

1. Withdraws USDT and DAI from the contract based on the set ratios. Note: if the sum of the ratios is less than 100, this means that there will always be a certan amount of liquidity inside the pool, which means if additional functionality is added, users can always withdraw some of their funds

### `calculateYield()`

1. Calculates the total yield of the treasury by adding the USDT and DAI balances owned by the treasury contract
