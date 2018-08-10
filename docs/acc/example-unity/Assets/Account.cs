using System.Collections;
using System.Collections.Generic;
// Here we import the Netherum.JsonRpc methods and classes.
using Nethereum.ABI.Encoders;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Contracts;
using Nethereum.Hex.HexConvertors.Extensions;
using Nethereum.Hex.HexTypes;
using Nethereum.JsonRpc.Client;
using Nethereum.JsonRpc.UnityClient;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.RPC.Eth.Transactions;
using Nethereum.Signer;
using Nethereum.Util;
using UnityEngine;
using UnityEngine.UI;

public class Account : MonoBehaviour
{
	public Text		  textSetDNAStatus;

	public InputField inputWallet;
	public InputField inputPrivateKey;
	public InputField inputSetDNAItemID;
	public InputField inputSetDNADNA;

	public InputField inputGetDNAItemID;
	public InputField inputGetDNAAddress;
	public InputField inputGetDNADNA;
	public InputField inputGetItemsResult;

private string ownershipABI = " [ { \"constant\": true, \"inputs\": [], \"name\": \"name\", \"outputs\": [ { \"name\": \"\", \"type\": \"string\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_tokenId\", \"type\": \"uint256\" } ], \"name\": \"getApproved\", \"outputs\": [ { \"name\": \"\", \"type\": \"address\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_to\", \"type\": \"address\" }, { \"name\": \"_tokenId\", \"type\": \"uint256\" } ], \"name\": \"approve\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [], \"name\": \"ceoAddress\", \"outputs\": [ { \"name\": \"\", \"type\": \"address\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [], \"name\": \"totalSupply\", \"outputs\": [ { \"name\": \"\", \"type\": \"uint256\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_from\", \"type\": \"address\" }, { \"name\": \"_to\", \"type\": \"address\" }, { \"name\": \"_tokenId\", \"type\": \"uint256\" } ], \"name\": \"transferFrom\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_newCEO\", \"type\": \"address\" } ], \"name\": \"setCEO\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_owner\", \"type\": \"address\" }, { \"name\": \"_index\", \"type\": \"uint256\" } ], \"name\": \"tokenOfOwnerByIndex\", \"outputs\": [ { \"name\": \"\", \"type\": \"uint256\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [], \"name\": \"unpause\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_from\", \"type\": \"address\" }, { \"name\": \"_to\", \"type\": \"address\" }, { \"name\": \"_tokenId\", \"type\": \"uint256\" } ], \"name\": \"safeTransferFrom\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_tokenId\", \"type\": \"uint256\" } ], \"name\": \"exists\", \"outputs\": [ { \"name\": \"\", \"type\": \"bool\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_index\", \"type\": \"uint256\" } ], \"name\": \"tokenByIndex\", \"outputs\": [ { \"name\": \"\", \"type\": \"uint256\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [], \"name\": \"paused\", \"outputs\": [ { \"name\": \"\", \"type\": \"bool\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [], \"name\": \"withdrawBalance\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_tokenId\", \"type\": \"uint256\" } ], \"name\": \"ownerOf\", \"outputs\": [ { \"name\": \"\", \"type\": \"address\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_owner\", \"type\": \"address\" } ], \"name\": \"balanceOf\", \"outputs\": [ { \"name\": \"\", \"type\": \"uint256\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [], \"name\": \"pause\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_address\", \"type\": \"address\" } ], \"name\": \"hasAccess\", \"outputs\": [ { \"name\": \"\", \"type\": \"bool\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [], \"name\": \"symbol\", \"outputs\": [ { \"name\": \"\", \"type\": \"string\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_to\", \"type\": \"address\" }, { \"name\": \"_approved\", \"type\": \"bool\" } ], \"name\": \"setApprovalForAll\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_address\", \"type\": \"address\" }, { \"name\": \"_isAllowed\", \"type\": \"bool\" } ], \"name\": \"setAccess\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, {\"constant\": false, \"inputs\": [ { \"name\": \"_from\", \"type\": \"address\" }, { \"name\": \"_to\", \"type\": \"address\" }, { \"name\": \"_tokenId\", \"type\": \"uint256\" }, { \"name\": \"_data\", \"type\": \"bytes\" } ], \"name\": \"safeTransferFrom\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_owner\", \"type\": \"address\" }, { \"name\": \"_operator\", \"type\": \"address\" } ], \"name\": \"isApprovedForAll\", \"outputs\": [ { \"name\": \"\", \"type\": \"bool\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"inputs\": [ { \"name\": \"_name\", \"type\": \"string\" }, { \"name\": \"_symbol\", \"type\": \"string\" }, { \"name\": \"_baseTokenURI\", \"type\": \"string\" } ], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"constructor\" }, { \"payable\": true, \"stateMutability\": \"payable\", \"type\": \"fallback\" }, { \"anonymous\": false, \"inputs\": [], \"name\": \"Pause\", \"type\": \"event\" }, { \"anonymous\": false, \"inputs\": [], \"name\": \"Unpause\", \"type\": \"event\" }, { \"anonymous\": false, \"inputs\": [ { \"indexed\": true, \"name\": \"_from\", \"type\": \"address\" }, { \"indexed\": true, \"name\": \"_to\", \"type\": \"address\" }, { \"indexed\": false, \"name\": \"_tokenId\", \"type\": \"uint256\" } ], \"name\": \"Transfer\", \"type\": \"event\" }, { \"anonymous\": false, \"inputs\": [ { \"indexed\": true, \"name\": \"_owner\", \"type\": \"address\" }, { \"indexed\": true, \"name\": \"_approved\", \"type\": \"address\" }, { \"indexed\": false, \"name\": \"_tokenId\", \"type\": \"uint256\" } ], \"name\": \"Approval\", \"type\": \"event\" }, { \"anonymous\": false, \"inputs\": [ { \"indexed\": true, \"name\": \"_owner\", \"type\": \"address\" }, { \"indexed\": true, \"name\": \"_operator\", \"type\": \"address\" }, { \"indexed\": false, \"name\": \"_approved\", \"type\": \"bool\" } ], \"name\": \"ApprovalForAll\", \"type\": \"event\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_newBaseURI\", \"type\": \"string\" } ], \"name\": \"setBaseTokenURI\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_useTokenForURI\", \"type\": \"bool\" } ], \"name\": \"setUseTokenForURI\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_tokenId\", \"type\": \"uint256\" } ], \"name\": \"tokenURI\", \"outputs\": [ { \"name\": \"\", \"type\": \"string\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_owner\", \"type\": \"address\" } ], \"name\": \"itemsOf\", \"outputs\": [ { \"name\": \"\", \"type\": \"uint256[]\" }, { \"name\": \"\", \"type\": \"uint256[]\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_owner\", \"type\": \"address\" } ], \"name\": \"packDefsOf\", \"outputs\": [ { \"name\": \"\", \"type\": \"uint256[]\" }, { \"name\": \"\", \"type\": \"uint256[]\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_owner\", \"type\": \"address\" } ], \"name\": \"itemDefsOf\", \"outputs\": [ { \"name\": \"\", \"type\": \"uint256[]\" }, { \"name\": \"\", \"type\": \"uint256[]\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_to\", \"type\": \"address\" }, { \"name\": \"_itemId\", \"type\": \"uint256\" } ], \"name\": \"mintItemTo\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_to\", \"type\": \"address\" }, { \"name\": \"_packId\", \"type\": \"uint256\" } ], \"name\": \"mintPackDefTo\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_to\", \"type\": \"address\" }, { \"name\": \"_itemId\", \"type\": \"uint256\" } ], \"name\": \"mintItemDefTo\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" } ]";

	// ItemManager ABI
