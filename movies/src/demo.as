var TIMELINE = this;
var LABEL = "test 1";

this.VERSION = function()
{
   return LABEL;
};

this.createEmptyMovieClip("box", 0);
this.box.beginFill(0x2E86DE, 100);
this.box.moveTo(40, 40);
this.box.lineTo(440, 40);
this.box.lineTo(440, 140);
this.box.lineTo(40, 140);
this.box.lineTo(40, 40);
this.box.endFill();

var format = new TextFormat();
format.font = "$Font2";
format.size = 36;
format.color = 0xFFFFFF;

this.createTextField("label", 1, 60, 65, 800, 60);
this.label.embedFonts = true;
this.label.setNewTextFormat(format);
this.label.text = LABEL;
