/**
 *
 * $prefs.getValueForKey(key)
 * $prefs.setValueForKey(value, key)
 *
 */


/**
 * Login
 *
 * @param {object} account string type. eg: JSON.stringify({"id": "1", "username": "hello", "password": "world"})
 * @return {Array} return root folder of current account.
 */
function login() {
    // perform http request with $http.fetch
    // var data = {
    //     'username': 'jsdrive'
    // }
    // var headers = {
    //     'User-Agent': 'You custom user agent string'
    // }
    // var request = {
    //     url: "https://api.example.com",
    //     method: 'POST', // optional, default is GET
    //     headers: headers, // optional
    //     body: JSON.stringify(data) // optional
    // }
    // $http.fetch(request).then(response => {
    // }).catch(e=>console.log(e))
    setTimeout(()=> {
        $done({
            id: "root_id",
            name: "Alist",
            path: "/",
            isDirectory: true
            
        })
    }, 2000);
}

/**
 * List files at folder.
 *
 * @param {object} folder string type. eg. JSON.stringify({"id": "1", "name": "root", path: "/"})
 * @return {Array} return files in the target folder.
 */
function list(folder) {
    setTimeout(()=> {
        const a = {
            id: "A",
            name: "FolderA",
            path: "FolderA",
            isDirectory: true
        };
        const b = {
            id: "B",
            name: "FolderB",
            path: "FolderB",
            isDirectory: true
        }
        $done([a, b]);
    }, 2000);
}


/**
 * Fetch playback info of video file. use $done to complete the function.
 * 
 * @param {object} file file type.
 */
function videoInfo(file) {
    setTimeout(()=> {
        $done({
            url: "https://example.com/video.mp4",
            headers: {
                "Cookie": "mycookiename=myvalue",
                "Referer": "https://example.com"
            }
        });
    }, 2000);
}
