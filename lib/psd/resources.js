// Generated by CoffeeScript 1.7.1
(function() {
  var Resource, Resources;

  Resource = require('./resource');

  module.exports = Resources = (function() {
    function Resources(file) {
      this.file = file;
      this.resources = {};
      this.typeIndex = {};
      this.length = null;
    }

    Resources.prototype.skip = function() {
      this.length = this.file.readInt();
      return this.file.seek(this.length, true);
    };

    Resources.prototype.parse = function() {
      var finish, resource, resourceEnd, section;
      this.length = this.file.readInt();
      finish = this.length + this.file.tell();
      while (this.file.tell() < finish) {
        resource = new Resource(this.file);
        resource.parse();
        resourceEnd = this.file.tell() + resource.length;
        section = Resource.Section.factory(resource);
        if (section == null) {
          this.file.seek(resourceEnd);
          continue;
        }
        this.resources[section.id] = section;
        if (section.name != null) {
          this.typeIndex[section.name] = section.id;
        }
        this.file.seek(resourceEnd);
      }
      return this.file.seek(finish);
    };

    Resources.prototype.resource = function(search) {
      if (typeof search === 'string') {
        return this.byType(search);
      } else {
        return this.resources[search];
      }
    };

    Resources.prototype.byType = function(name) {
      return this.resources[this.typeIndex[name]];
    };

    return Resources;

  })();

}).call(this);
