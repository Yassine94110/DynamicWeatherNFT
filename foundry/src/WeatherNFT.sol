// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WeatherNFT is ERC721, Ownable {
    uint256 public tokenCounter;

    enum WeatherType {
        Sun,
        Rain,
        Snow
    }

    struct WeatherData {
        int256 temperature;
        uint256 humidity;
        uint256 windSpeed;
        WeatherType weatherType;
        string additionalInfo;
        uint256 timestamp;
    }

    mapping(uint256 => WeatherData[]) private weatherHistory;
    mapping(WeatherType => string) public weatherTypeCID;

    event Minted(uint256 tokenId, address owner);
    event MetadataUpdated(uint256 tokenId, WeatherData data);

    constructor() ERC721("WeatherNFT", "WNFT") Ownable(msg.sender) {
        tokenCounter = 0;

        // Define CIDs for each weather type
        weatherTypeCID[
            WeatherType.Sun
        ] = "bafkreie667pj4qimtdcmld2hl2blbwnfcwdcn5vklzcxgxyteypzj4wnte";
        weatherTypeCID[
            WeatherType.Rain
        ] = "bafkreib77zirhipoqjirkpwoowxbuh7yivs3xu4szi2xbhy23qieqv6ps4";
        weatherTypeCID[
            WeatherType.Snow
        ] = "bafkreierhwploerf6lsaydheglsrbpyqggtjssnz5cpubehhpvuxjigyuu";
    }

    // Mint a new NFT with initial weather data
    function mintWeatherNFT(
        int256 temperature,
        uint256 humidity,
        uint256 windSpeed,
        WeatherType weatherType,
        string memory additionalInfo
    ) external returns (uint256) {
        uint256 newTokenId = tokenCounter;
        _safeMint(msg.sender, newTokenId);

        weatherHistory[newTokenId].push(
            WeatherData({
                temperature: temperature,
                humidity: humidity,
                windSpeed: windSpeed,
                weatherType: weatherType,
                additionalInfo: additionalInfo,
                timestamp: block.timestamp
            })
        );

        tokenCounter += 1;

        emit Minted(newTokenId, msg.sender);
        return newTokenId;
    }

    // Update metadata for a specific tokenId
    function updateWeatherMetadata(
        uint256 tokenId,
        int256 temperature,
        uint256 humidity,
        uint256 windSpeed,
        WeatherType weatherType,
        string memory additionalInfo
    ) external {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "Caller is not the owner");

        WeatherData memory newWeatherData = WeatherData({
            temperature: temperature,
            humidity: humidity,
            windSpeed: windSpeed,
            weatherType: weatherType,
            additionalInfo: additionalInfo,
            timestamp: block.timestamp
        });

        weatherHistory[tokenId].push(newWeatherData);

        emit MetadataUpdated(tokenId, newWeatherData);
    }

    // Retrieve weather data for specific periods
    function getWeatherData(
        uint256 tokenId,
        uint256 period
    ) external view returns (WeatherData[] memory) {
        require(_exists(tokenId), "Token does not exist");

        uint256 startTime;
        if (period == 1) {
            // Today
            startTime = block.timestamp - 1 days;
        } else if (period == 7) {
            // Last week
            startTime = block.timestamp - 7 days;
        } else if (period == 30) {
            // Last month
            startTime = block.timestamp - 30 days;
        } else {
            revert(
                "Invalid period. Use 1 (Today), 7 (Last week), or 30 (Last month)."
            );
        }

        uint256 length = 0;

        for (uint256 i = 0; i < weatherHistory[tokenId].length; i++) {
            if (weatherHistory[tokenId][i].timestamp >= startTime) {
                length++;
            }
        }

        WeatherData[] memory results = new WeatherData[](length);
        uint256 index = 0;

        for (uint256 i = 0; i < weatherHistory[tokenId].length; i++) {
            if (weatherHistory[tokenId][i].timestamp >= startTime) {
                results[index] = weatherHistory[tokenId][i];
                index++;
            }
        }

        return results;
    }

    // Retrieve the CID for a specific weather type
    function getWeatherTypeCID(
        WeatherType weatherType
    ) external view returns (string memory) {
        return weatherTypeCID[weatherType];
    }

    // Utility function to check if a token exists
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}
