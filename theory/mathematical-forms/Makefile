include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./theory/mathematical-forms"))')/nix_eval_module.mk


include /nix_eval_module.mk


.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.

.PHONY: test-_common

test-_common: _common.nix
	@echo "--- Testing _common.nix with nix eval ---"
	@nix eval --raw ./_common.nix > _common.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for _common.nix. Check _common.eval.log for details."
		cat _common.eval.log; 		exit 1; 	}
	@echo "--- _common.nix test complete. Output in _common.eval.log ---"



.PHONY: test-01-Value

test-01-Value: 01-Value.nix
	@echo "--- Testing 01-Value.nix with nix eval ---"
	@nix eval --raw ./01-Value.nix > 01-Value.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 01-Value.nix. Check 01-Value.eval.log for details."
		cat 01-Value.eval.log; 		exit 1; 	}
	@echo "--- 01-Value.nix test complete. Output in 01-Value.eval.log ---"



.PHONY: test-02-IsPrime

test-02-IsPrime: 02-IsPrime.nix
	@echo "--- Testing 02-IsPrime.nix with nix eval ---"
	@nix eval --raw ./02-IsPrime.nix > 02-IsPrime.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 02-IsPrime.nix. Check 02-IsPrime.eval.log for details."
		cat 02-IsPrime.eval.log; 		exit 1; 	}
	@echo "--- 02-IsPrime.nix test complete. Output in 02-IsPrime.eval.log ---"



.PHONY: test-03-MersennePrimeExponent

test-03-MersennePrimeExponent: 03-MersennePrimeExponent.nix
	@echo "--- Testing 03-MersennePrimeExponent.nix with nix eval ---"
	@nix eval --raw ./03-MersennePrimeExponent.nix > 03-MersennePrimeExponent.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 03-MersennePrimeExponent.nix. Check 03-MersennePrimeExponent.eval.log for details."
		cat 03-MersennePrimeExponent.eval.log; 		exit 1; 	}
	@echo "--- 03-MersennePrimeExponent.nix test complete. Output in 03-MersennePrimeExponent.eval.log ---"



.PHONY: test-04-CenteredPentagonalNumber

test-04-CenteredPentagonalNumber: 04-CenteredPentagonalNumber.nix
	@echo "--- Testing 04-CenteredPentagonalNumber.nix with nix eval ---"
	@nix eval --raw ./04-CenteredPentagonalNumber.nix > 04-CenteredPentagonalNumber.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 04-CenteredPentagonalNumber.nix. Check 04-CenteredPentagonalNumber.eval.log for details."
		cat 04-CenteredPentagonalNumber.eval.log; 		exit 1; 	}
	@echo "--- 04-CenteredPentagonalNumber.nix test complete. Output in 04-CenteredPentagonalNumber.eval.log ---"



.PHONY: test-05-IsHappyNumber

test-05-IsHappyNumber: 05-IsHappyNumber.nix
	@echo "--- Testing 05-IsHappyNumber.nix with nix eval ---"
	@nix eval --raw ./05-IsHappyNumber.nix > 05-IsHappyNumber.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 05-IsHappyNumber.nix. Check 05-IsHappyNumber.eval.log for details."
		cat 05-IsHappyNumber.eval.log; 		exit 1; 	}
	@echo "--- 05-IsHappyNumber.nix test complete. Output in 05-IsHappyNumber.eval.log ---"



.PHONY: test-06-PermutablePrime

test-06-PermutablePrime: 06-PermutablePrime.nix
	@echo "--- Testing 06-PermutablePrime.nix with nix eval ---"
	@nix eval --raw ./06-PermutablePrime.nix > 06-PermutablePrime.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 06-PermutablePrime.nix. Check 06-PermutablePrime.eval.log for details."
		cat 06-PermutablePrime.eval.log; 		exit 1; 	}
	@echo "--- 06-PermutablePrime.nix test complete. Output in 06-PermutablePrime.eval.log ---"



.PHONY: test-07-Emirp

