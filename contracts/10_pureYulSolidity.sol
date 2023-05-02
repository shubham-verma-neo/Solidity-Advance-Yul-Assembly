// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISimple{
    function itDoesntMatterBecauseItJustReturns2()external view returns(uint256);
}

contract pureYulSolidity{
    ISimple public target;

    constructor(ISimple _target){
        target = _target;
    }

    function callSimpleUint()external view returns(uint256){
        return target.itDoesntMatterBecauseItJustReturns2();
    }

    function callSimpleString()external view returns(string memory){
        (bool success, bytes memory result) = address(target).staticcall("");
        require(success, "failed");
        return string(result);
    }
}