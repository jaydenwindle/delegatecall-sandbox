object "Sandbox" {
    code {
        let size := datasize("runtime")
        datacopy(0, dataoffset("runtime"), size)
        return(0, size)
    }
    object "runtime" {
        code {
            // revert if caller is not owner
            if iszero(eq(caller(), 0xffffffffffffffffffffffffffffffffffffffff)) {
                revert(returndatasize(), returndatasize())
            }

            // copy calldata to memory
            calldatacopy(returndatasize(), returndatasize(), calldatasize())

            // execute delegatecall
            let success := delegatecall(
                gas(),
                shr(96, mload(returndatasize())),
                20,
                sub(calldatasize(), 20),
                returndatasize(),
                returndatasize()
            )

            // copy returndata to memory
            returndatacopy(0, 0, returndatasize())

            if iszero(success) {
                // delegatecall failed, revert and bubble up error
                revert(0, returndatasize())
            }

            // delegatecall succeeded, return result
            return(0, returndatasize())
        }
    }
}