test-07-Emirp: 07-Emirp.nix
	@echo "--- Testing 07-Emirp.nix with nix eval ---"
	@nix eval --raw ./07-Emirp.nix > 07-Emirp.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 07-Emirp.nix. Check 07-Emirp.eval.log for details."
		cat 07-Emirp.eval.log; 		exit 1; 	}
	@echo "--- 07-Emirp.nix test complete. Output in 07-Emirp.eval.log ---"



.PHONY: test-08-PrimeIndex

test-08-PrimeIndex: 08-PrimeIndex.nix
	@echo "--- Testing 08-PrimeIndex.nix with nix eval ---"
	@nix eval --raw ./08-PrimeIndex.nix > 08-PrimeIndex.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 08-PrimeIndex.nix. Check 08-PrimeIndex.eval.log for details."
		cat 08-PrimeIndex.eval.log; 		exit 1; 	}
	@echo "--- 08-PrimeIndex.nix test complete. Output in 08-PrimeIndex.eval.log ---"



.PHONY: test-09-PrimeIndexIsPrime

test-09-PrimeIndexIsPrime: 09-PrimeIndexIsPrime.nix
	@echo "--- Testing 09-PrimeIndexIsPrime.nix with nix eval ---"
	@nix eval --raw ./09-PrimeIndexIsPrime.nix > 09-PrimeIndexIsPrime.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 09-PrimeIndexIsPrime.nix. Check 09-PrimeIndexIsPrime.eval.log for details."
		cat 09-PrimeIndexIsPrime.eval.log; 		exit 1; 	}
	@echo "--- 09-PrimeIndexIsPrime.nix test complete. Output in 09-PrimeIndexIsPrime.eval.log ---"



.PHONY: test-10-DifferenceOfSquares

test-10-DifferenceOfSquares: 10-DifferenceOfSquares.nix
	@echo "--- Testing 10-DifferenceOfSquares.nix with nix eval ---"
	@nix eval --raw ./10-DifferenceOfSquares.nix > 10-DifferenceOfSquares.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 10-DifferenceOfSquares.nix. Check 10-DifferenceOfSquares.eval.log for details."
		cat 10-DifferenceOfSquares.eval.log; 		exit 1; 	}
	@echo "--- 10-DifferenceOfSquares.nix test complete. Output in 10-DifferenceOfSquares.eval.log ---"



.PHONY: test-11-SumOfFourPrimes

test-11-SumOfFourPrimes: 11-SumOfFourPrimes.nix
	@echo "--- Testing 11-SumOfFourPrimes.nix with nix eval ---"
	@nix eval --raw ./11-SumOfFourPrimes.nix > 11-SumOfFourPrimes.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 11-SumOfFourPrimes.nix. Check 11-SumOfFourPrimes.eval.log for details."
		cat 11-SumOfFourPrimes.eval.log; 		exit 1; 	}
	@echo "--- 11-SumOfFourPrimes.nix test complete. Output in 11-SumOfFourPrimes.eval.log ---"



.PHONY: test-12-NumberOfDivisors

test-12-NumberOfDivisors: 12-NumberOfDivisors.nix
	@echo "--- Testing 12-NumberOfDivisors.nix with nix eval ---"
	@nix eval --raw ./12-NumberOfDivisors.nix > 12-NumberOfDivisors.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 12-NumberOfDivisors.nix. Check 12-NumberOfDivisors.eval.log for details."
		cat 12-NumberOfDivisors.eval.log; 		exit 1; 	}
	@echo "--- 12-NumberOfDivisors.nix test complete. Output in 12-NumberOfDivisors.eval.log ---"



.PHONY: test-13-SumOfDivisors

test-13-SumOfDivisors: 13-SumOfDivisors.nix
	@echo "--- Testing 13-SumOfDivisors.nix with nix eval ---"
	@nix eval --raw ./13-SumOfDivisors.nix > 13-SumOfDivisors.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 13-SumOfDivisors.nix. Check 13-SumOfDivisors.eval.log for details."
		cat 13-SumOfDivisors.eval.log; 		exit 1; 	}
	@echo "--- 13-SumOfDivisors.nix test complete. Output in 13-SumOfDivisors.eval.log ---"



