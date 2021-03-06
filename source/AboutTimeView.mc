using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Math;

var locale = {};
var localeArrays = [];
var halfPast = true;
var updateCount = 0;
var fonts = new [5];
enum {
  tiny,
  small,
  medium,
  large,
  mega
}

class AboutTimeView extends WatchUi.WatchFace {

  function initialize() {
    WatchFace.initialize();
    Math.srand(System.getTimer());
  }

  function onLayout(dc) {
    readLocale();

    fonts[tiny] = WatchUi.loadResource(Rez.Fonts.id_font_tiny);
    fonts[small] = WatchUi.loadResource(Rez.Fonts.id_font_small);
    fonts[medium] = WatchUi.loadResource(Rez.Fonts.id_font_medium);
    fonts[large] = WatchUi.loadResource(Rez.Fonts.id_font_large);
    fonts[mega] = WatchUi.loadResource(Rez.Fonts.id_font_extralarge);

    // ugly hack: use system fonts for traditional Chinese
    if (locale[:hours][1].find("一") != null) {
      fonts[tiny] = Graphics.FONT_TINY;
      fonts[small] = Graphics.FONT_SMALL;
      fonts[medium] = Graphics.FONT_MEDIUM;
      fonts[large] = Graphics.FONT_SYSTEM_LARGE;
      fonts[mega] = fonts[large];
    }

  }

  function onUpdate(dc) {
    var width = dc.getWidth();
    var height = dc.getHeight();

    // updateCount += 1;
    // System.println("updating " + updateCount);

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
    dc.fillRectangle(0, 0, width, height);

    var heightUsed = drawTimeStrings(dc, System.getClockTime());
    var lineHeight = Graphics.getFontHeight(fonts[tiny])/2;

    // if (height - lineHeight > heightUsed) {
      var dataString = (System.getSystemStats().battery + 0.5).toNumber().toString() + " %";
      var color = Graphics.COLOR_DK_GRAY;
      drawString(dc, width/2, height-lineHeight, fonts[tiny], color, dataString);
    // }

  }

