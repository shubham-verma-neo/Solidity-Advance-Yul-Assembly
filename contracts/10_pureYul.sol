// SPDX-License-Identifier: MIT

    /*

    To Learn

    - constructor
    - yul doesn't have to respect the calldata
    - how compile yul
    - how to interacte with the yul
    - custom code in the constructor

    - https://docs.soliditylang.org/en/develop/yul.html#complete-erc20-example
    
    */

object "Simple" {

    code{
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    object "runtime"{
        // code{
        //     mstore(0x00, 2)
        //     return(0x00, 0x20)
        // }

        code{
            datacopy(0x00, dataoffset("Message"), datasize("Message"))
            return(0x00, datasize("Message"))
        }

        data "Message" "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor"
    }
}

/*
    Good usecase for 100% YUL

        1. deploying lots of small contracts that are easy to read in bytecode form
        2. doing arbitrage or EVM

    Bad usecase
    
        1. need to verified
        2. medium or large
*/
