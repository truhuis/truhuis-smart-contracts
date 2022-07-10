// SPDX-Licence-Identifier: MIT

pragma solidity 0.8.13;

import "../Conftest.sol";
import "@interfaces/ITruhuisAddressRegistry.sol";

/**
 * @title TruhuisAddressRegistryTest
 * @author vsevdrob
 * @dev List of implemented functions to test (PASS | FAIL | TODO):
 *      [PASS] constructor()
 *      [PASS] getAddress(bytes32)
 *      [PASS] getMunicipality(bytes4)
 *      [PASS] isRegisteredMunicipality(address,bytes4)
 *      [PASS] registerMunicipality(address,bytes4)
 *      [PASS] updateAddress(address,bytes32)
 *      [PASS] updateMunicipality(address,bytes4)
 */
contract TruhuisAddressRegistryTest is Conftest {
    TruhuisAddressRegistry public addressRegistryNew;
    Municipality public municipalityANew;

    function setUp() public {
        _deploy();

        vm.startPrank(truhuis);

        addressRegistryNew = new TruhuisAddressRegistry();
        municipalityANew = new Municipality(AMSTERDAM);

        vm.stopPrank();
    }

    function testConstructor() public {
        /* ACT */

        // Get contract address of the address registry.
        address addressRegistryAddr = addressRegistry.getAddress(
            ADDRESS_REGISTRY
        );

        // Get contract owner address.
        address contractOwnerAddr = addressRegistry.owner();

        /* PERFORM ASSERTIONS */

        // Actual contract address must be equal to the expected.
        assertEq(address(addressRegistry), addressRegistryAddr);
        // Actual contract owner must be equal to the expected.
        assertEq(truhuis, contractOwnerAddr);
    }

    function testGetAddress() public {
        /* ARRANGE */

        vm.startPrank(truhuis);

        // Update Truhuis Trade contract address.
        addressRegistry.updateAddress(address(trade), TRADE);

        vm.stopPrank();

        /* ACT */

        // Get contract address of the appraiser.
        address appraiserAddr = addressRegistry.getAddress(APPRAISER);
        // Get contract address of the trade.
        address tradeAddr = addressRegistry.getAddress(TRADE);

        /* PERFORM ASSERTIONS */

        // Actual contract address must be equal to the zero address.
        assertEq(address(0), appraiserAddr);
        // Actual contract address must be equal to the expected.
        assertEq(address(trade), tradeAddr);
    }

    function testGetMunicipality() public {
        /* ARRANGE */

        vm.startPrank(truhuis);

        // Register municipality of Amsterdam.
        addressRegistry.registerMunicipality(address(municipalityA), AMSTERDAM);

        vm.stopPrank();

        /* ACT */

        // Get municipality of Amsterdam.
        MunicipalityStruct memory mA = addressRegistry.getMunicipality(
            AMSTERDAM
        );

        /* PERFORM ASSERTIONS */

        // Actual contract address must be equal to the expected.
        assertEq(address(municipalityA), mA.contractAddr);
        // Municipality of Amsterdam identifier must be equal to the expected.
        assertEq(mA.cbsCode, AMSTERDAM);
        // Municipality of Amsterdam must be registered.
        assertEq(mA.isRegistered, true);
    }

    function testIsRegisteredMunicipality() public {
        /* ARRANGE */

        vm.startPrank(truhuis);

        // Register municipality of Amsterdam.
        addressRegistry.registerMunicipality(address(municipalityA), AMSTERDAM);

        vm.stopPrank();

        /* ACT */

        // Get whether the municipality registered or not.
        bool isRegisteredA = addressRegistry.isRegisteredMunicipality(
            address(municipalityA),
            AMSTERDAM
        );

        // Get whether the municipality registered or not.
        bool isRegisteredR = addressRegistry.isRegisteredMunicipality(
            address(municipalityR),
            ROTTERDAM
        );

        /* PERFORM ASSERTIONS */

        // Municipality of Amsterdam must be registered.
        assertEq(isRegisteredA, true);
        // Municipality of Rotterdam must be not registered.
        assertEq(isRegisteredR, false);
    }

    function testRegisterMunicipality() public {
        /* ARRANGE */

        vm.startPrank(truhuis);

        // Register municipality of Amsterdam.
        addressRegistry.registerMunicipality(address(municipalityA), AMSTERDAM);

        vm.stopPrank();

        /* ACT */

        // Get municipality of Amsterdam.
        MunicipalityStruct memory mA = addressRegistry.getMunicipality(
            AMSTERDAM
        );

        /* PERFORM ASSERTIONS */

        // Expected municipality contract address must be equal to the actual.
        assertEq(address(municipalityA), mA.contractAddr);
        // Municipality of Amsterdam identifier must be equal to the expected.
        assertEq(mA.cbsCode, AMSTERDAM);
        // Municipality of Amsterdam must be registered.
        assertEq(mA.isRegistered, true);

        /* REVERT ERRORS */

        vm.startPrank(truhuis);

        // Must fail because of default value of an address.
        vm.expectRevert(MUNICIPALITY_REGISTRATION_FAILED.selector);
        addressRegistry.registerMunicipality(address(0), AMSTERDAM);

        // Must fail because municipality is already registered.
        vm.expectRevert(MUNICIPALITY_REGISTRATION_FAILED.selector);
        addressRegistry.registerMunicipality(address(municipalityA), AMSTERDAM);

        // Must fail because of default value of a bytes4.
        vm.expectRevert(MUNICIPALITY_REGISTRATION_FAILED.selector);
        addressRegistry.registerMunicipality(
            address(municipalityR),
            0x00000000
        );

        vm.stopPrank();

        // Must fail because caller is not contract owner.
        vm.startPrank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        addressRegistry.registerMunicipality(address(municipalityH), THE_HAGUE);
        vm.stopPrank();
    }

    function testUpdateAddress() public {
        /* ARRANGE */

        vm.startPrank(truhuis);

        // Store updated appraiser contract address.
        addressRegistry.updateAddress(address(appraiser), APPRAISER);
        // Store updated inspector contract address.
        addressRegistry.updateAddress(address(inspector), INSPECTOR);

        vm.stopPrank();

        /* ACT */

        // Get appraiser contract address.
        address appraiserAddr = addressRegistry.getAddress(APPRAISER);
        // Get inspector contract address.
        address inspectorAddr = addressRegistry.getAddress(INSPECTOR);

        /* PERFORM ASSERTIONS */

        // Actual appraiser address must be equal to the expected.
        assertEq(address(appraiser), appraiserAddr);
        // Actual appraiser address must be equal to the expected.
        assertEq(address(inspector), inspectorAddr);

        /* REVERT ERRORS */

        vm.startPrank(truhuis);

        // Must fail because updating the address registry contract address
        // is not allowed.
        vm.expectRevert(UPDATE_ADDRESS_REGISTRY_NOT_ALLOWED.selector);
        addressRegistry.updateAddress(
            address(addressRegistryNew),
            ADDRESS_REGISTRY
        );

        // Must fail because updating a new contract address on top of an
        // identical old contract address is not allowed.
        vm.expectRevert(IDENTICAL_ADDRESS_PROVIDED.selector);
        addressRegistry.updateAddress(address(appraiser), APPRAISER);

        // Must fail because providing the zero address is not permitted.
        vm.expectRevert(ZERO_ADDRESS_PROVIDED.selector);
        addressRegistry.updateAddress(address(0), APPRAISER);

        vm.stopPrank();

        // Must fail because caller is not contract owner.
        vm.startPrank(bob);
        vm.expectRevert("Ownable: caller is not the owner");
        addressRegistry.updateAddress(address(inspector), INSPECTOR);
        vm.stopPrank();
    }

    function testUpdateMunicipality() public {
        /* ARRANGE */

        vm.startPrank(truhuis);

        // Register municipality of Amsterdam.
        addressRegistry.registerMunicipality(address(municipalityA), AMSTERDAM);

        // Store updated municipality of Amsterdam contract address.
        addressRegistry.updateMunicipality(
            address(municipalityANew),
            AMSTERDAM
        );

        vm.stopPrank();

        /* ACT */

        // Get municipality of Amsterdam.
        MunicipalityStruct memory mA = addressRegistry.getMunicipality(
            AMSTERDAM
        );

        // Actual municipality contract address must be equal to the expected.
        assertEq(address(municipalityANew), mA.contractAddr);
        // Actual CBS-code must be identical to the expected.
        assertEq(AMSTERDAM, mA.cbsCode);
        // Municipality of Amsterdam must be successfully registered.
        assertEq(mA.isRegistered, true);

        /* REVERT ERRORS */

        vm.startPrank(truhuis);

        // Must fail because new address is equal to old address.
        vm.expectRevert(MUNICIPALITY_UPDATE_FAILED.selector);
        addressRegistry.updateMunicipality(
            address(municipalityANew),
            AMSTERDAM
        );

        // Must fail because providing the zero address is not permitted.
        vm.expectRevert(ZERO_ADDRESS_PROVIDED.selector);
        addressRegistry.updateMunicipality(address(0), AMSTERDAM);

        vm.stopPrank();

        // Must fail because caller is not contract owner.
        vm.startPrank(ministryOfIKR);
        vm.expectRevert("Ownable: caller is not the owner");
        addressRegistry.updateMunicipality(address(municipalityH), THE_HAGUE);
        vm.stopPrank();
    }
}