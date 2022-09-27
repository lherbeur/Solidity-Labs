pragma solidity ^0.4.11;

import "installed_contracts/oraclize/contracts/usingOraclize.sol";


contract ExampleContract is usingOraclize {

    string public EURGBP;
    // uint256 [] public EURGBP;
    mapping(bytes32=>bool) validIds;
    event LogConstructorInitiated(string nextStep);
    event LogPriceUpdated(string price);
    event LogNewOraclizeQuery(string description);

    // This example requires funds to be send along with the contract deployment
    // transaction
    function ExampleContract() payable {
        oraclize_setCustomGasPrice(4000000000);
        LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Oraclize Query.");
    }

    function __callback(bytes32 myid, string result) {
        if (!validIds[myid]) revert();
        if (msg.sender != oraclize_cbAddress()) revert();
        EURGBP = result;
        LogPriceUpdated(result);
        delete validIds[myid];
        //updatePrice();
    }

    function updatePrice() payable {
        if (oraclize_getPrice("URL") > this.balance) {
            LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
           // bytes32 queryId =
                //oraclize_query(60, "URL", "json(http://api.fixer.io/latest?symbols=USD,GBP).rates.GBP", 500000);
            
            bytes32 queryId =
                oraclize_query(60, "URL", "json(https://api.random.org/json-rpc/1/invoke).result.random.data", 
                "\n{\"jsonrpc\": \"2.0\", \"method\": \"generateSignedIntegers\", \"params\": { \"apiKey\": \"00000000-0000-0000-0000-000000000000\", \"n\": 10, \"min\": 1, \"max\": 1000, \"replacement\": true, \"base\": 10 },  \"id\": 14215}", 500000);
            
            
            validIds[queryId] = true;
        }
    }
}
