//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BasicOperation {
    function isPrime(uint256 num) public pure returns (bool result) {
        result = true;
        assembly {
            let halfNum := add(div(num, 2), 1)
            let i := 2
            for {

            } lt(i, halfNum) {
                i := add(i, 1)
            } {
                // if eq(mod(num, i), 0) {
                if iszero(mod(num, i)) {
                    result := 0
                    break
                }
            }
        }
    }

    function test() external pure {
        require(isPrime(2));
        require(isPrime(3));
        require(!isPrime(4));
        require(!isPrime(15));
    }
}

contract IfComparison {
    function isTruthy() external pure returns (uint256 result) {
        result = 1;

        assembly {
            if 2 {
                result := 2
            }
        }
        return result;
    }

    function isFalsy() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if 0 {
                result := 2
            }
        }
        return result;
    }

    function negation() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if iszero(0) {
                result := 2
            }
        }
        return result;
    }

    function unsafe1NegationPart1() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if not(0) {
                result := 2
            }
        }
        return result;
    }

    function btFlip() external pure returns (bytes32 result) {
        assembly {
            result := not(2)
        }
        return result;
    }

    function unsafe2NegationPart2() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if not(2) {
                result := 2
            }
        }
        return result;
    }

    function safeNegation() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if iszero(2) {
                result := 2
            }
        }
        return result;
    }

    function max(uint256 x, uint256 y) external pure returns (uint256 maximum) {
        assembly {
            if lt(x, y) {
                maximum := y
            }
            if iszero(lt(x, y)) {
                //there is no else statements
                maximum := x
            }
        }
        return maximum;
    }

    // The rest:
    /*
        |  solidity   |    YUL    |
        +-------------+-----------+
        |   a && b    | and(a,b)  |
        +-------------+-----------+
        |   a || b    | or(a, b)  |
        +-------------+-----------+
        |   a ^ b     | xor(a, b) |
        +-------------+-----------+
        |   a + b     | add(a, b) |
        +-------------+-----------+
        |   a - b     | sub(a, b) |
        +-------------+-----------+
        |   a * b     | mul(a, b) |
        +-------------+-----------+
        |   a / b     | div(a, b) |
        +-------------+-----------+
        |   a % b     | mod(a, b) |
        +-------------+-----------+
        |   a >> b    | shr(a, b) |
        +-------------+-----------+
        |   a << b    | shl(a, b) |
        +-------------+-----------+
        
        https://docs.soliditylang.org/en/v0.6.2/yul.html
    */
}