.PHONY: test-14-BinaryRepresentation

test-14-BinaryRepresentation: 14-BinaryRepresentation.nix
	@echo "--- Testing 14-BinaryRepresentation.nix with nix eval ---"
	@nix eval --raw ./14-BinaryRepresentation.nix > 14-BinaryRepresentation.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 14-BinaryRepresentation.nix. Check 14-BinaryRepresentation.eval.log for details."
		cat 14-BinaryRepresentation.eval.log; 		exit 1; 	}
	@echo "--- 14-BinaryRepresentation.nix test complete. Output in 14-BinaryRepresentation.eval.log ---"



.PHONY: test-15-HexadecimalRepresentation

test-15-HexadecimalRepresentation: 15-HexadecimalRepresentation.nix
	@echo "--- Testing 15-HexadecimalRepresentation.nix with nix eval ---"
	@nix eval --raw ./15-HexadecimalRepresentation.nix > 15-HexadecimalRepresentation.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 15-HexadecimalRepresentation.nix. Check 15-HexadecimalRepresentation.eval.log for details."
		cat 15-HexadecimalRepresentation.eval.log; 		exit 1; 	}
	@echo "--- 15-HexadecimalRepresentation.nix test complete. Output in 15-HexadecimalRepresentation.eval.log ---"



.PHONY: test-16-OctalRepresentation

test-16-OctalRepresentation: 16-OctalRepresentation.nix
	@echo "--- Testing 16-OctalRepresentation.nix with nix eval ---"
	@nix eval --raw ./16-OctalRepresentation.nix > 16-OctalRepresentation.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 16-OctalRepresentation.nix. Check 16-OctalRepresentation.eval.log for details."
		cat 16-OctalRepresentation.eval.log; 		exit 1; 	}
	@echo "--- 16-OctalRepresentation.nix test complete. Output in 16-OctalRepresentation.eval.log ---"



.PHONY: test-17-NumberOfBits

test-17-NumberOfBits: 17-NumberOfBits.nix
	@echo "--- Testing 17-NumberOfBits.nix with nix eval ---"
	@nix eval --raw ./17-NumberOfBits.nix > 17-NumberOfBits.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 17-NumberOfBits.nix. Check 17-NumberOfBits.eval.log for details."
		cat 17-NumberOfBits.eval.log; 		exit 1; 	}
	@echo "--- 17-NumberOfBits.nix test complete. Output in 17-NumberOfBits.eval.log ---"



.PHONY: test-18-SmallestPrimeGreaterThan29

test-18-SmallestPrimeGreaterThan29: 18-SmallestPrimeGreaterThan29.nix
	@echo "--- Testing 18-SmallestPrimeGreaterThan29.nix with nix eval ---"
	@nix eval --raw ./18-SmallestPrimeGreaterThan29.nix > 18-SmallestPrimeGreaterThan29.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 18-SmallestPrimeGreaterThan29.nix. Check 18-SmallestPrimeGreaterThan29.eval.log for details."
		cat 18-SmallestPrimeGreaterThan29.eval.log; 		exit 1; 	}
	@echo "--- 18-SmallestPrimeGreaterThan29.nix test complete. Output in 18-SmallestPrimeGreaterThan29.eval.log ---"



.PHONY: test-19-LargestPrimeLessThan37

test-19-LargestPrimeLessThan37: 19-LargestPrimeLessThan37.nix
	@echo "--- Testing 19-LargestPrimeLessThan37.nix with nix eval ---"
	@nix eval --raw ./19-LargestPrimeLessThan37.nix > 19-LargestPrimeLessThan37.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 19-LargestPrimeLessThan37.nix. Check 19-LargestPrimeLessThan37.eval.log for details."
		cat 19-LargestPrimeLessThan37.eval.log; 		exit 1; 	}
	@echo "--- 19-LargestPrimeLessThan37.nix test complete. Output in 19-LargestPrimeLessThan37.eval.log ---"



.PHONY: test-20-ConsecutivePrimeGap

