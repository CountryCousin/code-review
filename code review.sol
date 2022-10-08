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
        
        // Using abi.encodePacked to typecast Svg tags and finally stringfying the output. 
        ag_ = string(abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">', svg, "</svg>"));
    }
    
    
    
    //Below is a struct name SvgLayerDetails
    struct SvgLayerDetails {
        string primaryColor; // variable of type string declaration
        string secondaryColor; // variable of type string declaration
        string cheekColor; // variable of type string declaration
        bytes collateral; // variable of type bytes declaration
        int256 trait; // variable of type string declaration
        int256[18] eyeShapeTraitRange; // variable of type of array int256 declaration with a fixed size of 18 element
        bytes eyeShape; // variable of type bytes declaration
        string eyeColor; // variable of type string declaration
        int256[8] eyeColorTraitRanges;// variable of type of array int256 declaration with a fixed size of 8 element
        string[7] eyeColors;// variable of type array of string declaration with a fixed size of 7 element
    }
    
    
    // function that takes takes address, and array of int16 , uint256, and returns bytes
    function getAavegotchiSvgLayers(
        address _collateralType,
        int16[NUMERIC_TRAITS_NUM] memory _numericTraits,
        uint256 _tokenId,
        uint256 _hauntId
    ) internal view returns (bytes memory svg_) {
        SvgLayerDetails memory details; // variable declaration
        details.primaryColor = LibSvg.bytes3ToColorString(s.collateralTypeInfo[_collateralType].primaryColor); // variable assignment
        details.secondaryColor = LibSvg.bytes3ToColorString(s.collateralTypeInfo[_collateralType].secondaryColor);// variable assignment
        details.cheekColor = LibSvg.bytes3ToColorString(s.collateralTypeInfo[_collateralType].cheekColor); // variable assignment

        // aavegotchi body
        svg_ = LibSvg.getSvg("aavegotchi", LibSvg.AAVEGOTCHI_BODY_SVG_ID); // variable assignment
        details.collateral = LibSvg.getSvg("collaterals", s.collateralTypeInfo[_collateralType].svgId); // variable assignment

        bytes32 eyeSvgType = "eyeShapes"; // variable declaration
        if (_hauntId != 1) { // conditional decalaration
            //Convert Haunt into string to match the uploaded category name
            bytes memory haunt = abi.encodePacked(LibSvg.uint2str(_hauntId));
            // passing the "haunt" bytes into abi.encodepacked method
            eyeSvgType = LibSvg.bytesToBytes32(abi.encodePacked("eyeShapesH"), haunt);
        }

        details.trait = _numericTraits[4]; // variable assignment

        if (details.trait < 0) { // conditional decalaration
            details.eyeShape = LibSvg.getSvg(eyeSvgType, 0); // variable assignment
        } else if (details.trait > 97) { // conditional decalaration
            details.eyeShape = LibSvg.getSvg(eyeSvgType, s.collateralTypeInfo[_collateralType].eyeShapeSvgId); // variable assignment
        } else { // conditional decalaration
            details.eyeShapeTraitRange = [int256(0), 1, 2, 5, 7, 10, 15, 20, 25, 42, 58, 75, 80, 85, 90, 93, 95, 98]; // array population
            for (uint256 i; i < details.eyeShapeTraitRange.length - 1; i++) {// looping the and array
                if (details.trait >= details.eyeShapeTraitRange[i] && details.trait < details.eyeShapeTraitRange[i + 1]) { // conditional decalaration
                    details.eyeShape = LibSvg.getSvg(eyeSvgType, i); // variable assignment
                    break;
                }
            }
        }

        details.trait = _numericTraits[5]; // variable of type array declaration
        details.eyeColorTraitRanges = [int256(0), 2, 10, 25, 75, 90, 98, 100]; // an array assignement
        details.eyeColors = [
            "FF00FF", // mythical_low
            "0064FF", // rare_low
            "5D24BF", // uncommon_low
            details.primaryColor, // common
            "36818E", // uncommon_high
            "EA8C27", // rare_high
            "51FFA8" // mythical_high
        ];
        if (details.trait < 0) { // conditional declaration
            details.eyeColor = "FF00FF"; // variable assignment
        } else if (details.trait > 99) {// conditional declaration
            details.eyeColor = "51FFA8";// variable assignment
        } else { // conditional declaration
            for (uint256 i; i < details.eyeColorTraitRanges.length - 1; i++) { // looping through an array
                if (details.trait >= details.eyeColorTraitRanges[i] && details.trait < details.eyeColorTraitRanges[i + 1]) { // conditional dcalration
                    details.eyeColor = details.eyeColors[i]; // variable assignment
                    break;
                }
            }
        }

        //Load in all the equipped wearables
        uint16[EQUIPPED_WEARABLE_SLOTS] memory equippedWearables = s.aavegotchis[_tokenId].equippedWearables; // memory binding

        //Token ID is uint256 max: used for Portal Aavegotchis to close hands
        if (_tokenId == type(uint256).max) { // conditional declaration
        //concatenation using abi.encodePacked
            svg_ = abi.encodePacked(
                applyStyles(details, _tokenId, equippedWearables),
                LibSvg.getSvg("aavegotchi", LibSvg.BACKGROUND_SVG_ID),
                svg_,
                details.collateral,
                details.eyeShape
            );
        }
        //Token ID is uint256 max - 1: used for Gotchi previews to open hands
        else if (_tokenId == type(uint256).max - 1) { // conditional declaration
            equippedWearables[0] = 1; // variable assignment
            svg_ = abi.encodePacked(applyStyles(details, _tokenId, equippedWearables), svg_, details.collateral, details.eyeShape); //concatenation using abi.encodePacked

            //Normal token ID
        } else { // conditional declaration
            svg_ = abi.encodePacked(applyStyles(details, _tokenId, equippedWearables), svg_, details.collateral, details.eyeShape); //concatenation using abi.encodePacked
            svg_ = addBodyAndWearableSvgLayers(svg_, equippedWearables); // variable assignment
        }
    }
    
    //Apply styles based on the traits and wearables
    // function that takes parameter SvgLayerDetails, uint256, uint16 and returns bytes
    function applyStyles(
        SvgLayerDetails memory _details,
        uint256 _tokenId,
        uint16[EQUIPPED_WEARABLE_SLOTS] memory equippedWearables
    ) internal pure returns (bytes memory) {
        if ( // conditional declaration
            _tokenId != type(uint256).max &&
            (equippedWearables[LibItems.WEARABLE_SLOT_BODY] != 0 ||
                equippedWearables[LibItems.WEARABLE_SLOT_HAND_LEFT] != 0 ||
                equippedWearables[LibItems.WEARABLE_SLOT_HAND_RIGHT] != 0)
        ) {
            //Open-hands aavegotchi
            return // retunrns a concatination bounded by abi.encodePacked
                abi.encodePacked(
                    "<style>.gotchi-primary{fill:#",
                    _details.primaryColor,
                    ";}.gotchi-secondary{fill:#",
                    _details.secondaryColor,
                    ";}.gotchi-cheek{fill:#",
                    _details.cheekColor,
                    ";}.gotchi-eyeColor{fill:#",
                    _details.eyeColor,
                    ";}.gotchi-primary-mouth{fill:#",
                    _details.primaryColor,
                    ";}.gotchi-sleeves-up{display:none;}",
                    ".gotchi-handsUp{display:none;}",
                    ".gotchi-handsDownOpen{display:block;}",
                    ".gotchi-handsDownClosed{display:none;}",
                    "</style>"
                );
        } else { // conditional decalaration
            //Normal Aavegotchi, closed hands
            return // retunrns a concatination bounded by abi.encodePacked
                abi.encodePacked(
                    "<style>.gotchi-primary{fill:#",
                    _details.primaryColor,
                    ";}.gotchi-secondary{fill:#",
                    _details.secondaryColor,
                    ";}.gotchi-cheek{fill:#",
                    _details.cheekColor,
                    ";}.gotchi-eyeColor{fill:#",
                    _details.eyeColor,
                    ";}.gotchi-primary-mouth{fill:#",
                    _details.primaryColor,
                    ";}.gotchi-sleeves-up{display:none;}",
                    ".gotchi-handsUp{display:none;}",
                    ".gotchi-handsDownOpen{display:none;}",
                    ".gotchi-handsDownClosed{display:block}",
                    "</style>"
                );
        }
    }
    
    function getWearableClass(uint256 _slotPosition) internal pure returns (string memory className_) { // function that takes uint256 as parameter and returns string
        //Wearables

        if (_slotPosition == LibItems.WEARABLE_SLOT_BODY) className_ = "wearable-body"; // conditional assignment
        if (_slotPosition == LibItems.WEARABLE_SLOT_FACE) className_ = "wearable-face"; // conditional assignment
        if (_slotPosition == LibItems.WEARABLE_SLOT_EYES) className_ = "wearable-eyes"; // conditional assignment
        if (_slotPosition == LibItems.WEARABLE_SLOT_HEAD) className_ = "wearable-head"; // conditional assignment
        if (_slotPosition == LibItems.WEARABLE_SLOT_HAND_LEFT) className_ = "wearable-hand wearable-hand-left"; // conditional assignment
        if (_slotPosition == LibItems.WEARABLE_SLOT_HAND_RIGHT) className_ = "wearable-hand wearable-hand-right"; // conditional assignment
        if (_slotPosition == LibItems.WEARABLE_SLOT_PET) className_ = "wearable-pet";  // conditional assignment
        if (_slotPosition == LibItems.WEARABLE_SLOT_BG) className_ = "wearable-bg";  // conditional assignment
    }

    function getBodyWearable(uint256 _wearableId) internal view returns (bytes memory bodyWearable_, bytes memory sleeves_) { // function that takes uint256 as parameter and returns bytes
        ItemType storage wearableType = s.itemTypes[_wearableId]; // storage binding
        Dimensions memory dimensions = wearableType.dimensions;// memery binding
        
        
        //
        bodyWearable_ = abi.encodePacked( // retunrns a concatination bounded by abi.encodePacked
            '<g class="gotchi-wearable wearable-body',
            // x
            LibStrings.strWithUint('"><svg x="', dimensions.x),
            // y
            LibStrings.strWithUint('" y="', dimensions.y),
            '">',
            LibSvg.getSvg("wearables", wearableType.svgId),
            "</svg></g>"
        );
        uint256 svgId = s.sleeves[_wearableId];// variable assignment
        if (svgId != 0) { // conditional check
            sleeves_ = abi.encodePacked( // retunrns a concatination bounded by abi.encodePacked
                // x
                LibStrings.strWithUint('"><svg x="', dimensions.x),
                // y
                LibStrings.strWithUint('" y="', dimensions.y),
                '">',
                LibSvg.getSvg("sleeves", svgId),
                "</svg>"
            );
        }
    }

    function getWearable(uint256 _wearableId, uint256 _slotPosition) internal view returns (bytes memory svg_) { // function that takes uint256 as parameter and returns bytes
        ItemType storage wearableType = s.itemTypes[_wearableId]; // storage binding
        Dimensions memory dimensions = wearableType.dimensions;// memory binding

        string memory wearableClass = getWearableClass(_slotPosition); // memory binding

        svg_ = abi.encodePacked( // retunrns a concatination bounded by abi.encodePacked
            '<g class="gotchi-wearable ',
            wearableClass,
            // x
            LibStrings.strWithUint('"><svg x="', dimensions.x),
            // y
            LibStrings.strWithUint('" y="', dimensions.y),
            '">'
        );
        if (_slotPosition == LibItems.WEARABLE_SLOT_HAND_RIGHT) { // conditional check
            svg_ = abi.encodePacked( // retunrns a concatination bounded by abi.encodePacked
                svg_,
                LibStrings.strWithUint('<g transform="scale(-1, 1) translate(-', 64 - (dimensions.x * 2)),
                ', 0)">',
                LibSvg.getSvg("wearables", wearableType.svgId),
                "</g></svg></g>"
            );
        } else { // conditional check
            svg_ = abi.encodePacked(svg_, LibSvg.getSvg("wearables", wearableType.svgId), "</svg></g>"); //  a concatination bounded by abi.encodePacked
        }
    }
    
    //struct with a layout of 10 vairables ot type bytes
    struct AavegotchiLayers {
        bytes background;
        bytes bodyWearable;
        bytes hands;
        bytes face;
        bytes eyes;
        bytes head;
        bytes sleeves;
        bytes handLeft;
        bytes handRight;
        bytes pet;
    }

 ///@notice Allow the preview of an aavegotchi given the haunt id,a set of traits,wearables and collateral type
    ///@param _hauntId Haunt id to use in preview /
    ///@param _collateralType The type of collateral to use
    ///@param _numericTraits The numeric traits to use for the aavegotchi
    ///@param equippedWearables The set of wearables to wear for the aavegotchi
    ///@return ag_ The final svg string being generated based on the given test parameters

    function previewAavegotchi( // a function that takes uint256, address, an array of int16, an array of uint16 as parameters and returns string.
        uint256 _hauntId,
        address _collateralType,
        int16[NUMERIC_TRAITS_NUM] memory _numericTraits,
        uint16[EQUIPPED_WEARABLE_SLOTS] memory equippedWearables
    ) external view returns (string memory ag_) {
        //Get base body layers
        bytes memory svg_ = getAavegotchiSvgLayers(_collateralType, _numericTraits, type(uint256).max - 1, _hauntId); //mempry binding

        //Add on body wearables
        svg_ = abi.encodePacked(addBodyAndWearableSvgLayers(svg_, equippedWearables)); // concatenation implemented with abi.encode

        //Encode
        ag_ = string(abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">', svg_, "</svg>"));// the final(result) ie string which the function returns
    } 
    
    //function that takes bytes, an array of uint16 as paramters and returns bytes
     function addBodyAndWearableSvgLayers(bytes memory _body, uint16[EQUIPPED_WEARABLE_SLOTS] memory equippedWearables) 
        internal
        view
        returns (bytes memory svg_)
    {
        AavegotchiLayers memory layers; // variable declaration

        // If background is equipped
        uint256 wearableId = equippedWearables[LibItems.WEARABLE_SLOT_BG]; // varible assignment
        if (wearableId != 0) { // conditional check
            layers.background = getWearable(wearableId, LibItems.WEARABLE_SLOT_BG); // varible assignment
        } else {
            layers.background = LibSvg.getSvg("aavegotchi", 4);// varible assignment
        }

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_BODY];// varible assignment
        if (wearableId != 0) { //conditional check
            (layers.bodyWearable, layers.sleeves) = getBodyWearable(wearableId); // varible assignment
        }

        // get hands
        layers.hands = abi.encodePacked(svg_, LibSvg.getSvg("aavegotchi", LibSvg.HANDS_SVG_ID)); // varible assignment gotten by concatination

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_FACE]; // varible assignment
        if (wearableId != 0) { //conditional check
            layers.face = getWearable(wearableId, LibItems.WEARABLE_SLOT_FACE); // varible assignment
        }

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_EYES];// varible assignment
        if (wearableId != 0) {//conditional check
            layers.eyes = getWearable(wearableId, LibItems.WEARABLE_SLOT_EYES);// varible assignment
        }

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_HEAD];// varible assignment
        if (wearableId != 0) {//conditional check
            layers.head = getWearable(wearableId, LibItems.WEARABLE_SLOT_HEAD);// varible assignment
        }

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_HAND_LEFT];// varible assignment
        if (wearableId != 0) {//conditional check
            layers.handLeft = getWearable(wearableId, LibItems.WEARABLE_SLOT_HAND_LEFT);// varible assignment
        }

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_HAND_RIGHT];// varible assignment
        if (wearableId != 0) {//conditional check
            layers.handRight = getWearable(wearableId, LibItems.WEARABLE_SLOT_HAND_RIGHT);// varible assignment
        }

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_PET];// varible assignment
        if (wearableId != 0) {//conditional check
            layers.pet = getWearable(wearableId, LibItems.WEARABLE_SLOT_PET);// varible assignment
        }

        //1. Background wearable
        //2. Body
        //3. Body wearable
        //4. Hands
        //5. Face
        //6. Eyes
        //7. Head
        //8. Sleeves of body wearable
        //9. Left hand wearable
        //10. Right hand wearable
        //11. Pet wearable

        svg_ = applyFrontLayerExceptions(equippedWearables, layers, _body); // the bytes that gets returned
    }
    // function that takes an array of uint16, structs, bytes and returns bytes
    function applyFrontLayerExceptions(
        uint16[EQUIPPED_WEARABLE_SLOTS] memory equippedWearables,
        AavegotchiLayers memory layers,
        bytes memory _body
    ) internal view returns (bytes memory svg_) {
        bytes32 front = LibSvg.bytesToBytes32("wearables-", "front");// variable of byte32 assignement

        svg_ = abi.encodePacked(layers.background, _body, layers.bodyWearable, layers.hands); //variable gotten by concatenation
        //eyes and head exceptions
        if (// conditional check
            s.wearableExceptions[front][equippedWearables[2]][2] &&
            s.wearableExceptions[front][equippedWearables[3]][3] &&
            equippedWearables[2] != 301 /*alluring eyes*/
        ) {
            svg_ = abi.encodePacked(svg_, layers.face, layers.head, layers.eyes);// concatination done with abi.encode
            //face or eye and head exceptions
        } else if ( // conditional check
            (s.wearableExceptions[front][equippedWearables[1]][1] || equippedWearables[2] == 301) &&
            s.wearableExceptions[front][equippedWearables[3]][3]
        ) {
            svg_ = abi.encodePacked(svg_, layers.eyes, layers.head, layers.face); // concatination 
        } else if ((s.wearableExceptions[front][equippedWearables[1]][1] || equippedWearables[2] == 301) && equippedWearables[2] == 301) { // conditional check
            svg_ = abi.encodePacked(svg_, layers.eyes, layers.face, layers.head);// concatination done with abi.encode
        } else {
            svg_ = abi.encodePacked(svg_, layers.face, layers.eyes, layers.head);// concatination done with abi.encode
        }
        svg_ = abi.encodePacked(svg_, layers.sleeves, layers.handLeft, layers.handRight, layers.pet);// concatination done with abi.encode
    }
