(function(exports) {

  function isObject(obj) {
    var type = typeof obj;
    return type === 'function' || type === 'object' && !!obj;
  }

  function extend(obj) {
    if (!isObject(obj)) return obj;
    var source, prop;
    for (var i = 1, length = arguments.length; i < length; i++) {
      source = arguments[i];
      for (prop in source) {
        if (hasOwnProperty.call(source, prop)) {
            obj[prop] = source[prop];
        }
      }
    }
    return obj;
  }

  var scope = {
    require: function(path) {
      var module = {};
      scope.require.modules[path].call(null, scope.require.modules, scope.require, module);
      return module.exports;
    }
  }

  scope.require.modules = {};

  var App = function(properties) {
    extend(this, properties);
  };

  App.install = function() {};

  App.extend = function extendApp(subclass_properties) {
    var ParentClass = this;
    function AppSubclass(settings) {
      ParentClass.call(this, settings);
    }

    AppSubclass.reopen = function(properties) {
      extend(this.prototype, properties);
      return this;
    };
    AppSubclass.reopenClass = function(properties) {
      extend(this, properties);
      return this;
    };
    AppSubclass.reopen(new ParentClass(subclass_properties));
    AppSubclass.reopenClass(this);

    return AppSubclass;
  };

  exports.ZendeskApps = {
    AppScope: {
      create: function() {
        return scope;
      }
    },

    defineApp: App.extend.bind(App)
  };

  exports.require = scope.require;
}(this));
