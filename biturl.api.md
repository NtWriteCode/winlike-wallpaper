# Bing Wallpaper API

A RESTful API to fetch daily wallpaper from Bing.com

## Usage
### API

    API Address: https://bing.biturl.top
    Method: HTTP GET

### Parameters

    format - The response format, can be json or image. If response format is set as image, you will be redirected to the wallpaper image directly.
    image_format - The format of the wallpaper image, available values are jpg or webp. The default value is jpg.
    index - The index of wallpaper, starts from 0. By default, 0 means to get today's image, 1 means to get the image of yesterday, and so on. Or you can specify it as random to choose a random index between 0 and 7.
    mkt - The region parameter, the default value is zh-CN, you can also use en-US, ja-JP, en-AU, en-GB, de-DE, en-NZ, en-CA, en-IN, fr-FR, fr-CA, it-IT, es-ES, pt-BR, en-ROW. Alternatively, you can set it as random to choose the region randomly.
    resolution - The resolution of wallpaper image. 1920 is the default value, you can also use 1366 and 3840 or UHD (4K resolution).

### The available resolution options are listed below:

UHD
1920x1200
1920x1080
1366x768
1280x768
1024x768
800x600
800x480
768x1280 (Portrait mode)
720x1280 (Portrait mode)
640x480
480x800 (Portrait mode)
400x240
320x240
240x320 (Portrait mode)

## Example

### Request

https://bing.biturl.top/?resolution=UHD&format=json&index=0&mkt=zh-CN

### Response

{
    "start_date": "20240803",
    "end_date": "20240804",
    "url": "https://www.bing.com/th?id=OHR.ImpalaOxpecker_ZH-CN9652434873_UHD.jpg",
    "copyright": "黑斑羚和红嘴牛椋鸟，南非 (© Matrishva Vyas/Getty Images)",
    "copyright_link": "https://www.bing.com/search?q=%E5%8F%8B%E8%B0%8A%E6%97%A5&form=hpcapt&mkt=zh-cn"
}