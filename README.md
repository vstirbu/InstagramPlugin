# Instagram plugin for Cordova

By [Vlad Stirbu](https://github.com/vstirbu).

Adds ability to share the content of a canvas element or a dataUrl encoded image using the Instagram application for iOS and Android.
__UPDATED__
Now accepts the URL of an image and bakes the caption onto the image before opening in Instagram.

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

__CHANGED FUNCTIONALITY FROM ORIGINAL__
Share the content of an image URL. The function share accepts a string, corresponding to the URL of the image, an optional caption to bake onto the image, and a callback function as parameters:

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

A very basic application that uses the plugin can be found [here](https://github.com/vstirbu/instagramplugin-example).

### AngularJS

The plugin is included in [ngCordova](http://ngcordova.com/docs/plugins/instagram/).

### Quirks:

#### Android

* Passing caption in addition to sharing image requires Instagram Android application [version 6.1.0 or higher](http://instagram.com/developer/mobile-sharing/android-intents/#).
* Older versions of Android (2.x-3.x) do not have proper support for toDataURL on canvas elements. You can still get the canvas content as dataURL following these [instructions](http://jbkflex.wordpress.com/2012/12/21/html5-canvas-todataurl-support-for-android-devices-working-phonegap-2-2-0-plugin/). Pass the dataUrl instead of the canvas id to ```share```.

#### iOS

* Although the plugin follows the [instructions](http://instagram.com/developer/iphone-hooks/) to show only Instagram in the document interaction controller, there are [reports](https://github.com/vstirbu/InstagramPlugin/issues/23) that other apps appear in the list.

### Recipes

* Sharing image when knowing the [file url](https://github.com/vstirbu/InstagramPlugin/issues/29).

### License

The plugin is available under MIT license.
