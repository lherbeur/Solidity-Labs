pragma solidity ^0.4.11;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

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
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
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
            //     oraclize_query(60, "URL", "json(http://api.fixer.io/latest?symbols=USD,GBP).rates.GBP", 500000);
            
            // bytes32 queryId =
            //     oraclize_query(60, "URL", "json(https://api.random.org/json-rpc/1/invoke).result.random.data", 
            //     "\n{\"jsonrpc\": \"2.0\", \"method\": \"generateSignedIntegers\", \"params\": { \"apiKey\": \"00000000-0000-0000-0000-000000000000\", \"n\": 10, \"min\": 1, \"max\": 1000, \"replacement\": true, \"base\": 10 },  \"id\": 14215}", 500000);
            
             bytes32 queryId =
                oraclize_query("nested", "[URL] ['BGI2gWXuVedIBlkhYABBYP862dVSqoJWIy6z+s8L3IdfArJip3hLvcI3+e27dMwuDZh6l+ShYViL3OaGj+EJfqzYxqEX2DqP6nhBzMAtZCIUt/wI19RBrx5j9pZT5ElT31IxMZIO+PnpGZu98Igmksm9ouH1UXm189KZut7htyWaPlAL66r981JyT7EWGh3CGX0=', 'BCIlQkMsucabdrcLl8nA+AD00BB0JwpRPlmbQGn1ODTbzumVA/z1ViFxVbbCzR/uZ3Oy0BpkFuyMOyvUXenuz7cWToZH+7QypOFZa0VZtZwvsWdBHfJ+50eNsdegQ1YAbgpKij1vIA6sgqhZUHUBlTu7dNX5SIekswOcccLTh710m93SHRmGSx7KGrYfD+JLsJ46mfJvdsC6aiFvpJvB79qxGN/pypF8TLT9gh/YHk+2swzLQGVCf6HHlqNB2LWbKEh0QstPsUruW9yH6VrZ6YrCR+52NA+Cv5AXc9/V8hOKBvarzr+yOocx5m7ySdR7joFbQ15nIaqxFQV021c3sBa6c1Aum1oxjEZJCFh6uNrFsZI4ZC7xtA==']");
            // this works and gets the array of random numbers, shows under the oraclize tab in the Oraclize IDE, but is not emitted by the event like others. thinking the proof might be the issue. 
            
            validIds[queryId] = true;
        }
    }
}
