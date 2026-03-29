# Access the latest Bing daily wallpapers from around the world for your apps.
## API

    Endpoint: https://peapix.com/bing/feed
    Method: GET

## Parameters

    country - Specifies the Bing region for image results.
    Accepted values:
        au br ca cn de fr in it jp es gb us 
    n - The number of images to return.

## Examples

### Request

GET https://peapix.com/bing/feed?country=jp

### Response for this request:

[{
    "title": "太湖の桜, 中国 江蘇省",
    "copyright": "© Eric Yang/Getty Image",
    "fullUrl": "https://img.peapix.com/742a3b0ab5b04b2b83aea1df0863dd49_1920.jpg",
    "thumbUrl": "https://img.peapix.com/742a3b0ab5b04b2b83aea1df0863dd49_640.jpg",
    "imageUrl": "https://img.peapix.com/742a3b0ab5b04b2b83aea1df0863dd49.jpg",
    "pageUrl": "https://peapix.com/bing/38085"
}]
