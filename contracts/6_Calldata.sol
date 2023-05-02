//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

    /*
    How Geth Constructs Transactions

    func NewMessage(){

        return Message{
            from : from,            <------ tx.origin/origin()
            to: to,                 <------ wallet/smart contract address
            nonce: nonce,
            amount: amount,         <------ msg.value/callvalue()
            gasLimt; gasLimit,
            gasPrice: gasPrice,     <------ gasprice()
            gasFeeCap: gasFeeCap,
            gasTipCap: gasTipCap,
            data: data,             <------ tx.data/ calldatalog
            accessList: accessList,
            isFake: isFake,
        }
    }

    Tx.data can be arbitary - only constrained by gas cost

    Convention

    - Solidity's dominance has enforced a convention on how tx.data is used
    - When sending to a wallet, you don't put any data in unlessyou are trying
        to send that person a message (hackers have used this field for taunts)
    - When sending to a smart contract, the first four bytes specify which function you are 
        calling, and the bytes to follow are abi encoded function arguments
    - https://docs.soliditylang.org/en/develop/abi-spec.html#abi
    - Solidity expects the bytes after the function  selector to always be a multiple of 32
        in length, but this is convention
    - If you send more bytes, solidity will ignore them
    - But a yul smart contract can be programmed to respond to arbitrary length tx.data
        in an arbitrary manner

    Overview 
    - Function selector are the first four bytes of the keccak256 of the function signature
    - balanceOf(address _address) -> keccak256("balanceOf(address)") -> 0x70a08231
    - balanceOf(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4)
        -> 0x70a082310000000000000000000000005B38Da6a701c568545dCfcB03FcB875f56beddC4
    - balanceOf(address _address, uint256 id) -> keccak256("balanceOf(address,uint256)") -> 0x00fdd58e
    - balanceOf(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,5)
        -> 0x70a082310000000000000000000000005B38Da6a701c568545dCfcB03FcB875f56beddC40
            000000000000000000000000000000000000000000000000000000000000005
    
    ABI specification
    - Front-end apps knows how to format the transaction based on the abi 
        specification of the contract
    - In solidity, function selector and 32 byte encoded arguements are created under the hood
        by interfaces or if you use
        ab.encodeWithSignature("balanceOf(address)", 0x...)
    - But yul you have to be explicit
    - It doesn't know about function selector, interfaces, or abi encoding
    - If you want to make an external call to a solidity contract, you need to implement all of 
        that yourself 
    */

contract OtherContract{

    // "0c55699c" : "x()"
    uint256 public x;

    // "71e5ee5f" : "arr(uint256)"
    uint256[] public arr;

    // "9a884bde" : "get21()"
    function get21()external pure returns(uint256){
        return 21;
    }

    // "73712595" : "revertWith999()"
    function revertWith999()external pure returns(uint256){
        assembly{
            mstore(0x00, 999)
            revert(0x00, 0x20)
        }
    }

    // "196e6d84" : "multiply(uint128,uint16)"
    function multiply(uint128 _x, uint16 _y)external pure returns(uint256){
        return _x * _y;
    }

    //"4018d911" : "stX(uint256)"
    function setX(uint _x)external{
        x = _x;
    }

    // "7c70b4db" : "variableReturnLength(uint256)"
    function variableReturnLength(uint256 len)external pure returns(bytes memory){
        bytes memory ret = new bytes(len);
        for(uint256 i = 0; i < ret.length; i++){
            ret[i] = 0xab;
        }
        return ret;
    }
}

contract ExternalCalls{
    function externalViewCallNoArgs(address _a)external view returns(uint256){
        assembly{
            mstore(0x00, 0x9a884bde)
            //000000000000000000000000000000000000000000000000000000009a884bde
            //                                                         |     |
            //                                                         28    32
            let success := staticcall(gas(), _a, 28, 30, 0x00, 0x20)
            if iszero(success){
                revert(0, 0)
            }
            return(0x00, 0x20)

        }
    }

    function getViaRevert(address _a)external view returns(uint256){
        assembly{
            mstore(0x00, 0x73712595)
            pop(staticcall(gas(), _a, 28, 32, 0x00, 0x20))
            return(0x00, 0x20)
        }
    }

    function  callMultiply(address _a)external view returns(uint256 result){
        assembly{
            let mptr := mload(0x40)
            let oldMptr := mptr
            mstore(mptr, 0x196e6d84)
            mstore(add(mptr, 0x20), 3)
            mstore(add(mptr, 0x40), 11)
            mstore(0x40, add(mptr, 0x60))// advance the memory pointer 3 x 32 bytes
            //000000000000000000000000000000000000000000000000000000009a884bde
            //0000000000000000000000000000000000000000000000000000000000000003
            //000000000000000000000000000000000000000000000000000000000000000b

            let success :=  staticcall(gas(), _a, add(mptr, 28), mload(0x40), 0x00,0x20)
            if iszero(success){
                revert(0, 0)
            }
            result := mload(0x00)
        }
    }

    function externalStateChangingCall(address _a)external {
        assembly{
            mstore(0x00, 0x4018d9aa)
            mstore(0x20, 999)
            // memory looks like this
            //0x000000000000000000000000000000000000000000000000000000004018d9aa...
            //  00000000000000000000000000000000000000000000000000000000000003e7
            // let success := call(gas(), _a, callvalue(), 28, add(28, 32), 0x00, 0x00)
            let success := call(gas(), _a, 0, 28, add(28, 32), 0x00, 0x00)
            if iszero(success){
                revert(0, 0)
            }
        }
    }

    function unknownReturnSize(address _a, uint256 amount)external view returns(bytes32){
        assembly{
            mstore(0x00, 0x7c70b4db)
            mstore(0x20, amount)
            let success := staticcall(gas(), _a, 28, add(28, 32), 0x00, 0x00)
            if iszero(success){
                revert(0, 0)
            }
            returndatacopy(0, 0, returndatasize())
            return(0, returndatasize())
        }
    }

    function multiplyVariablelength(uint256[] calldata data1, uint256[] calldata data2)external pure returns(bool){
        require(data1.length != data2.length, "invalid");

        //this is often done with hash function, but we want to enforce
        //array is proper for tese
        for(uint256 i = 0; i < data1.length; i++){
            if(data1[i] != data2[i]){
                return false;
            }
        }
        return true;
    }
}