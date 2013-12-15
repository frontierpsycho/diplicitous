#!/usr/bin/env node

// note: coffeescript required

// sudo npm install -g coffee-script
// export NODE_PATH=$NODE_PATH:/usr/local/lib/node:/usr/local/lib/node_modules

var SourceMaps = {}

var coffee = require('coffee-script'),
    util = require('util'),
    http = require('http'),
    fs = require('fs'),
    url = require('url'),
    events = require('events');

var DEFAULT_PORT = 8000;

function main(argv) {
  new HttpServer({
    'GET': createServlet(StaticServlet),
    'HEAD': createServlet(StaticServlet)
  }).start(Number(argv[2]) || DEFAULT_PORT);
}

function escapeHtml(value) {
  return value.toString().
    replace('<', '&lt;').
    replace('>', '&gt;').
    replace('"', '&quot;');
}

function createServlet(Class) {
  var servlet = new Class();
  return servlet.handleRequest.bind(servlet);
}

/**
 * An Http server implementation that uses a map of methods to decide
 * action routing.
 *
 * @param {Object} Map of method => Handler function
 */
function HttpServer(handlers) {
  this.handlers = handlers;
  this.server = http.createServer(this.handleRequest_.bind(this));
}

HttpServer.prototype.start = function(port) {
  this.port = port;
  this.server.listen(port);
  util.puts('Http Server running at http://localhost:' + port + '/');
};

HttpServer.prototype.parseUrl_ = function(urlString) {
  var parsed = url.parse(urlString);
  parsed.pathname = url.resolve('/', parsed.pathname);
  return url.parse(url.format(parsed), true);
};

HttpServer.prototype.handleRequest_ = function(req, res) {
  var logEntry = req.method + ' ' + req.url;
  if (req.headers['user-agent']) {
    logEntry += ' ' + req.headers['user-agent'];
  }
  util.puts(logEntry);
  req.url = this.parseUrl_(req.url);
  var handler = this.handlers[req.method];
  if (!handler) {
    res.writeHead(501);
    res.end();
  } else {
    handler.call(this, req, res);
  }
};

/**
 * Handles static content.
 */
function StaticServlet() {}

StaticServlet.MimeMap = {
  'txt': 'text/plain',
  'html': 'text/html',
  'css': 'text/css',
  'xml': 'application/xml',
  'json': 'application/json',
  'js': 'application/javascript',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'gif': 'image/gif',
  'png': 'image/png',
  'svg': 'image/svg+xml'
};

StaticServlet.prototype.handleRequest = function(req, res) {
  var self = this;
  var path = ('./' + req.url.pathname).replace('//','/').replace(/%(..)/g, function(match, hex){
    return String.fromCharCode(parseInt(hex, 16));
  });
  var parts = path.split('/');
  if (parts[parts.length-1].charAt(0) === '.')
    return self.sendForbidden_(req, res, path);

  // is a .js file is requested,
  // check for .coffee file first
  var jsMatch = path.match(/(.+)\.js$/);
  if (jsMatch && jsMatch.length >= 2) {
    return self.sendCoffeeFile_(req, res, jsMatch);
  }
  var mapMatch = path.match(/(.+)\.map$/);
  if (mapMatch && mapMatch.length >= 2) {
    return self.sendMapFile_(req, res, mapMatch);
  }

  fs.stat(path, function(err, stat) {
    if (err)
      return self.sendMissing_(req, res, path);
    if (stat.isDirectory())
      return self.sendDirectory_(req, res, path);
    return self.sendFile_(req, res, path);
  });
}

StaticServlet.prototype.sendError_ = function(req, res, error) {
  res.writeHead(500, {
      'Content-Type': 'text/html'
  });
  res.write('<!doctype html>\n');
  res.write('<title>Internal Server Error</title>\n');
  res.write('<h1>Internal Server Error</h1>');
  res.write('<pre>' + escapeHtml(util.inspect(error)) + '</pre>');
  util.puts('500 Internal Server Error');
  util.puts(util.inspect(error));
};

StaticServlet.prototype.sendMissing_ = function(req, res, path) {
  path = path.substring(1);
  res.writeHead(404, {
      'Content-Type': 'text/html'
  });
  res.write('<!doctype html>\n');
  res.write('<title>404 Not Found</title>\n');
  res.write('<h1>Not Found</h1>');
  res.write(
    '<p>The requested URL ' +
    escapeHtml(path) +
    ' was not found on this server.</p>'
  );
  res.end();
  util.puts('404 Not Found: ' + path);
};

StaticServlet.prototype.sendForbidden_ = function(req, res, path) {
  path = path.substring(1);
  res.writeHead(403, {
      'Content-Type': 'text/html'
  });
  res.write('<!doctype html>\n');
  res.write('<title>403 Forbidden</title>\n');
  res.write('<h1>Forbidden</h1>');
  res.write(
    '<p>You do not have permission to access ' +
    escapeHtml(path) + ' on this server.</p>'
  );
  res.end();
  util.puts('403 Forbidden: ' + path);
};