  function drawString(dc, x, y, font, color, string) {
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    dc.drawText(x, y, font, string, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawTimeStrings(dc, time) {

    var width = dc.getWidth();
    var height = dc.getHeight();

    var r = 0;

    var currentLocale = localize();
    var strings = prepareStrings(time, currentLocale);
    var top = strings[:top];
    var topFont = strings[:topFont];
    var middle = strings[:middle];
    var middleFont = strings[:middleFont];
    var bottom = strings[:bottom];
    var bottomFont = strings[:bottomFont];

    topFont = scaleFont(dc, topFont, top, :top);
    middleFont = scaleFont(dc, middleFont, middle, :middle);
    bottomFont = scaleFont(dc, bottomFont, bottom, :bottom);

    var topHeight = Graphics.getFontHeight(topFont)/1.2;
    var middleHeight = Graphics.getFontHeight(middleFont)/1.2;
    var bottomHeight = Graphics.getFontHeight(bottomFont)/1.2;
/*
    var topHeight = dc.getTextDimensions(top, topFont)[1]/1.2;
    var middleHeight = dc.getTextDimensions(middle, middleFont)[1]/1.2;
    var bottomHeight = dc.getTextDimensions(bottom, bottomFont)[1]/1.2;
*/
    var totalHeight = topHeight + middleHeight + bottomHeight;

    var x = width / 2;
    var topY = height / 2 - totalHeight / 2;
    var middleY = topY + topHeight / 2 + middleHeight / 2;
    var bottomY = middleY + middleHeight / 2 + bottomHeight / 2;
    var color = Graphics.COLOR_WHITE;

    drawString(dc, x, topY, topFont, color, top);
    drawString(dc, x, middleY, middleFont, color, middle);
    drawString(dc, x, bottomY, bottomFont, color, bottom);

/*
    dc.drawRectangle(0, topY - topHeight/2, width, topHeight);
    dc.drawRectangle(0, middleY - middleHeight/2, width, middleHeight);
    dc.drawRectangle(0, bottomY - bottomHeight/2, width, bottomHeight);
*/

    return bottomY + bottomHeight;

  }

  function scaleFont(dc, font, string, position) {
    var width = dc.getWidth();
    var device = System.getDeviceSettings();
    var shape = device.screenShape;
    if ((shape == System.SCREEN_SHAPE_ROUND) && (position != :middle)) {
      width = 0.9 * width;
    }
    var strWidth = dc.getTextWidthInPixels(string, font);
    var fontIndex = 2; // default for Epix
    if (fonts has :indexOf) {
      fontIndex = fonts.indexOf(font);
    }
    if ((width > 180) && (string.length() <= 9)) {
      if (fontIndex < (fonts.size() - 1)) {
        fontIndex += 1;
        font = fonts[fontIndex];
        strWidth = dc.getTextWidthInPixels(string, font);
      }
    }
    while ((strWidth > width) && (fontIndex >= 0)) {
      fontIndex -= 1;
      font = fonts[fontIndex];
      strWidth = dc.getTextWidthInPixels(string, font);
    }
    return font;
  }

  function readLocale() {
    locale = {
      "min0" => WatchUi.loadResource(Rez.Strings.min0),
      "min5" => WatchUi.loadResource(Rez.Strings.min5),
      "min10" => WatchUi.loadResource(Rez.Strings.min10),
      "min15" => WatchUi.loadResource(Rez.Strings.min15),
      "min20" => WatchUi.loadResource(Rez.Strings.min20),
      "min25" => WatchUi.loadResource(Rez.Strings.min25),
      "min30" => WatchUi.loadResource(Rez.Strings.min30),
      "min35" => WatchUi.loadResource(Rez.Strings.min35),
      "min40" => WatchUi.loadResource(Rez.Strings.min40),
      "min45" => WatchUi.loadResource(Rez.Strings.min45),
      "min50" => WatchUi.loadResource(Rez.Strings.min50),
      "min55" => WatchUi.loadResource(Rez.Strings.min55),
      :hours => [
        "",
        WatchUi.loadResource(Rez.Strings.hour1),
        WatchUi.loadResource(Rez.Strings.hour2),
        WatchUi.loadResource(Rez.Strings.hour3),
        WatchUi.loadResource(Rez.Strings.hour4),
        WatchUi.loadResource(Rez.Strings.hour5),
        WatchUi.loadResource(Rez.Strings.hour6),
        WatchUi.loadResource(Rez.Strings.hour7),
        WatchUi.loadResource(Rez.Strings.hour8),
        WatchUi.loadResource(Rez.Strings.hour9),
        WatchUi.loadResource(Rez.Strings.hour10),
        WatchUi.loadResource(Rez.Strings.hour11)
      ],
      :noon => WatchUi.loadResource(Rez.Strings.noon),
      :midnight => WatchUi.loadResource(Rez.Strings.midnight),
    };

    var keys = locale.keys();
    for (var i=0; i<keys.size(); i++) {
      var key = keys[i];
      locale[key] = strToArray(locale[key]);
      if (key != :hours && locale[key] instanceof Toybox.Lang.Array) {
        localeArrays.add({:name => key, :size => locale[key].size()});
      }
    }
    for (var i=0; i<locale[:hours].size(); i++) {
      locale[:hours][i] = strToArray(locale[:hours][i]);
      if (locale[:hours][i] instanceof Toybox.Lang.Array) {
        localeArrays.add({:name => i, :size => locale[:hours][i].size()});
      }
    }
  }

  function localize() {
    var currentLocale = cloneDictionary(locale);

    var i;
    for (i=0; i<localeArrays.size(); i++) {
      var it = localeArrays[i];
      var r = Math.rand() % it[:size];
      var key = it[:name];
      if (key instanceof Toybox.Lang.Number) {
        currentLocale[:hours][key] = locale[:hours][key][r];
      }
      else {
        currentLocale[key] = locale[key][r];
      }
    }
    return currentLocale;
  }

  function prepareStrings(time, currentLocale) {
    var top = "";
    var middle = "";
    var bottom = "";

    var fuzzyHour = time.hour;
    var fuzzyMinutes = ((time.min + 2) / 5) * 5;

    if (fuzzyMinutes > 55) {
      fuzzyMinutes = 0;
      fuzzyHour += 1;
      if (fuzzyHour > 23) {
        fuzzyHour = 0;
      }
    }
    var nextHour = fuzzyHour + 1;

    if (fuzzyHour == 0) {
      fuzzyHour = currentLocale[:midnight];
    } else if (fuzzyHour == 12) {
      fuzzyHour = currentLocale[:noon];
    } else {
      fuzzyHour = currentLocale[:hours][fuzzyHour % 12];
    }

    if (nextHour == 24) {
      nextHour = currentLocale[:midnight];
    } else if (nextHour == 12) {
      nextHour = currentLocale[:noon];
    } else {
      nextHour = currentLocale[:hours][nextHour % 12];
    }

    var lineString = locale["min" + fuzzyMinutes];
    var lines = new [3];
    var firstIndex = lineString.find("	");
    if (firstIndex == null) {
      lines[0] = "";
      lines[1] = lineString;
      lines[2] = "";
    }
    else {
      lines[0] = "";
      lines[1] = lineString.substring(0, firstIndex);
      lines[2] = lineString.substring(firstIndex + 1, lineString.length());
      var secondIndex = lines[2].find("	");
      if (secondIndex != null) {
        lines[0] = lines[1];
        lines[1] = lines[2].substring(0, secondIndex);
        lines[2] = lines[2].substring(secondIndex + 1, lines[2].length());
      }
    }

    var topFont = fonts[small];
    var middleFont = fonts[medium];
    var bottomFont = fonts[large];

    if (lines[0].find("$") != null) {
      topFont = fonts[large];
      middleFont = fonts[small];
      bottomFont = fonts[medium];
    }
    else if ((lines[1].find("$") != null) && (lines[2].length() > 0)) {
      topFont = fonts[small];
      middleFont = fonts[large];
      bottomFont = fonts[medium];
    }
    else if (lines[1].find("$") != null) {
      topFont = fonts[medium];
      middleFont = fonts[large];
      bottomFont = fonts[tiny];
    }
    if (lines[0].length() == 0) {
      topFont = fonts[tiny];
    }
    if (lines[2].length() == 0) {
      bottomFont = fonts[tiny];
    }

    var params = [fuzzyHour, nextHour];

    top = Lang.format(lines[0], params);
    middle = Lang.format(lines[1], params);
    bottom = Lang.format(lines[2], params);

    return {
      :bottom => bottom,
      :bottomFont => bottomFont,
      :middle => middle,
      :middleFont => middleFont,
      :top => top,
      :topFont => topFont
    };
  }

  function strToArray(str) {
    if (str instanceof Toybox.Lang.String != true) {
      return str;
    }
    if (str.find("|")) {
      var arr = [];
      while (str.find("|")) {
        var splitIndex = str.find("|");
        if (! arr has :add) { // epix doesn't support array.add()
          return str.substring(0, splitIndex);
        }
        arr.add(str.substring(0, splitIndex));
        str = str.substring(splitIndex+1, str.length());
      }
      arr.add(str);
      return arr;
    }
    return str;
  }

  function cloneDictionary(source) {
    var target = {};
    var keys = source.keys();
    for (var i=0; i<keys.size(); i++) {
      if (source[keys[i]] instanceof Toybox.Lang.Array) {
        target[keys[i]] = cloneArray(source[keys[i]]);
      }
      else {
        target[keys[i]] = source[keys[i]];
      }
    }
    return target;
  }

  function cloneArray(source) {
    var target = new [source.size()];
    for (var i=0; i<source.size(); i++) {
      target[i] = source[i];
    }
    return target;
  }

}

class AboutTimeDelegate extends WatchUi.WatchFaceDelegate {
  function onPowerBudgetExceeded(powerInfo) {
    System.println( "Average execution time: " + powerInfo.executionTimeAverage );
    System.println( "Allowed execution time: " + powerInfo.executionTimeLimit );
  }
}
