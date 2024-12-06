// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/WeatherNFT.sol";

contract WeatherNFTTest is Test {
    WeatherNFT weatherNFT;
    address owner = address(this); // Deploying contract owner
    address user = address(0x1234);

    function setUp() public {
        weatherNFT = new WeatherNFT();
    }

    function testMintWeatherNFT() public {
        // Mint a new WeatherNFT
        int256 temp = 25;
        uint256 humidity = 60;
        uint256 windSpeed = 15;
        string memory additionalInfo = "Sunny day";

        uint256 tokenId = weatherNFT.mintWeatherNFT(
            temp,
            humidity,
            windSpeed,
            WeatherNFT.WeatherType.Sun,
            additionalInfo
        );

        // Validate token ID and ownership
        assertEq(tokenId, 0);
        assertEq(weatherNFT.ownerOf(tokenId), owner);
    }

    function testUpdateWeatherMetadata() public {
        // Mint a WeatherNFT
        int256 temp = 10;
        uint256 humidity = 80;
        uint256 windSpeed = 20;
        string memory additionalInfo = "Snowy day";

        uint256 tokenId = weatherNFT.mintWeatherNFT(
            temp,
            humidity,
            windSpeed,
            WeatherNFT.WeatherType.Snow,
            additionalInfo
        );

        // Update the metadata
        weatherNFT.updateWeatherMetadata(
            tokenId,
            -5, // New temperature
            90, // New humidity
            25, // New windSpeed
            WeatherNFT.WeatherType.Snow,
            "Extreme cold"
        );

        // Retrieve data and validate update
        WeatherNFT.WeatherData[] memory data = weatherNFT.getWeatherData(
            tokenId,
            1
        );
        assertEq(data.length, 2); // Initial + update
        assertEq(data[1].temperature, -5);
        assertEq(data[1].humidity, 90);
        assertEq(data[1].windSpeed, 25);
        assertEq(
            uint256(data[1].weatherType),
            uint256(WeatherNFT.WeatherType.Snow)
        );
        assertEq(data[1].additionalInfo, "Extreme cold");
    }

    function testOnlyOwnerCanUpdateMetadata() public {
        // Mint a WeatherNFT
        uint256 tokenId = weatherNFT.mintWeatherNFT(
            15,
            70,
            10,
            WeatherNFT.WeatherType.Rain,
            "Rainy day"
        );

        // Try updating metadata as a non-owner
        vm.prank(user); // Change sender to user
        vm.expectRevert("Caller is not the owner");
        weatherNFT.updateWeatherMetadata(
            tokenId,
            20,
            75,
            15,
            WeatherNFT.WeatherType.Rain,
            "Mild rain"
        );
    }

    function testGetWeatherDataForPeriods() public {
        // Mint a WeatherNFT
        uint256 tokenId = weatherNFT.mintWeatherNFT(
            30,
            50,
            10,
            WeatherNFT.WeatherType.Sun,
            "Hot day"
        );

        // Add historical data
        weatherNFT.updateWeatherMetadata(
            tokenId,
            28,
            45,
            12,
            WeatherNFT.WeatherType.Sun,
            "Cooler evening"
        );

        // Fast forward time to simulate older data
        vm.warp(block.timestamp + 2 days);

        weatherNFT.updateWeatherMetadata(
            tokenId,
            32,
            60,
            15,
            WeatherNFT.WeatherType.Sun,
            "Sunny morning"
        );

        // Retrieve last week's data
        WeatherNFT.WeatherData[] memory data = weatherNFT.getWeatherData(
            tokenId,
            7
        );
        assertEq(data.length, 3); // All records within the week

        // Retrieve today's data
        data = weatherNFT.getWeatherData(tokenId, 1);
        assertEq(data.length, 1); // Only the last update
        assertEq(data[0].temperature, 32);
    }

    function testGetWeatherTypeCID() public {
        // Validate CID mapping
        assertEq(
            weatherNFT.getWeatherTypeCID(WeatherNFT.WeatherType.Sun),
            "bafkreie667pj4qimtdcmld2hl2blbwnfcwdcn5vklzcxgxyteypzj4wnte"
        );
        assertEq(
            weatherNFT.getWeatherTypeCID(WeatherNFT.WeatherType.Rain),
            "bafkreib77zirhipoqjirkpwoowxbuh7yivs3xu4szi2xbhy23qieqv6ps4"
        );
        assertEq(
            weatherNFT.getWeatherTypeCID(WeatherNFT.WeatherType.Snow),
            "bafkreierhwploerf6lsaydheglsrbpyqggtjssnz5cpubehhpvuxjigyuu"
        );
    }
}
