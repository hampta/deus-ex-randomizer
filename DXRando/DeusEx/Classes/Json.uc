class Json extends Object transient;
// singleton class

//JSON parsing states
const KeyState = 1;
const ValState = 2;
const ArrayState = 3;
const ArrayDoneState = 4;

struct JsonElement
{
    var string key;
    var string value[5];
    var int valCount;
};

struct JsonMsg
{
    var JsonElement e[20];
    var int count;
};

var JsonMsg _data;

function _parse(string msg) {
    _data = ParseJson(msg);
}

static function Json parse(LevelInfo parent, string msg, optional Json o) {
    if(o == None)
        foreach parent.AllObjects(class'json', o)
            break;
    if(o == None)
        o = new(parent) class'json';
    o._parse(msg);
    return o;
}

function int count() {
    return _data.count;
}

function int max_count() {
    return ArrayCount(_data.e);
}

function int max_values() {
    return ArrayCount(_data.e[0].value);
}

function string at(int k, optional int i) {
    return _data.e[k].value[i];
}

function int find(string key) {
    local int i;
    local int j;

    for (i=0;i<_data.count;i++) {
        if (_data.e[i].key == key) {
            return i;
        }
    }

    // error!
    return -1;
}

function int get_vals(string key, optional out string vals[5]) {
    local int i;
    local int j;

    i = find(key);
    if(i == -1)
        return 0;

    for(j=0; j < ArrayCount(vals); j++)
        vals[j] = _data.e[i].value[j];
    return _data.e[i].valCount;
}

function int get_count(string key) {
    local int i;
    i = find(key);
    if(i == -1)
        return 0;
    return _data.e[i].valCount;
}

function string get(string key, optional int v) {
    local int i;
    i = find(key);
    if(i == -1)
        return "";
    return _data.e[i].value[v];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                             JSON STUFF                                                   ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


static function string StripQuotes (string msg) {
    if (Mid(msg,0,1)==Chr(34)) {
        if (Mid(msg,Len(Msg)-1,1)==Chr(34)) {
            return Mid(msg,1,Len(msg)-2);
        }
    }
    return msg;
}

static function string JsonStripSpaces(string msg) {
    local int i, a, length, lastCurly;
    local string c;
    local string buf;
    local bool inQuotes;

    inQuotes = False;
    msg = Mid(msg, InStr(msg, "{"));

    length = Len(msg);
    for (i = 0; i < length; i++) {
        c = Mid(msg,i,1); //Grab a single character
        a = Asc(c);

        if (!inQuotes && (a<33 || a>126)) {
            continue;  //Don't add whitespace or invisible characters to the buffer if we're outside quotes
        } else if (a==34) {// 34 is "
            inQuotes = !inQuotes;
        } else if (a==125) {// 125 is }
            lastCurly = Len(buf)+1;
        }

        buf = buf $ c;
    }

    buf = Mid(buf, 0, lastCurly);

    return buf;
}

//Returns the appropriate character for whatever is after
//the backslash, eg \c
static function string JsonGetEscapedChar(string c) {
    switch(c){
        case "b":
            return Chr(8); //Backspace
        case "f":
            return Chr(12); //Form feed
        case "n":
            return Chr(10); //New line
        case "r":
            return Chr(13); //Carriage return
        case "t":
            return Chr(9); //Tab
        case Chr(34): //Quotes
        case Chr(92): //Backslash
            return c;
        default:
            return "";
    }
}

static function bool _IsJson(string msg, int length) {
    // we've already run JsonStripSpaces
    if (Mid(msg, 0, 1) != "{") {
        log("Json._IsJson missing opening curly brace: "$msg);
        return false;
    }
    if (Mid(msg, length-1, 1) != "}") {
        log("JSon._IsJson missing closing curly brace: "$msg);
        return false;
    }

    return true;
}

function JsonMsg ParseJson(string msg) {
    local int i, length;
    local string c;
    local string buf;

    local int parsestate;
    local bool inquotes;
    local bool escape;
    local int inBraces;

    local JsonMsg j;

    local bool elemDone;

    elemDone = False;

    parsestate = KeyState;
    inquotes = False;
    escape = False;
    buf = "";

    //Strip any spaces outside of strings to standardize the input a bit
    msg = JsonStripSpaces(msg);
    length = Len(msg);
    if( ! _IsJson(msg, length) ) {
        log(Self$".ParseJson IsJson failed! " $ msg);
        return j;
    }

    // we set the length to -1 to end the loop
    for (i = 0; i < length; i++) {
        c = Mid(msg,i,1); //Grab a single character

        if (!inQuotes) {
            switch (c) {
                case ":":
                case ",":
                  //Wrap up the current string that was being handled
                  //PlayerMessage(buf);
                  if (parsestate == KeyState) {
                      j.e[j.count].key = StripQuotes(buf);
                      parsestate = ValState;
                  } else if (parsestate == ValState) {
                      //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                      j.e[j.count].value[j.e[j.count].valCount]=buf;
                      j.e[j.count].valCount++;
                      parsestate = KeyState;
                      elemDone = True;
                  } else if (parsestate == ArrayState) {
                      // TODO: arrays of objects
                      if (c != ":") {
                        //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                        j.e[j.count].value[j.e[j.count].valCount]=buf;
                        j.e[j.count].valCount++;
                      }
                  } else if (parsestate == ArrayDoneState){
                      parseState = KeyState;
                  }
                    buf = "";
                    break; // break for colon and comma

                case "{":
                    inBraces++;
                    buf = "";
                    break;

                case "}":
                    //PlayerMessage(buf);
                    inBraces--;
                    if (inBraces == 0 && parsestate == ValState) {
                      //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                      j.e[j.count].value[j.e[j.count].valCount]=buf;
                      j.e[j.count].valCount++;
                      parsestate = KeyState;
                      elemDone = True;
                    }
                    if (parsestate == ArrayState) {
                        // TODO: arrays of objects
                    }
                    else if(inBraces > 0) {
                        // TODO: sub objects
                    }
                    else {
                        // last loop iteration
                        length = -1;
                    }
                    break;

                case "]":
                    if (parsestate == ArrayState) {
                        //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                        j.e[j.count].value[j.e[j.count].valCount]=buf;
                        j.e[j.count].valCount++;
                        elemDone = True;
                        parsestate = ArrayDoneState;
                    } else {
                        buf = buf $ c;
                    }
                    break;
                case "[":
                    if (parsestate == ValState){
                        parsestate = ArrayState;
                    } else {
                        buf = buf $ c;
                    }
                    break;
                case Chr(34): //Quotes
                    inQuotes = !inQuotes;
                    break;
                default:
                    //Build up the buffer
                    buf = buf $ c;
                    break;

            }
        } else {
            switch(c) {
                case Chr(34): //Quotes
                    if (escape) {
                        escape = False;
                        buf = buf $ JsonGetEscapedChar(c);
                    } else {
                        inQuotes = !inQuotes;
                    }
                    break;
                case Chr(92): //Backslash, escape character time
                    if (escape) {
                        //If there has already been one, then we need to turn it into the right char
                        escape = False;
                        buf = buf $ JsonGetEscapedChar(c);
                    } else {
                        escape = True;
                    }
                    break;
                default:
                    //Build up the buffer
                    if (escape) {
                        escape = False;
                        buf = buf $ JsonGetEscapedChar(c);
                    } else {
                        buf = buf $ c;
                    }
                    break;
            }
        }

        if (elemDone) {
          //PlayerMessage("Key: "$j.e[j.count].key$ "   Val: "$j.e[j.count].value[0]);
          j.count++;
          elemDone = False;
        }
    }

    return j;
}