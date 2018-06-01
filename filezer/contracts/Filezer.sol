pragma solidity ^0.4.17;

contract Filezer
{

struct FileDetails
{
    address owner;
    string fileDescription;
    uint timeAdded;
}

mapping (string => FileDetails) files;

event FileAdded(address owner, string fileDescription, uint timeAdded);
// event FileRetrieved(address retriever, string fileDescription, uint timeRetrieved); //no need for an event since soemthing is returned in the call

function saveFile(string fileHash, string description)
{
    require (files[fileHash].timeAdded == 0);
    files[fileHash] = FileDetails({
                         owner: msg.sender,
                         fileDescription: description,
                         timeAdded: now
                        });
    FileAdded(msg.sender, description, now);           
}

function retrieveFile(string fileHash) view 
returns (address, string, uint)//checks for only the hash and not both the hash and address
{
    FileDetails fileDetails = files[fileHash];
    return (fileDetails.owner, fileDetails.fileDescription, fileDetails.timeAdded);
}

}