StaticServlet.prototype.sendRedirect_ = function(req, res, redirectUrl) {
  res.writeHead(301, {
      'Content-Type': 'text/html',
      'Location': redirectUrl
  });
  res.write('<!doctype html>\n');
  res.write('<title>301 Moved Permanently</title>\n');
  res.write('<h1>Moved Permanently</h1>');
  res.write(
    '<p>The document has moved <a href="' +
    redirectUrl +
    '">here</a>.</p>'
  );
  res.end();
  util.puts('301 Moved Permanently: ' + redirectUrl);
};

StaticServlet.prototype.sendFile_ = function(req, res, path) {
  var self = this;
  var file = fs.createReadStream(path);
  res.writeHead(200, {
    'Content-Type': StaticServlet.
      MimeMap[path.split('.').pop()] || 'text/plain'
  });
  if (req.method === 'HEAD') {
    res.end();
  } else {
    file.on('data', res.write.bind(res));
    file.on('close', function() {
      res.end();
    });
    file.on('error', function(error) {
      self.sendError_(req, res, error);
    });
  }
};

/**
  * Tries to find and compile a .coffee file first
  * If not found, will try to send the original .js
  * @param {Array.String} match is a result from path.match function
  */
StaticServlet.prototype.sendCoffeeFile_ = function(req, res, match) {
  var self = this;
  var path = match[0];
  var coffeeFile = match[1] + '.coffee';
  coffeeFile = coffeeFile.replace("/js/", "/coffee/");
  fs.exists(coffeeFile, function (exists) {
    if (exists) {
      fs.readFile(coffeeFile, 'utf8', function(err, data) {
        // compiles the coffee file without top-level wrapper function
        // to enable the option to pollute global scope
        // and let this unhealthy feature of angular work
        var compilerOptions = {
          'bare': true,
          'filename': coffeeFile,
          'sourceMap': true,
          'sourceFiles': [coffeeFile.substring(1)]
        }
        var compiled = coffee.compile(data, compilerOptions);
        res.write(compiled.js);
        res.write("/*\n//@ sourceMappingURL="+match[1].substring(1)+".map\n*/ ")
        res.end();
        SourceMaps[match[1]+".map"] = compiled.v3SourceMap;
      });
    } else {
      // .coffee not found, try to find and return original request
      fs.exists(path, function(exists) {
        if (exists) {
          self.sendFile_(req, res, path);
        } else {
          self.sendMissing_(req, res, path);
        }
      });
    }
  });
}

StaticServlet.prototype.sendMapFile_ = function(req, res, match) {
    var self = this;
    var path = match[0];
    if (SourceMaps[match[1]+".map"]){
        res.write(SourceMaps[match[1]+".map"]);
        res.end();
    } else {
      // .map not found, try to find and return original request
      fs.exists(path, function(exists) {
        if (exists) {
          self.sendFile_(req, res, path);
        } else {
          self.sendMissing_(req, res, path);
        }
      });
    }
};

StaticServlet.prototype.sendDirectory_ = function(req, res, path) {
  var self = this;
  if (path.match(/[^\/]$/)) {
    req.url.pathname += '/';
    var redirectUrl = url.format(url.parse(url.format(req.url)));
    return self.sendRedirect_(req, res, redirectUrl);
  }
  fs.readdir(path, function(err, files) {
    if (err)
      return self.sendError_(req, res, error);

    if (!files.length)
      return self.writeDirectoryIndex_(req, res, path, []);

    var remaining = files.length;
    files.forEach(function(fileName, index) {
      fs.stat(path + '/' + fileName, function(err, stat) {
        if (err)
          return self.sendError_(req, res, err);
        if (stat.isDirectory()) {
          files[index] = fileName + '/';
        }
        if (!(--remaining))
          return self.writeDirectoryIndex_(req, res, path, files);
      });
    });
  });
};

StaticServlet.prototype.writeDirectoryIndex_ = function(req, res, path, files) {
  path = path.substring(1);
  res.writeHead(200, {
    'Content-Type': 'text/html'
  });
  if (req.method === 'HEAD') {
    res.end();
    return;
  }
  res.write('<!doctype html>\n');
  res.write('<title>' + escapeHtml(path) + '</title>\n');
  res.write('<style>\n');
  res.write('  ol { list-style-type: none; font-size: 1.2em; }\n');
  res.write('</style>\n');
  res.write('<h1>Directory: ' + escapeHtml(path) + '</h1>');
  res.write('<ol>');
  files.forEach(function(fileName) {
    if (fileName.charAt(0) !== '.') {
      res.write('<li><a href="' +
        escapeHtml(fileName) + '">' +
        escapeHtml(fileName) + '</a></li>');
    }
  });
  res.write('</ol>');
  res.end();
};

// Must be last,
main(process.argv);
