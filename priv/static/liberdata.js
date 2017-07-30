liberdata = function() {
  this.commands = [];
  this.load_csv = function(resource) {
    console.log('loading csv '+resource);
    this.commands.push("load");
    this.commands.push("csv");
    this.commands.push(resource);
    return this
  };
  this.trim = function(key) {
    this.commands.push("trim");
    this.commands.push(key);
    return this;
  };
  this.filter = function(key, operator, value) {
    this.commands.push("filter");
    this.commands.push(key);
    this.commands.push(operator);
    this.commands.push(value);
    return this;
  };
  this.count = function() {
    this.commands.push("count");
    return this;
  };
  this.execute = function() {
    return new Promise(function(resolve, reject) {
      var xhr = new XMLHttpRequest();
      var address = 'https://liberdata.tech/api/' + this.commands.map(encodeURIComponent).join('/')
      xhr.open('get', address, true);
      xhr.responseType = 'json';
      xhr.onload = function() {
        var status = xhr.status;
        if (status == 200) {
          resolve(xhr.response);
        } else {
          reject(status);
        }
      };
      xhr.send();
    });
  };
  return this;
}
