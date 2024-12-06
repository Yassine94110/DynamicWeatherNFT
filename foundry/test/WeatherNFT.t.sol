// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/WeatherNFT.sol";
import {console} from "forge-std/console.sol";

contract WeatherNFTTest is Test {
    WeatherNFT public weatherNFT;

    // Adresse du propriétaire du contrat
    address owner = address(0x123);

    function setUp() public {
        // Déployer le contrat avant chaque test
        weatherNFT = new WeatherNFT();
        vm.startPrank(owner); // Simuler les transactions comme si c'était l'owner
    }

    function tearDown() public {
        vm.stopPrank(); // Terminer la simulation de l'owner
    }

    function testMintWeatherNFT() public {
        // Test de la fonction mintWeatherNFT
        uint256 tokenId = weatherNFT.mintWeatherNFT(
            30,
            60,
            10,
            WeatherNFT.WeatherType.Sun,
            "Clear sky"
        );

        // Vérifier que le token a bien été minté
        assertEq(weatherNFT.ownerOf(tokenId), owner);
    }

    function testUpdateWeatherMetadata() public {
        // Créer un NFT
        uint256 tokenId = weatherNFT.mintWeatherNFT(
            30,
            60,
            10,
            WeatherNFT.WeatherType.Sun,
            "Clear sky"
        );

        // Mettre à jour les métadonnées
        weatherNFT.updateWeatherMetadata(
            tokenId,
            25,
            70,
            15,
            WeatherNFT.WeatherType.Rain,
            "Cloudy"
        );

        // Récupérer les données météo mises à jour
        WeatherNFT.WeatherData[] memory data = weatherNFT.getWeatherData(
            tokenId,
            1
        );
        // console.log data

        assertEq(data[0].temperature, 30);
        assertEq(data[0].humidity, 60);
        assertEq(data[0].windSpeed, 10);

        assertEq(data[0].additionalInfo, "Clear sky");
    }
}
