/**
 *
 *
 * $prefs.getValueForKey(key)
 * $prefs.setValueForKey(value, key)
 *
 */

const baseURL = "https://pan.qxnav.com";

var headers = {
    'content-type': 'application/json;charset=UTF-8'
}

/**
 * Login account.
 *
 * @param {object} account string type. eg: JSON.stringify({"id": "1", "username": "hello", "password": "world"})
 * @return {Array} return root folder of current account.
 */
function login() {
    $done({
        id: 'root',
        name: 'alist',
        path: '/',
        isDirectory: true
    });
}

/**
 * List files at folder.
 *
 * @param {object} folder string type. eg. JSON.stringify({"id": "1", "name": "root", path: "/"})
 * @return {Array} return files in the target folder.
 */
function list(folder) {
    const obj = JSON.parse(folder);
    console.log(JSON.stringify(obj));
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

function videoInfo(file) {
    const obj = JSON.parse(file);
    $done({
        url: baseURL + '/d' + encodeURIComponent(obj.path)
    });
}
