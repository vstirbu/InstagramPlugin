# Instagram plugin for Cordova

By [Vlad Stirbu](https://github.com/vstirbu).

Adds ability to share the content of a canvas element or a dataUrl encoded image using the Instagram application for iOS and Android.

[![GitHub version](https://badge.fury.io/gh/vstirbu%2FInstagramPlugin.png)](http://badge.fury.io/gh/vstirbu%2FInstagramPlugin) [![Stories in Ready](https://badge.waffle.io/vstirbu/instagramplugin.png?label=ready)](https://waffle.io/vstirbu/instagramplugin)
[![Join the chat at https://gitter.im/vstirbu/InstagramPlugin](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/vstirbu/InstagramPlugin?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

### Installing the plugin to your project

If you use `cordova-cli` newer than 5.0:

```bash
cordova plugin add cordova-instagram-plugin
```

or, for older versions:

```bash
cordova plugin add https://github.com/vstirbu/InstagramPlugin
```

### Instagram plugin JavaScript API

Detect if the Instagram application is installed on the device. The function isInstalled accepts a callback function as parameter:

```javascript
Instagram.isInstalled(function (err, installed) {
    if (installed) {
        console.log("Instagram is", installed); // installed app version on Android
    } else {
        console.log("Instagram is not installed");
    }
});
```

Share the content of a canvas element or a base64 dataURL __png__ image. The function share accepts a string, corresponding to the canvas element id or the dataURL, an optional caption, and a callback function as parameters:

__API CHANGE NOTE__: [Instagram](http://developers.instagram.com/post/125972775561/removing-pre-filled-captions-from-mobile-sharing) app stopped accepting pre-filled captions on both iOS and Android. As a work-around, the caption is copied to the clipboard. You have to inform your users to paste the caption.

```javascript
Instagram.share(canvasIdOrDataUrl, caption, function (err) {
    if (err) {
        console.log("not shared");
    } else {
        console.log("shared");
    }
});
```

or:

```javascript
Instagram.share(canvasIdOrDataUrl, function (err) {
    if (err) {
        console.log("not shared");
    } else {
        console.log("shared");
    }
});
```

Share library __asset__ image or video. The function shareAsset (iOS only) accepts a string with asset local identifier, and a callback function as parameters:
```javascript
var assetLocalIdentifier = "24320B60-1F52-46AC-BE4C-1202F02B9D00/L0/001";
Instagram.shareAsset(function(result) {
            console.log('Instagram.shareAsset success: ' + result);
        }, function(e) {
            console.log('Instagram.shareAsset error: ' + e);
        }, assetLocalIdentifier);
```
You can get a LocalIdentifier by using Photos Framework [Fetching Assets](https://developer.apple.com/library/ios/documentation/Photos/Reference/PHAsset_Class/#//apple_ref/doc/uid/TP40014383-CH1-SW2) API

A very basic application that uses the plugin can be found [here](https://github.com/vstirbu/instagramplugin-example).

### AngularJS/Ionic

The plugin is included in [ngCordova](http://ngcordova.com/docs/plugins/instagram/) and [ionic-native](https://github.com/driftyco/ionic-native).

__NOTE__: If you are using an image from the server,then you should download the image and fetch  the content using   [readAsDataURL](https://developer.mozilla.org/en-US/docs/Web/API/FileReader/readAsDataURL).
Example:
* Add plugin [cordova-plugin-file-transfer](https://cordova.apache.org/docs/en/latest/reference/cordova-plugin-file-transfer)
```Javascript code
var url = encodeURI('https://static.pexels.com/photos/33109/fall-autumn-red-season.jpg');
var filename = 'image.jpg';
var targetPath = cordova.file.externalRootDirectory + filename;
$cordovaFileTransfer.download(url, targetPath, {}, true).then(function(result) {
        var mywallpaper = result.toURL();
        window.resolveLocalFileSystemURL(mywallpaper, function(fileEntry) {
            fileEntry.file(function(file) {
                var reader = new FileReader(),
                    data = null;
                reader.onloadend = function(event) {
                    data = reader.result;
                    $cordovaInstagram.share(data, '#amazing').then(function(success) {
                        console.log('shareViaInstagram Success', success);
                    }, function(err) {
                        console.log('shareViaInstagram failed', err);
                    });
                };
                reader.readAsDataURL(file)
            });
        });
    },
    function(error) {},
    function(progress) {
});
```

### Quirks:

#### Android

* Passing caption in addition to sharing image requires Instagram Android application [version 6.1.0 or higher](http://instagram.com/developer/mobile-sharing/android-intents/#).
* Older versions of Android (2.x-3.x) do not have proper support for toDataURL on canvas elements. You can still get the canvas content as dataURL following these [instructions](http://jbkflex.wordpress.com/2012/12/21/html5-canvas-todataurl-support-for-android-devices-working-phonegap-2-2-0-plugin/). Pass the dataUrl instead of the canvas id to ```share```.

#### iOS

* Although the plugin follows the [instructions](https://www.instagram.com/developer/mobile-sharing/iphone-hooks/) to show only Instagram in the document interaction controller, there are [reports](https://github.com/vstirbu/InstagramPlugin/issues/23) that other apps appear in the list.

### Recipes

* Sharing image when knowing the [file url](https://github.com/vstirbu/InstagramPlugin/issues/29).

### License

The plugin is available under MIT license.
