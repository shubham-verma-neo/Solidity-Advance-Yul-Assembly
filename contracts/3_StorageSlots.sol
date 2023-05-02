//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
contract StorageSlots1 {
    uint256 x = 2; // slot 0 ideally
    uint256 y = 45; // slot 1 ideally
    uint256 z = 87; // slot 2 ideally
    uint128 a = 1; // slot 3 ideally
    uint128 b = 2; // slot 4 ideally

    function setX(uint256 newVal) external {
        x = newVal;
    }

    function getX() external view returns (uint256) {
        return x;
    }

    function getXinYul() external view returns (uint256 result) {
        assembly {
            result := sload(x.slot)
        }
        return result;
    }

    function getVarinYulBySlotUint256(uint256 slot)
        external
        view
        returns (uint256 result)
    {
        assembly {
            result := sload(slot)
        }
        return result;
    }

    function getVarinYulBySlotBytes32(uint256 slot)
        external
        view
        returns (bytes32 result)
    {
        assembly {
            result := sload(slot)
        }
        return result;
    }

    function setVarinYul(uint256 slot, uint256 value) external {
        //Dangerous
        assembly {
            sstore(slot, value)
        }
    }

    function getSlot() external pure returns (uint256 Aslot, uint256 Bslot) {
        assembly {
            Aslot := a.slot
            Bslot := b.slot
        }
    }
}

contract StorageSlots2 {
    uint128 public C = 4;
    uint96 public D = 6;
    uint16 public E = 8;
    uint8 public F = 1;

    function readBySlot(uint256 slot) external view returns (bytes32 result) {
        assembly {
            result := sload(slot)
        }
    }

    function getOffsetE() external pure returns (uint256 slot, uint256 offset) {
        assembly {
            slot := E.slot
            offset := E.offset
        }
    }

    // Shifting is preferred to division because it costs less gas
    function readE()
        external
        view
        returns (
            uint16 e,
            uint256 e1,
            uint256 e2
        )
    {
        assembly {
            let value := sload(E.slot) // must load in 32 bytes increments

            //E.offset = 28
            let shifted := shr(mul(E.offset, 8), value)

            // equivalent to
            //
            e := and(0xffffffff, shifted)
            e1 := and(0xffffffff, shifted)
            e2 := and(0xffff, shifted)
        }
    }

    function readEalt() external view returns (uint16 e, uint256 e1) {
        assembly {
            let slot := sload(E.slot)
            let offset := sload(E.offset)
            let value := sload(E.slot) // must load in 32 bytes increments

            // shift right by 224 = divide by (2 ** 224). below is 2 ** 224 in hex
            let shifted := div(
                value,
                0x1ffff0000000000000000000000000000000000000000000000000000
            )

            e := and(0xffff, shifted)
            e1 := and(0xffffffff, shifted)
        }
    }

    // masks can be harcode because variable storage slot and offsets are fixed
    // V and 00 = 00
    // V and FF = V
    // V or 00 = V
    // function arguments are always 32 bytes long under the hood
    function writeToE(uint16 _newE)
        external
        returns (
            bytes32 c,
            bytes32 clearedE,
            bytes32 newE,
            bytes32 shiftedNewE,
            bytes32 newVal
        )
    {
        assembly {
            newE := _newE
            // newEr = 0x0000000a00000000000000000000000000000000000000000000000000000000

            c := sload(E.slot) // slot 0
            // c = 0x0001000800000000000000000000000600000000000000000000000000000004

            clearedE := and(
                c,
                0xffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
            // mask     = 0xffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            // c        = 0x0001000800000000000000000000000600000000000000000000000000000004
            // clearedE = 0x0001000000000000000000000000000600000000000000000000000000000004

            shiftedNewE := shl(mul(E.offset, 8), newE)
            // shiftedNewE = 0x0000000a00000000000000000000000000000000000000000000000000000000

            newVal := or(shiftedNewE, clearedE)
            // shiftedNewE  = 0x0000000a00000000000000000000000000000000000000000000000000000000
            // clearedE     = 0x0001000000000000000000000000000600000000000000000000000000000004
            // newVal       = 0x0001000a00000000000000000000000600000000000000000000000000000004
            sstore(C.slot, newVal)
        }
    }
}
*/

contract StorageComplex {
    struct myStruct {
        string name;
        uint16 age;
    }

    uint256[3] fixedArray;
    uint256[] bigArray;
    uint8[] smallArray;
    mapping(uint256 => uint256) public myMapping;
    mapping(uint256 => mapping(uint256 => uint256)) public nsetedMapping;
    mapping(address => uint256[]) public addressToList;

    constructor() {
        fixedArray = [99, 999, 9999];
        bigArray = [10, 20, 30];
        smallArray = [1, 2, 3];

        myMapping[10] = 5;
        myMapping[11] = 6;
        nsetedMapping[2][4] = 7;
        addressToList[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = [
            42,
            1337,
            777
        ];

    }

    function fixedArrayView(uint256 index)
        external
        view
        returns (uint256 _fixed)
    {
        assembly {
            _fixed := sload(add(fixedArray.slot, index))
        }
    }

    function bigArrayLength() external view returns (uint256 result) {
        assembly {
            result := sload(bigArray.slot)
        }
    }

    function readBigArrayLocation(uint256 index)
        external
        view
        returns (uint256 result)
    {
        uint256 slot;
        assembly {
            slot := bigArray.slot
        }

        bytes32 location = keccak256(abi.encode(slot));

        assembly {
            result := sload(add(location, index))
        }
    }

    function readSmallArrayLocation(uint256 index)
        external
        view
        returns (bytes32 b32, uint8 u8)
    {
        uint256 slot;
        assembly {
            slot := smallArray.slot
        }

        bytes32 location = keccak256(abi.encode(slot));

        assembly {
            b32 := sload(add(location, index))
            u8 := sload(add(location, index))
        }
    }

    function getMapping(uint256 key) external view returns (uint256 result) {
        uint256 slot;
        assembly {
            slot := myMapping.slot
        }

        bytes32 location = keccak256(abi.encode(key, uint256(slot)));

        assembly {
            result := sload(location)
        }
    }

    function getNestedMapping(uint256 key1, uint256 key2)
        external
        view
        returns (uint256 result)
    {
        uint256 slot;
        assembly {
            slot := nsetedMapping.slot
        }

        bytes32 location = keccak256(
            abi.encode(key2, keccak256(abi.encode(key1, uint256(slot))))
        );

        assembly {
            result := sload(location)
        }
    }

    function lengthOfNestedArray(address _address)
        external
        view
        returns (uint256 result)
    {
        uint256 addressToListSlot;
        assembly {
            addressToListSlot := addressToList.slot
        }

        bytes32 location = keccak256(abi.encode(_address, addressToListSlot));

        assembly {
            result := sload(location)
        }
    }

    function getAddressToList(address _address, uint256 index)
        external
        view
        returns (uint256 result)
    {
        uint256 addressToListSlot;
        assembly {
            addressToListSlot := addressToList.slot
        }

        bytes32 location = keccak256(
            abi.encode(keccak256(abi.encode(_address, addressToListSlot)))
        );

        assembly {
            result := sload(add(location, index))
        }
    }
}