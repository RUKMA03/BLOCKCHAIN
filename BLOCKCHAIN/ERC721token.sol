//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

//IERC165 is a meta-interface ; checks whether contract supports use of interfaces
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns(bool);
}

//IERC721 inherits IERC165
interface IERC721 is IERC165{

    
    function balanceOf(address owner) external view returns(uint balance);
    
    
    function ownerOf(uint tokenId) external view returns(address owner);

    
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external;
    
     
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;
    
    
    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external;
    
    
    function approve(address to, uint tokenId) external;
    
    
    function setApprovalForAll(address operator, bool approved) external;
    
    
    function getApproved(uint tokenId) external view returns(address operator);
    
    
    function isApprovedForAll(address owner, address operator) external view returns (bool);

}

//interface can hold ERC721 tokens
interface IERC721Receiver{
    function onERC721Received(
        address operator,
        address from,
        uint tokenID,
        bytes calldata data
    ) external returns(bytes4);

}

//contract implements IERC721
contract ERC721 is IERC721 {
    
    //event triggered when tokens are transferred from one address to another
    event Transfer(address indexed from, address indexed to, uint indexed id);

    //gives administrators the final say in approving or rejecting a pending demand
    event Approval(address indexed owner, address indexed spender, uint indexed id);

    //event triggered when owner changes approval status given to the operator for their NFTs 
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    
    //to store owner of each NFT
    mapping(uint => address) internal _ownerOf;

    //to keep track of number of NFTs each address owns
    mapping(address => uint) internal _balanceOf;

    //to check whether owner has given approval to any other address to manage NFTs
    mapping(uint=> address) internal _approvals;

    //to give approval to address that holds NFT collection
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    
    //checks returned boolean value to see if contract supports specific interface
    function supportsInterface(bytes4 interfaceId) external view returns(bool){
        return interfaceId ==type(IERC721).interfaceId || interfaceId ==type(IERC165).interfaceId;

    }
    
    //function balanceOf() takes address as parameter and returns the number of tokens owned by the address
    function balanceOf(address owner) external view returns(uint balance) {
        require(owner!=address(0), "owner = zero address");
        return _balanceOf[owner];
    }
    
    //function ownerOf() takes NFT ID as parameter and returns address of owner of NFT
    function ownerOf(uint tokenId) external view returns(address owner){
        owner= _ownerOf[tokenId];
        require(owner!=address(0), "owner = zero address");
    
    }
    
    //function setApprovalForAll() takes address and bool as parameter and approves of management for all NFTs at the address
    function setApprovalForAll(address operator, bool _approved) external{
        isApprovedForAll[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator,_approved) ;

    }
    
    //function approve() takes address and ID of token which you own and approves of managing it
    function approve(address to, uint tokenId) external{
        address owner = _ownerOf[tokenId];
        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "not authorized"
        );
        _approvals[tokenId] = to;
        emit Approval(owner,to,tokenId);

    }
    
    //function getApproved() takes token ID as parameter and returns the account approved for token ID token
    function getApproved(uint tokenId) external view returns(address operator){
        require(_ownerOf[tokenId] != address(0), "token does not exist");
        return _approvals[tokenId];
    }
    
    //function _isApprovedOrOwner() checks whether spender has permission to spend token
    function _isApproverOrOwner(
        address owner,
        address spender,
        uint tokenId
    ) internal view returns(bool) {
        return(
            spender == owner ||
            isApprovedForAll[owner][spender] ||
            spender == _approvals[tokenId]
        );
    }
    
    //function transferFrom() transfers tokens while not performing check for receiving address
    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) public{
        require(from == _ownerOf[tokenId], "from !=owner");
        require(to != address(0), "to = zero address");
        require(_isApproverOrOwner(from, msg.sender,tokenId), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[tokenId] =to;

        delete _approvals[tokenId];

        emit Transfer(from,to,tokenId);
    }
    
    //function safeTransferFrom() transfers NFT from one address to another, given token ID
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external{
        transferFrom(from,to,tokenId);
        
        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(msg.sender,from,tokenId,"") ==
                IERC721Receiver.onERC721Received.selector,
                "unsafe recepient"
        );
    }
    
    //function safeTransferFrom() transfers NFT from one address to another, given token ID , along with ETH 
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external{
        transferFrom(from,to,tokenId);
        
        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(msg.sender,from,tokenId,data) ==
                IERC721Receiver.onERC721Received.selector,
                "unsafe recepient"
        );

    }
    

    //function _mint() is used to mint token after ensuring token ID is unique
    function _mint(address to, uint tokenId) internal{
        require(to !=address(0), "to = zero address");
        require(_ownerOf[tokenId] == address(0), "token exists");

        _balanceOf[to]++;
        _ownerOf[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
    

    //function _burn() is used to completely erase token, given token ID
    function _burn(uint tokenId) internal{
        address owner = _ownerOf[tokenId];
        require(owner!= address(0), "token does not exist");

        _balanceOf[owner]--;
        delete _ownerOf[tokenId];
        delete _approvals[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

}

//new token
contract MyFish is ERC721{
    function mint(address to, uint tokenId) external{
        _mint(to, tokenId);
    }

    function burn(uint tokenId) external{
        require(msg.sender == _ownerOf[tokenId], "not owner");
        _burn(tokenId);
    }
}