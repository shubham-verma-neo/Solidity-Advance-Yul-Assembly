//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
Solidity Memory 

Memory is a prerequisite
- You need memory to do the following
    - Return values to external calls
    - Set the function arguments for external calls
    - Get value from external calls
    - Revert with an error string
    - Log message
    - Create other Smart Contract
    - Use the keccak256 hash function

Overview
- Equivalent to heap in other languages
    - But there is no garbage collector or free 
    - Solidity memory is laid out in 32 bytes sequence
    - [0x00 - 0x20) [0x20 - 0x40) [0x40 - 0x60) [0x60 - 0x80) [0x80 - 0x100)..
- Only four instructions: mload, mstore, mstore8, msize
- In pure yul programs, memory is easy to use. But in mixed solidity/yul programs, solidity
  expects memory to be used in a specific manner.
- Important You are chrged gas for each memory access, and for how far into the memory array
  you accessed.
- mload(0xffffffffffffffff) will run out of gas. Demo!
    - Using a hash function to mstore like storage does is a bad idea!
- mstore(p, v) stores value v in slot p (just like sload)
- mload(p) reterives 32 bytes from the slot [p..0x20]
- mstore8(p, v) like mstore but for 1 byte
- msize() largest accessed memory index in that transaction 


How Solidity Uses Memory
- Slidity allocates slots [0x00-0x20), [0x20-0x40) for "scratch space"
- Solidty reserves slot [0x40-0x60) as the "free memory pointer"
- Solidity keeps slot [0x60-0x80) empty
- The action begins in slot [0x80-..)

- Solidity use memory for
    - abi.encode and abi.encodePacked
    - Structs and Arrays (but you explicity need the memory keyboard)
    - When structs and arrays are declared memory in the function arguments
    - Besause objects in memory are laid out end to end, arrays have no push unlike storage
- In Yul
    - The variable itself is where it begins in memory
    - To access the dynamic array, you have to add 32 bytes or 0x20 to skip the length


Gotcahs
- If you don't respect solidity's memory layout and free memory pointer, 
   you can get some serious bugs!
- The EVM memory does not try to pack datatypes smaller than 32 bytes
- If you load storage to memory, it will be unpacked
*/
/*
contract Memory {
    struct Point {
        uint256 x;
        uint256 y;
        uint256 z;
    }

    event MemoryPointer(bytes32);
    event MemoryPointerMsize(bytes32, bytes32);

    function highAccess() external pure {
        assembly {
            //pop just throws away the return value
            pop(mload(0xffffffffffffffff))
        }
    }

    function mstore8() external pure {
        assembly {
            mstore8(0x00, 7)
            mstore(0x00, 7)
        }
    }

    function memPointerV1() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }

        emit MemoryPointer(x40);

        Point memory p = Point({x: 1, y: 2, z: 3});
        assembly {
            x40 := mload(0x40)
        }

        emit MemoryPointer(x40);
    }

    function memPointerV2() external {
        bytes32 x40;
        bytes32 _msize;
        assembly {
            x40 := mload(0x40)
            _msize := msize()
        }

        emit MemoryPointerMsize(x40, _msize);

        Point memory p = Point({x: 1, y: 2, z: 3});
        assembly {
            x40 := mload(0x40)
            _msize := msize()
        }

        emit MemoryPointerMsize(x40, _msize);

        assembly {
            pop(mload(0xff))
            x40 := mload(0x40)
            _msize := msize()
        }

        emit MemoryPointerMsize(x40, _msize);
    }

    function fixedArray() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }

        emit MemoryPointer(x40);

        uint256[2] memory p = [uint256(2), uint256(3)];
        assembly {
            x40 := mload(0x40)
        }

        emit MemoryPointer(x40);
    }

    function abiEncode1() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);

        abi.encode(uint256(5), uint256(19));

        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    function abiEncode2() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);

        abi.encode(uint256(5), uint128(19));

        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    function abiEncodePacked1() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);

        abi.encodePacked(uint256(5), uint256(19));

        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    function abiEncodePacked2() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);

        abi.encodePacked(uint256(5), uint128(19));

        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    event Debug(bytes32, bytes32, bytes32, bytes32);

    function args(uint256[] memory arr) external {
        bytes32 location;
        bytes32 len;
        bytes32 valueAtIndex0;
        bytes32 valueAtIndex1;
        assembly {
            location := arr
            len := mload(arr)
            valueAtIndex0 := mload(add(arr, 0x20))
            valueAtIndex1 := mload(add(arr, 0x40))
        }
        emit Debug(location, len, valueAtIndex0, valueAtIndex1);
    }

    function breakFreeMemoryPointer(uint256[1] memory foo)
        external
        view
        returns (uint256)
    {
        assembly {
            mstore(0x40, 0x80)
        }

        uint256[1] memory bar = [uint256(6)];

        return foo[0];
    }

    uint8[] foo = [1, 2, 3, 4, 5, 6];

    function unpacked() external {
        uint8[] memory bar = foo;
    }
}
*/
// /*
contract UsinMemory {
    function return2and4() external pure returns (uint256, uint256) {
        assembly {
            mstore(0x00, 2)
            mstore(0x20, 4)
            return(0x00, 0x40)
        }
    }

    function requireV1() external view {
        require(msg.sender == 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
    }

    function requireV2() external view {
        assembly {
            if iszero(
                eq(caller(), 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)
            ) {
                revert(0, 0)
            }
        }
    }

    function hashV1()external pure returns(bytes32, bytes memory){
        bytes memory toBeHashed = abi.encode(1,2,3);
        return (keccak256(toBeHashed), toBeHashed);
    }

    function hashV2()external pure returns(bytes32){
        assembly{
            let freeMemoryPointer := mload(0x40)

            // store 1,2,3  in memory
            mstore(freeMemoryPointer, 1)
            mstore(add(freeMemoryPointer, 0x20), 2)
            mstore(add(freeMemoryPointer, 0x40), 3)

            // update memory pointer
            mstore(0x40, add(freeMemoryPointer, 0x60))

            mstore(0x00, keccak256(freeMemoryPointer, 0x60))
            return(0x00, 0x20)
        }
    }
}
// */