test-20-ConsecutivePrimeGap: 20-ConsecutivePrimeGap.nix
	@echo "--- Testing 20-ConsecutivePrimeGap.nix with nix eval ---"
	@nix eval --raw ./20-ConsecutivePrimeGap.nix > 20-ConsecutivePrimeGap.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 20-ConsecutivePrimeGap.nix. Check 20-ConsecutivePrimeGap.eval.log for details."
		cat 20-ConsecutivePrimeGap.eval.log; 		exit 1; 	}
	@echo "--- 20-ConsecutivePrimeGap.nix test complete. Output in 20-ConsecutivePrimeGap.eval.log ---"



.PHONY: test-21-NotAFibonacciNumber

test-21-NotAFibonacciNumber: 21-NotAFibonacciNumber.nix
	@echo "--- Testing 21-NotAFibonacciNumber.nix with nix eval ---"
	@nix eval --raw ./21-NotAFibonacciNumber.nix > 21-NotAFibonacciNumber.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 21-NotAFibonacciNumber.nix. Check 21-NotAFibonacciNumber.eval.log for details."
		cat 21-NotAFibonacciNumber.eval.log; 		exit 1; 	}
	@echo "--- 21-NotAFibonacciNumber.nix test complete. Output in 21-NotAFibonacciNumber.eval.log ---"



.PHONY: test-22-NotACatalanNumber

test-22-NotACatalanNumber: 22-NotACatalanNumber.nix
	@echo "--- Testing 22-NotACatalanNumber.nix with nix eval ---"
	@nix eval --raw ./22-NotACatalanNumber.nix > 22-NotACatalanNumber.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 22-NotACatalanNumber.nix. Check 22-NotACatalanNumber.eval.log for details."
		cat 22-NotACatalanNumber.eval.log; 		exit 1; 	}
	@echo "--- 22-NotACatalanNumber.nix test complete. Output in 22-NotACatalanNumber.eval.log ---"



.PHONY: test-23-NotAFactorial

test-23-NotAFactorial: 23-NotAFactorial.nix
	@echo "--- Testing 23-NotAFactorial.nix with nix eval ---"
	@nix eval --raw ./23-NotAFactorial.nix > 23-NotAFactorial.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 23-NotAFactorial.nix. Check 23-NotAFactorial.eval.log for details."
		cat 23-NotAFactorial.eval.log; 		exit 1; 	}
	@echo "--- 23-NotAFactorial.nix test complete. Output in 23-NotAFactorial.eval.log ---"



.PHONY: test-24-NotATriangularNumber

test-24-NotATriangularNumber: 24-NotATriangularNumber.nix
	@echo "--- Testing 24-NotATriangularNumber.nix with nix eval ---"
	@nix eval --raw ./24-NotATriangularNumber.nix > 24-NotATriangularNumber.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 24-NotATriangularNumber.nix. Check 24-NotATriangularNumber.eval.log for details."
		cat 24-NotATriangularNumber.eval.log; 		exit 1; 	}
	@echo "--- 24-NotATriangularNumber.nix test complete. Output in 24-NotATriangularNumber.eval.log ---"



.PHONY: test-25-NotASquareNumber

test-25-NotASquareNumber: 25-NotASquareNumber.nix
	@echo "--- Testing 25-NotASquareNumber.nix with nix eval ---"
	@nix eval --raw ./25-NotASquareNumber.nix > 25-NotASquareNumber.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 25-NotASquareNumber.nix. Check 25-NotASquareNumber.eval.log for details."
		cat 25-NotASquareNumber.eval.log; 		exit 1; 	}
	@echo "--- 25-NotASquareNumber.nix test complete. Output in 25-NotASquareNumber.eval.log ---"



.PHONY: test-26-NotACubeNumber

test-26-NotACubeNumber: 26-NotACubeNumber.nix
	@echo "--- Testing 26-NotACubeNumber.nix with nix eval ---"
	@nix eval --raw ./26-NotACubeNumber.nix > 26-NotACubeNumber.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 26-NotACubeNumber.nix. Check 26-NotACubeNumber.eval.log for details."
		cat 26-NotACubeNumber.eval.log; 		exit 1; 	}
	@echo "--- 26-NotACubeNumber.nix test complete. Output in 26-NotACubeNumber.eval.log ---"



