var Template = function(input) {
    this.source = input["source"];
};

Template.prototype = {
    render: function(variables) {
        var result = this.source;
        
        for (var k in variables){
            var re = new RegExp("{\\s*%\\s+"+k+"\\s+%\\s*}");
            result = result.replace(re, variables[k]);
        }

        return result;
    }
};
