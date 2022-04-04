// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "../common/Ownable.sol";

contract DaoLaunchERC721 is ERC721Enumerable, Ownable {
	string _baseTokenURI;
    uint256 public currentTokenId ;
	mapping(uint256 => string) private _onlyHolderSecretURI;


    constructor() ERC721("DAOLaunch", "DAL")  {
        setBaseURI("https://tokenibo.dev.api-java.bappartners.com/token/721/");
    }
    /**
     * @dev mint new tokenID to address "_to", if there is a secret token URI 
     * then setting for the "_tokenSecretURI"
     *
     * "currentTokenId" is autoincreament
     * 
     */

    function mint721Token(address _to, string memory _tokenSecretURI) public {
        currentTokenId = currentTokenId + 1;
        _safeMint(_to, currentTokenId);

        if(bytes(_tokenSecretURI).length > 0){
            setTokenOnlyHolderURI(currentTokenId, _tokenSecretURI);
        }

    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
    /**
     * contractURI method for OpenSea Metadata Standard
     */
    function contractURI() public view returns (string memory) {
        return _baseTokenURI;
    }
    
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }
    
    modifier onlyHolder(uint256 tokenId) {
        require(_msgSender() == ownerOf(tokenId), "Only the TokenId holder can see this URI");
        _;
    }

    function getHolderSecretURI(uint256 tokenId) public onlyHolder(tokenId) view returns(string memory){
        require(_exists(tokenId), "URI query for nonexistent token");
        
        string memory _tokenOnlyholderURI = _onlyHolderSecretURI[tokenId];
        string memory base = _baseURI();   
        
        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenOnlyholderURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenOnlyholderURI).length > 0) {
            return string(abi.encodePacked(base, _tokenOnlyholderURI));
        }

        return '';
    }

    /**
     * @dev Sets `_tokenSecretURI` as the tokenSecretURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function setTokenOnlyHolderURI(uint256 tokenId, string memory _tokenSecretURI) public onlyHolder(tokenId) virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
       
        _onlyHolderSecretURI[tokenId] = _tokenSecretURI;
    }

    /**
     * @dev show all TokenId  of  the `holder`.
     *
     * 
     */
    
    function tokensOfOwner(address _owner) external view returns(uint256[] memory) {
        uint tokenCount = balanceOf(_owner);
    
        uint256[] memory tokensId = new uint256[](tokenCount);
        for(uint i = 0; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
    
        return tokensId;
    }

    function burn(uint256 tokenId) external {
        require(_msgSender() == ownerOf(tokenId), "Only the TokenId holder can burn this tokenId");
        _burn(tokenId);
    }
    
    

}