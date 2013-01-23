/*
    The MIT License (MIT)
    Copyright (c) 2013 Vlad Stirbu
    
    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    
    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

(function () {

    var cordovaRef = window.PhoneGap || window.Cordova || window.cordova; // old to new fallbacks

    function Instagram() {}

    Instagram.prototype.isInstalled = function (callback) {

        cordovaRef.exec(function () {
            callback(null, true);
        }, function () {
            callback(null, false);
        }, "Instagram", "isInstalled", []);

    };

    Instagram.prototype.share = function (canvasId, callback) {
		var canvas = document.getElementById(canvasId),
            imageData = canvas.toDataURL().replace(/data:image\/png;base64,/,"");

        cordovaRef.exec(function () {
            callback(null, true);
        }, function () {
            callback("error");
        }, "Instagram", "share", [imageData]);

    };

    Instagram.install = function () {
        if (!window.plugins) {
            window.plugins = {};
        }
        if (!window.plugins.instagram) {
            window.plugins.instagram = new Instagram();
        }
    };

    if (cordovaRef && cordovaRef.addConstructor) {
        cordovaRef.addConstructor(Instagram.install);
        console.log("installed");
    }
    else {
        console.log("Instagram Cordova Plugin could not be installed.");
        return null;
    }

})();
