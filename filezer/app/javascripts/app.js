const createKeccakHash = require('keccak')
// import { web3 as Web3} from 'web3';

// // // Import libraries we need.
// // import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

var accounts;
var account;

var description;

const abi = [{"constant":false,"inputs":[{"name":"fileHash","type":"string"},{"name":"description","type":"string"}],"name":"saveFile","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"fileHash","type":"string"}],"name":"retrieveFile","outputs":[{"name":"","type":"address"},{"name":"","type":"string"},{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"name":"owner","type":"address"},{"indexed":false,"name":"fileDescription","type":"string"},{"indexed":false,"name":"timeAdded","type":"uint256"}],"name":"FileAdded","type":"event"}];
const contractAddress = '0x9f6b5E2091Cd46fEe132d5f84695b9EaeEaBeb1E'

var filezerContract;
var filezer;

var eventsList;
var messageDiv;


window.App = {
  start: function() {
    var self = this;

    eventsList = document.getElementById("events_list")
    messageDiv = document.getElementById("message")

    //initialize contract
    accounts =  web3.eth.accounts;
    account = accounts[0]

    filezerContract = web3.eth.contract(abi);
    filezer = filezerContract.at(contractAddress);

    filezer.FileAdded().watch(function(err, response){  
      
      console.log(response)
      var eventResponse = response.args;
      var owner = eventResponse.owner
      var fileDescription = eventResponse.fileDescription
      var timeAdded = new Date(parseInt(eventResponse.timeAdded) * 1000)
      
      if (!err)
      {
        if(eventsList.innerHTML.indexOf('No Transaction Found') >= 0){
          eventsList.innerHTML = ""
        }

        eventsList.insertAdjacentHTML('beforeend', '<li>Transaction Hash - </li>' + response.transactionHash +
       '\nOwner - '+  owner + '\nFile Description - '+ fileDescription + '\nTime Added - '+ timeAdded)
      }
      else
          alert("An error occurred - "+ err);
    });
  },

  submitFile: function ()
  {
    var file = document.getElementById("file").files[0]; 
    if(file) 
    { 
      description = document.getElementById("description").value; 

      if(description.trim().length == 0) { 
        alert("Enter a good description of the file"); 
        return;
      }
      else
      {
        var reader = new FileReader();
        reader.readAsText(file, "UTF-8");
        reader.onload = function (evt) {
                   
            var fileHash = createKeccakHash('keccak256').update(evt.target.result).digest('hex').toString()
            // console.log(fileHash)
            //store file using ipfs or swarm 
            ///.....
            //send to blockchain
            filezer.saveFile(fileHash, description, function (error, result) {
             
              if (!error)
              {
                // console.log(result); ///result is the tx hash
                messageDiv.innerHTML = 'Transaction Hash - ' + result;
              }                
              else
              {
                alert(error);
              }
                
            });              
        }
        reader.onerror = function (evt) {
          alert("An error occurred while processing the file!"); 
        }
      }
    }
  },
  retrieveFile: function ()
  {   
    const fileHash = document.getElementById("fileHash").value;
    
    filezer.retrieveFile(fileHash, function (error, result) {
      
      if (!error)
      {
        messageDiv.innerHTML = 'Owner - '+ result[0] + '\r\n Description - ' +  result[1] +
        '\r\nTime added - ' + new Date(parseInt(result[2] * 1000)); //get time in milliseconds
      }                
      else
        console.log(error);
    });             

  }
};

window.addEventListener('load', function() {
  //Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
     // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:9545"));
  }

  App.start();
});
