# JSDrive

A drive file browser app driven by JavaScript.

You can think JSDrive is a special JSBridge with provides native file browser experience with a simple video playback support.

The demo project shows show to use [alist](https://github.com/alist-org/alist) as drive provider. You can write your own provider by implementing functions in the `template.js`.

The purpose of this project is demostrate how you can integrate other drives without modifying native code. In other words, you can move your codes into JavaScript and load them dynamic. But be carefull, Apple maybe reject your apps if you are using private apis.

## Requirements

- iOS 15.0 +
- Xcode 13.4 +


## Get Started

- clone the project `git clone https://github.com/alexis/JSDrive`
- open JSDrive.xcodeproj with Xcode
- edit alist.js and replace `baseURL` with alist web url
- run the project


## Template

By implementing functions in template.js, you can create your own drive provider.

```javascript

// login the drive provider with account object and return root folder
function login() {
    // use $done({}) to notify success callback.
}

// list files with folder object
function list(folder) {
    // use $done([]) to notify success callback.
}

// fetch video playback info
function videoInfo(file) {
    // use $done({url: 'url', headers: {}}) to notify success callback.
}

```

You can also create more funtions to template.js and native browser, such as

- create folder
- delete file/folder
- preview images
- move files
- and much more ...

## Models

JavaScript should return defined models as native Swift requires。

```swift
struct DriveItem: Codable, Hashable {
    var id: String
    var name: String
    var path: String
    var isDirectory: Bool
    var size: Int? = nil
    var extras: [String: String]? = nil
}
```

You can repsent the file object as following:

```javascript

// file
{
    id: 'fileid',
    name: 'filename',
    path: '/',
    isDirectory: true,
    size: 100
}

```

## Built-ins

You can call these built in functions in JavaScript.

```javascript

// print log info to console
console.log('message');

// set value to prefs (Backend is UserDefaults)
$prefs.setValueForKey('key', 'value');

// get value from prefs (Backend is UserDefaults)
const value = $prefs.getValueForKey('key');

// remove the key related value
$prefs.removeValueForKey('key');

// perform http request with $http.fetch
var data = {
    'username': 'jsdrive'
}
var headers = {
    'User-Agent': 'You custom user agent string'
}
var request = {
    url: "https://api.example.com",
    method: 'POST', // optional, default is GET
    headers: headers, // optional
    body: JSON.stringify(data) // optional
}
$http.fetch(request).then(response => {
    $done({id: "1", name: 'name', path: '/'})
}).catch(e=>console.log(e))

```

## alist

The demo project shows how to load files with alist web api.

```javascript

// defines the alist host, should something like: https://example.com
const baseURL = "";

function login() {
    // do the login matter, just return the root folder object
    $done({
        id: 'root',
        name: 'alist',
        path: '/',
        isDirectory: true
    });
}

function list(folder) {
    // list folder, send post request to alist web api
    const obj = JSON.parse(folder);
    const data = {
        page_num: 1,
        page_size: 100,
        password: '',
        path: obj.path
    };
    const req = {
        url: baseURL + '/api/public/path',
        method: 'POST',
        headers: headers,
        body: JSON.stringify(data)
    };
    $http.fetch(req).then(res => {
         console.log(res.body);
        const items = JSON.parse(res.body).data.files;
        var files = [];
        const parent = obj.path === "/" ? "": obj.path;
        items.forEach(function(item) {
            const file = {
                isDirectory: item.type === 1,
                path: parent + "/" + item.name,
                name: item.name,
                id: item.name,
                size: item.size
            };
            files.push(file);
        });
        $done(files);
    });
}

```