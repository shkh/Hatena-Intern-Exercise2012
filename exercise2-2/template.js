var Template = function(input) {
    this.source = input["source"];
};

Template.prototype = {
    render: function(variables) {
        var result = this.source;
        
        for (var key in variables){
            var val = variables[key];
            
            val = val.replace(/&/g, "&amp;");
            val = val.replace(/>/g, "&gt;");
            val = val.replace(/</g, "&lt;");
            val = val.replace(/"/g, "&quot;");

            key = key.replace(/\$/g, "\\$");

            var re = new RegExp("{\\s*%\\s+"+key+"\\s+%\\s*}", "g");
            result = result.replace(re, val);
        }

        //値がないものは空にする
        var re = /{\s*%\s+\w+\s+%\s*}/g;
        result = result.replace(re, "");

        return result;
    }
};
