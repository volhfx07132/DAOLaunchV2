// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155.sol";
import "../common/Ownable.sol";
import "../common/Strings.sol";
// import "hardhat/console.sol";


contract DaoLaunchERC1155 is ERC1155, Ownable {
  using Strings for uint256;

  uint256 private _currentTokenID = 0;  // 
  mapping (uint256 => uint256) private tokenSupply; // supply quanlity of tokenId 
  mapping (uint256 => string) private _onlyHolderSecretURI;

  string private baseUri;
  string public name;   // Collection name


  /**
   * @dev Require msg.sender to be one of the holders of the token id
   */
  modifier onlyHolders(uint256 _id) {
    require(_exists(_id), "DaoLaunchERC1155#uri: NONEXISTENT_TOKEN");
    require( balanceOf(msg.sender, _id) > 0, "DaoLaunchERC1155#onlyHolders: ONLY_HOLDER_ALLOWED");
    _;
  }

  
  constructor() ERC1155("https://tokenibo.dev.api-java.bappartners.com/token/1155/{id}.json"){
      baseUri = "https://tokenibo.dev.api-java.bappartners.com/token/1155/";
      name = "DAOLaunch";
  }

  /**
  * contractURI method for OpenSea Metadata Standard
  */
  function contractURI() public view returns (string memory) {
    return baseUri;
  }

  function uri(uint256 _id) public override view returns (string memory) {
    require(_exists(_id), "DaoLaunchERC1155#uri: NONEXISTENT_TOKEN");
    
    if(bytes(baseUri).length > 0)
      return string(abi.encodePacked(baseUri, _id.toString()));
    else
      return '';
  }

  function setCollectionName(string memory _name) external onlyOwner{
    name = _name;
  }

  /**
    * @dev Returns the total quantity for a token ID
    * @param _id uint256 ID of the token to query
    * @return amount of token in existence
    */
  function totalSupply(
    uint256 _id
  ) public view returns (uint256) {
    return tokenSupply[_id];
  }

  /**
   * @dev Will update the base URL of token's URI
   * @param _newBaseMetadataURI New base URL of token's URI
   */
  function setBaseMetadataURI(
    string memory _newBaseMetadataURI
  ) public onlyOwner {
    baseUri = _newBaseMetadataURI;
    _setURI(_newBaseMetadataURI);
  }

  /**
    * @dev Creates a new token type and assigns _initialSupply to an address
    * NOTE: remove onlyOwner if you want third parties to create new tokens on your contract (which may change your IDs)
    * @param _initialHolder address of the first owner of the token
    * @param _initialSupply amount to supply the first owner
    * @param _secreteUri Secret URI for this token type, only holder allowed to see this URI
    * @return The newly created token ID
    */
  function mintERC1155Token(
    address _initialHolder,
    uint256 _initialSupply,
    string memory _secreteUri
  ) external  returns (uint256) {

    _incrementTokenTypeId();
    uint256 _id = _currentTokenID;
    
    _mint(_initialHolder, _id, _initialSupply, "");
    tokenSupply[_id] = _initialSupply;
    
    if(bytes(_secreteUri).length > 0){
        setTokenOnlyHolderURI(_id, _secreteUri);
    }
    return _id;
  }


  /**
    * @dev Returns whether the specified token exists by checking to see if it has a creator
    * @param _id uint256 ID of the token to query the existence of
    * @return bool whether the token exists
    */
  function _exists(
    uint256 _id
  ) internal view returns (bool) {
    return tokenSupply[_id] > 0;
  }

  /**
    * @dev increments the value of _currentTokenID
    */
  function _incrementTokenTypeId() private  {
    _currentTokenID++;
  }

  /**
    * @dev Sets `_tokenSecretURI` as the tokenSecretURI of `_id`.
    *
    * Requirements:
    *
    * - `_id` must exist.
    */
  function setTokenOnlyHolderURI(uint256 _id, string memory _tokenSecretURI) public onlyHolders(_id) virtual {
      require(_exists(_id), "DaoLaunchERC1155: URI set of nonexistent token");
      
      _onlyHolderSecretURI[_id] = _tokenSecretURI;
  }


  /**
    * @dev all holders are allowed to see this URI, otherwise not allowed
    * @param _id uint256 ID of the token to query the existence of
    * @return secret uri of the token type 
    */
  function getHolderSecretURI(uint256 _id) public onlyHolders(_id) view returns(string memory){
    require(_exists(_id), "DaoLaunchERC1155: URI query for nonexistent token");
    
    string memory _tokenOnlyholderURI = _onlyHolderSecretURI[_id];

    
    // If there is no base URI, return the token URI.
    if (bytes(baseUri).length == 0) {
        return _tokenOnlyholderURI;
    }
    // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
    if (bytes(_tokenOnlyholderURI).length > 0) {
        return string(abi.encodePacked(baseUri, _tokenOnlyholderURI));
    }

    return '';
  }

  /**
  * @dev Destroys `amount` tokens of token type `id` from `account`
  *
  * Requirements:
  *
  * - `account` cannot be the zero address. Check in _burn(...)
  * - `account` must have at least `amount` tokens of token type `id`. Check in _burn(...)
  * - the message sender must be the account or be ApprovedForAll
  */
  function burn(address account, uint256 _id, uint256 _amount) external {
	    require((msg.sender == account) || isApprovedForAll(account, msg.sender), "DaoLaunchERC1155#burn: INVALID_OPERATOR");
	    _burn(account, _id, _amount);
  }


}
