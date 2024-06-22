# Foundry Fund Me

This is a section of the solidity code that learns from the Cyfrin Solidity Course.



# Usage

## Deploy

```
forge script script/DeployFundMe.s.sol
```

## Testing
```
forge test
```

or 

```
// Only run test functions matching the specified regex pattern.

"forge test -m testFunctionName" is deprecated. Please use 

forge test --match-test testFunctionName
```

or

```
forge test --fork-url $SEPOLIA_RPC_URL
```


