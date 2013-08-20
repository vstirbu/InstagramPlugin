# Instagram plugin for Cordova

By [Vlad Stirbu](https://github.com/vstirbu).

Adds ability to share the content of a canvas element or a dataUrl encoded image using the Instagram application for iOS and Android.

### Installing the plugin to your project

The simplest way to install the plugin is via the [plugman](https://github.com/apache/cordova-plugman) tool.

If you prefer to install the plugin manually, copy the content of the src/ios folder in the Plugins directory and the content of the www folder in your www folder. Add the plugin to your Cordova.plist, in Plugins section: the key is ```Instagram``` and value is ```CDVInstagramPlugin```.

### Instagram plugin JavaScript API

Detect if the Instagram application is installed on the device. The function isInstalled accepts a callback function as parameter:

```javascript
Instagram.isInstalled(function (err, installed) {
    if (installed) {
        console.log("Instagram is installed");
    } else {
        console.log("Instagram is not installed");
    }
});
```

Share the content of a canvas element or a base64 dataURL image. The function share accepts a string, corresponding to the canvas element id or the dataURL, and a callback function as parameters:

```javascript
Instagram.share(canvasIdOrDataUrl, function (err) {
    if (err) {
        console.log("not shared");
    } else {
        console.log("shared");
    }
});
```

### Android Quirks:

Older versions of Android (2.x-3.x) do not have proper support for toDataURL on canvas elements. You can still get the canvas content as dataURL following these [instructions](http://jbkflex.wordpress.com/2012/12/21/html5-canvas-todataurl-support-for-android-devices-working-phonegap-2-2-0-plugin/). Pass the dataUrl instead of the canvas id to ```share```.

### License

The plugin is available under MIT license.
