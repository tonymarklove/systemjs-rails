var path = require('path');

var opts = {
  config: {
    baseURL: path.resolve('app/assets/javascripts'),
    transpiler: "6to5",

    paths: {
      "*": "*.js",
      "app/*": "app/*.js",
      "test/*": "../../../test/fixtures/test/*.js",
      "npm:*": "../../../../es6-test/vendor/assets/javascripts/jspm_packages/npm/*.js",
      "github:*": "../../../../es6-test/vendor/assets/javascripts/jspm_packages/github/*.js"
    },

    // any map config
    map: {
      jquery: "github:components/jquery@2.1.3",
      underscore: "npm:underscore@1.7.0"
    }
  }
};

var systemJsBuilder = require('systemjs-builder');
var es6Compiler = require('systemjs-builder/compilers/es6');
var registerCompiler = require('systemjs-builder/compilers/register');
var amdCompiler = require('systemjs-builder/compilers/amd');
var cjsCompiler = require('systemjs-builder/compilers/cjs');
var globalCompiler = require('systemjs-builder/compilers/global');

// TODO source maps
var loader;

function reset() {
  loader = new Loader(System);
  loader.baseURL = System.baseURL;
  loader.paths = { '*': '*.js' };
  loader.config = System.config;

  loader.trace = true;
  loader.execute = false;

  loader.set('@empty', loader.newModule({}));

  amdCompiler.attach(loader);
}

reset();

function compileLoad(load, opts, compilers) {
  return Promise.resolve()
  .then(function() {
    // note which compilers we used
    compilers = compilers || {};
    if (load.metadata.build == false) {
      return {};
    }
    else if (load.metadata.format == 'es6') {
      compilers['es6'] = true;
      return es6Compiler.compile(load, opts, loader);
    }
    else if (load.metadata.format == 'register') {
      compilers['register'] = true;
      return registerCompiler.compile(load, opts, loader);
    }
    else if (load.metadata.format == 'amd') {
      compilers['amd'] = true;
      return amdCompiler.compile(load, opts, loader);
    }
    else if (load.metadata.format == 'cjs') {
      compilers['cjs'] = true;
      return cjsCompiler.compile(load, opts, loader);
    }
    else if (load.metadata.format == 'global') {
      compilers['global'] = true;
      return globalCompiler.compile(load, opts, loader);
    }
    else if (load.metadata.format == 'defined') {
      return {source: ''};
    }
    else {
      throw "unknown format " + load.metadata.format;
    }
  });
}

var buildSingle = function(moduleName, opts) {
  opts = opts || {};
  var config = opts.config;

  var outputs = ['"format register";\n'];
  var requires = [];
  opts.normalize = true;

  return systemJsBuilder.trace(moduleName, config)
    .then(function(trace) {
      var tree = trace.tree;
      moduleName = trace.moduleName;

      requires = Object.keys(tree).filter(function(name) {
        return name !== moduleName
      }).map(function(name) {
        var load = tree[name];
        return load.address;
      });

      var load = tree[moduleName];
      Promise.resolve(compileLoad(load, opts)).then(function(compiledSource) {
        outputs.push(compiledSource.source);
      });
    })
    .then(function() {
      return {requires: requires, source: outputs};
    });
};

buildSingle(process.argv[2], opts).then(function(result) {
  result.source = result.source.join("\n");
  console.log(JSON.stringify(result));
});