private string itemManagerABI = " [ { \"constant\": true, \"inputs\": [], \"name\": \"ceoAddress\", \"outputs\": [ { \"name\": \"\", \"type\": \"address\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_newCEO\", \"type\": \"address\" } ], \"name\": \"setCEO\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [], \"name\": \"unpause\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [], \"name\": \"paused\", \"outputs\": [ { \"name\": \"\", \"type\": \"bool\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [], \"name\": \"withdrawBalance\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [], \"name\": \"pause\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_address\", \"type\": \"address\" } ], \"name\": \"hasAccess\", \"outputs\": [ { \"name\": \"\", \"type\": \"bool\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_address\", \"type\": \"address\" }, { \"name\": \"_isAllowed\", \"type\": \"bool\" } ], \"name\": \"setAccess\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"inputs\": [ { \"name\": \"_storageAddress\", \"type\": \"address\" } ], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"constructor\" }, { \"payable\": true, \"stateMutability\": \"payable\", \"type\": \"fallback\" }, { \"anonymous\": false, \"inputs\": [ { \"indexed\": false, \"name\": \"id\", \"type\": \"uint256\" } ], \"name\": \"ItemCreated\", \"type\": \"event\" }, { \"anonymous\": false, \"inputs\": [], \"name\": \"Pause\", \"type\": \"event\" }, { \"anonymous\": false, \"inputs\": [], \"name\": \"Unpause\", \"type\": \"event\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_itemId\", \"type\": \"uint256\" } ], \"name\": \"itemExists\", \"outputs\": [ { \"name\": \"\", \"type\": \"bool\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [], \"name\": \"createItem\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_itemId\", \"type\": \"uint256\" }, { \"name\": \"_dna\", \"type\": \"uint256\" } ], \"name\": \"setDNA\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_itemId\", \"type\": \"uint256\" }, { \"name\": \"_game\", \"type\": \"address\" }, { \"name\": \"_token\", \"type\": \"uint256\" }, { \"name\": \"_dna\", \"type\": \"uint256\" } ], \"name\": \"setMutableDNA\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [], \"name\": \"getItemCount\", \"outputs\": [ { \"name\": \"\", \"type\": \"uint256\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_itemId\", \"type\": \"uint256\" }, { \"name\": \"_game\", \"type\": \"address\" } ], \"name\": \"getDNA\", \"outputs\": [ { \"name\": \"\", \"type\": \"uint256\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": true, \"inputs\": [ { \"name\": \"_itemId\", \"type\": \"uint256\" }, { \"name\": \"_game\", \"type\": \"address\" }, { \"name\": \"_token\", \"type\": \"uint256\" } ], \"name\": \"getMutableDNA\", \"outputs\": [ { \"name\": \"\", \"type\": \"uint256\" } ], \"payable\": false, \"stateMutability\": \"view\", \"type\": \"function\" }, { \"constant\": false, \"inputs\": [ { \"name\": \"_count\", \"type\": \"uint256\" } ], \"name\": \"createItems\", \"outputs\": [], \"payable\": false, \"stateMutability\": \"nonpayable\", \"type\": \"function\" } ]";

	/// ItemManager Address
	private string ownershipContractAddress = "0xf403ffc5bfa75f622a3a00ac9fc1480e723b259c";
	private string itemManagerContractAddress = "0x8fbb25f6272316651d14b521a8334b0be7d1ba51";

	/// We're using Infura
	public string url = "https://rinkeby.infura.io";

	/// Called when Set DNA button is pressed
	public void OnSetDNA()
	{
		StartCoroutine(SetDNA());
	}

	/// Called when Get DNA button is pressed
	public void OnGetDNA()
	{
		StartCoroutine(GetDNA());
	}

	/// Called when Get Items button is pressed
	public void OnGetItems()
	{
		StartCoroutine(GetItems());
	}



	/// Sets the DNA based on the input fields
	/// 1. Estimate Gas parameter
	/// 2. Send transaction
	/// 3. Wait for receipt
	private IEnumerator SetDNA()
	{
		string wallet = inputWallet.text;
		string privateKey = inputPrivateKey.text;

		var contract = new Contract(null, itemManagerABI, itemManagerContractAddress);
        var function = contract.GetFunction("setDNA");

		EthEstimateGasUnityRequest estimateRequest = new EthEstimateGasUnityRequest(url);
        TransactionInput estimateInput = function.CreateTransactionInput(wallet, inputSetDNAItemID.text, inputSetDNADNA.text);
        yield return estimateRequest.SendRequest(estimateInput);
        if (estimateRequest.Exception != null)
        {
			Debug.Log(estimateRequest.Exception);
            yield break;
		}

		Debug.Log("Gas: " + estimateRequest.Result.Value);

		var req = new TransactionSignedUnityRequest(url, privateKey, wallet);

		var callInput = function.CreateTransactionInput(
			wallet,
			estimateRequest.Result,
			new HexBigInteger("0x0"),
			inputSetDNAItemID.text,
			inputSetDNADNA.text);
		yield return req.SignAndSendTransaction(callInput);

		textSetDNAStatus.text = "waiting";

		var receiptRequest = new EthGetTransactionReceiptUnityRequest(url);

		bool done = false;
		while (!done)
		{
			yield return receiptRequest.SendRequest(req.Result);

			if (receiptRequest.Result != null)
				done = true;

			yield return new WaitForSeconds(1.0f);
		}

		textSetDNAStatus.text = "done";

	}

	/// Gets the DNA based on the input fields
	private IEnumerator GetDNA()
    {
		var req = new EthCallUnityRequest(url);
        var contract = new Contract(null, itemManagerABI, itemManagerContractAddress);
        var function = contract.GetFunction("getDNA");
        var callInput = function.CreateCallInput(inputGetDNAItemID.text, inputGetDNAAddress.text);
        var blockParameter = Nethereum.RPC.Eth.DTOs.BlockParameter.CreateLatest();
        yield return req.SendRequest(callInput, blockParameter);

		inputGetDNADNA.text = req.Result;
    }

/// Gets the items based on the input fields
private IEnumerator GetItems()
	{
	var req = new EthCallUnityRequest(url);
			var contract = new Contract(null, ownershipABI, ownershipContractAddress);
			var function = contract.GetFunction("itemsOf");
			var callInput = function.CreateCallInput(inputGetDNAAddress.text);
			var blockParameter = Nethereum.RPC.Eth.DTOs.BlockParameter.CreateLatest();
			yield return req.SendRequest(callInput, blockParameter);

	inputGetItemsResult.text = req.Result;
	}
}
