-include .env

.PHONY: test build deploy-sepolia anvil

build:; forge build

deploy-sepolia:;
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

test:;
	forge test

anvil:; anvil

FundFundMe:;
	forge script script/interactions.s.sol:FundFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast

WithdrawFundMe:;
	forge script script/interactions.s.sol:WithdrawFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast

snapshot:;
	forge snapshot

# To load env
env:;
	source .env