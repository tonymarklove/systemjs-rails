var System = (function() {
  var config = {};

  function merge(options1, options2) {
    for (var attrname in options2) {
      options1[attrname] = options2[attrname];
    }
  }

  return {
    config: function(options) {
      merge(config, options);
    },

    fetchConfig: function() {
      return JSON.stringify(config);
    }
  };
})();
