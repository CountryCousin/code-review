// SPDX-License-Identifier: MIT … licensing which is MIT
pragma solidity 0.8.1; // compiler version of the contract.

// destructed imports from LibAppStorage.sol
import {AppStorage, SvgLayer, Dimensions} from "../libraries/LibAppStorage.sol";

// imports from  LibAavegochi.sol
import {LibAavegotchi, PortalAavegotchiTraitsIO, EQUIPPED_WEARABLE_SLOTS, PORTAL_AAVEGOTCHIS_NUM, NUMERIC_TRAITS_NUM} from "../libraries/LibAavegotchi.sol";

// imports from LibItems.sol
import {LibItems} from "../libraries/LibItems.sol";

// more destructed imports from  LibAppStorage.sol
import {Modifiers, ItemType} from "../libraries/LibAppStorage.sol";

// imports from LibSvg.sol
import {LibSvg} from "../libraries/LibSvg.sol";

// import from  LibStrings.sol
import {LibStrings} from "../../shared/libraries/LibStrings.sol";

contract SvgFacet is Modifiers { // here we have a contract “ SvgFacet” which is inherited from the contract “Modifiers”

// Below are functions that doesn’t make change to the blockchain ie “Read functions”
    /***********************************|
   |             Read Functions         |
   |__________________________________*/

    ///@notice Given an aavegotchi token id, return the combined SVG of its layers and its wearables
    ///@param _tokenId the identifier of the token to query
    ///@return ag_ The final svg which contains the combined SVG of its layers and its wearables

    function getAavegotchiSvg(uint256 _tokenId) public view returns (string memory ag_) { // function that takes a uint256 and returns string ag_
        require(s.aavegotchis[_tokenId].owner != address(0), "SvgFacet: _tokenId does not exist"); // a check to enusure incoming address is not zero address

 bytes memory svg; // local variable of type bytes named svg
        uint8 status = s.aavegotchis[_tokenId].status; // variable of type uint8 assignment
        uint256 hauntId = s.aavegotchis[_tokenId].hauntId; // variable of type uint256 assignment
        //conditional checks and outputs
        if (status == LibAavegotchi.STATUS_CLOSED_PORTAL) { 
            // sealed closed portal
            svg = LibSvg.getSvg("portal-closed", hauntId);
        } else if (status == LibAavegotchi.STATUS_OPEN_PORTAL) {
            // open portal
            svg = LibSvg.getSvg("portal-open", hauntId);
        } else if (status == LibAavegotchi.STATUS_AAVEGOTCHI) {
            address collateralType = s.aavegotchis[_tokenId].collateralType;
            svg = getAavegotchiSvgLayers(collateralType, s.aavegotchis[_tokenId].numericTraits, _tokenId, hauntId);
        }
        ag_ = string(abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">', svg, "</svg>"));
    }
