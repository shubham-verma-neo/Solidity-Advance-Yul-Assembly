//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract YulTypes {
    function myNumber() public pure returns (uint256) {
        uint256 x;

        assembly {
            x := 45
        }

        return x;
    }

    function myHex() public pure returns (uint256) {
        uint256 x;

        assembly {
            x := 0xa
        }

        return x;
    }

    function myStringAsString() public pure returns (string memory) {
        string memory x = "";

        assembly {
            x := "my String"
        }

        return x;
    }

    function myStringAsHex() public pure returns (bytes32) {
        bytes32 x;

        assembly {
            x := "my String"
        }

        return x;
    }

    function myStringAsHexInReadingForm() public pure returns (string memory) {
        bytes32 x;

        assembly {
            x := "my String"
        }

        return string(abi.encode(x));
    }

    // function myStringAsHex32Plus() public pure returns (bytes32) {
    //     bytes32 x;

    //     assembly {
    //         x := "Hello World How ALl Are You... I Am"
    //     }

    //     return x;
    // }

        function myBool() public pure returns (bool) {
        bool x;

        assembly {
            x := 1
        }

        return x;
    }
}
