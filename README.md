# Instagram plugin for Cordova

[![Join the chat at https://gitter.im/vstirbu/InstagramPlugin](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/vstirbu/InstagramPlugin?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

By [Vlad Stirbu](https://github.com/vstirbu).

Adds ability to share the content of a canvas element or a dataUrl encoded image using the Instagram application for iOS and Android.

[![GitHub version](https://badge.fury.io/gh/vstirbu%2FInstagramPlugin.png)](http://badge.fury.io/gh/vstirbu%2FInstagramPlugin) [![Stories in Ready](https://badge.waffle.io/vstirbu/instagramplugin.png?label=ready)](https://waffle.io/vstirbu/instagramplugin)

### Installing the plugin to your project

In your project directory:

```bash
cordova plugins add https://github.com/vstirbu/InstagramPlugin
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

Share the content of a canvas element or a base64 dataURL image. The function share accepts a string, corresponding to the canvas element id or the dataURL, an optional caption, and a callback function as parameters:

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

A very basic application that uses the plugin can be found [here](https://github.com/vstirbu/instagramplugin-example).

### Quirks:

#### Android

* Passing caption in addition to sharing image requires Instagram Android application [version 6.1.0 or higher](http://instagram.com/developer/mobile-sharing/android-intents/#).
* Older versions of Android (2.x-3.x) do not have proper support for toDataURL on canvas elements. You can still get the canvas content as dataURL following these [instructions](http://jbkflex.wordpress.com/2012/12/21/html5-canvas-todataurl-support-for-android-devices-working-phonegap-2-2-0-plugin/). Pass the dataUrl instead of the canvas id to ```share```.

#### iOS

* Althought the plugin follows the [instructions](http://instagram.com/developer/iphone-hooks/) to show only Instagram in the document interaction controller, there are [reports](https://github.com/vstirbu/InstagramPlugin/issues/23) that other apps appear in the list.

### Recipes

* Sharing image when knowing the [file url](https://github.com/vstirbu/InstagramPlugin/issues/29).

### License

The plugin is available under MIT license.