.PHONY: test-27-SumOfTwoPrimes

test-27-SumOfTwoPrimes: 27-SumOfTwoPrimes.nix
	@echo "--- Testing 27-SumOfTwoPrimes.nix with nix eval ---"
	@nix eval --raw ./27-SumOfTwoPrimes.nix > 27-SumOfTwoPrimes.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 27-SumOfTwoPrimes.nix. Check 27-SumOfTwoPrimes.eval.log for details."
		cat 27-SumOfTwoPrimes.eval.log; 		exit 1; 	}
	@echo "--- 27-SumOfTwoPrimes.nix test complete. Output in 27-SumOfTwoPrimes.eval.log ---"



.PHONY: test-28-SumOfThreePrimes

test-28-SumOfThreePrimes: 28-SumOfThreePrimes.nix
	@echo "--- Testing 28-SumOfThreePrimes.nix with nix eval ---"
	@nix eval --raw ./28-SumOfThreePrimes.nix > 28-SumOfThreePrimes.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 28-SumOfThreePrimes.nix. Check 28-SumOfThreePrimes.eval.log for details."
		cat 28-SumOfThreePrimes.eval.log; 		exit 1; 	}
	@echo "--- 28-SumOfThreePrimes.nix test complete. Output in 28-SumOfThreePrimes.eval.log ---"



.PHONY: test-29-SumOfDistinctPrimes

test-29-SumOfDistinctPrimes: 29-SumOfDistinctPrimes.nix
	@echo "--- Testing 29-SumOfDistinctPrimes.nix with nix eval ---"
	@nix eval --raw ./29-SumOfDistinctPrimes.nix > 29-SumOfDistinctPrimes.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 29-SumOfDistinctPrimes.nix. Check 29-SumOfDistinctPrimes.eval.log for details."
		cat 29-SumOfDistinctPrimes.eval.log; 		exit 1; 	}
	@echo "--- 29-SumOfDistinctPrimes.nix test complete. Output in 29-SumOfDistinctPrimes.eval.log ---"



.PHONY: test-30-NumberInSomeMonths

test-30-NumberInSomeMonths: 30-NumberInSomeMonths.nix
	@echo "--- Testing 30-NumberInSomeMonths.nix with nix eval ---"
	@nix eval --raw ./30-NumberInSomeMonths.nix > 30-NumberInSomeMonths.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 30-NumberInSomeMonths.nix. Check 30-NumberInSomeMonths.eval.log for details."
		cat 30-NumberInSomeMonths.eval.log; 		exit 1; 	}
	@echo "--- 30-NumberInSomeMonths.nix test complete. Output in 30-NumberInSomeMonths.eval.log ---"



.PHONY: test-31-TheNthPrime

test-31-TheNthPrime: 31-TheNthPrime.nix
	@echo "--- Testing 31-TheNthPrime.nix with nix eval ---"
	@nix eval --raw ./31-TheNthPrime.nix > 31-TheNthPrime.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 31-TheNthPrime.nix. Check 31-TheNthPrime.eval.log for details."
		cat 31-TheNthPrime.eval.log; 		exit 1; 	}
	@echo "--- 31-TheNthPrime.nix test complete. Output in 31-TheNthPrime.eval.log ---"



.PHONY: test-32-FixForCubeNumberCheck

test-32-FixForCubeNumberCheck: 32-FixForCubeNumberCheck.nix
	@echo "--- Testing 32-FixForCubeNumberCheck.nix with nix eval ---"
	@nix eval --raw ./32-FixForCubeNumberCheck.nix > 32-FixForCubeNumberCheck.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for 32-FixForCubeNumberCheck.nix. Check 32-FixForCubeNumberCheck.eval.log for details."
		cat 32-FixForCubeNumberCheck.eval.log; 		exit 1; 	}
	@echo "--- 32-FixForCubeNumberCheck.nix test complete. Output in 32-FixForCubeNumberCheck.eval.log ---"


