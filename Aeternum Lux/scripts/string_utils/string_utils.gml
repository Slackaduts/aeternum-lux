/// @func   string_trim(str, trim)
///
/// @desc   Returns given string with whitespace stripped from its start
///         and end. Whitespace is defined as SPACE, LF, CR, HT, VT, FF.
///         A string of characters to be trimmed may be optionally supplied.
///
/// @param  {string}    str         string of text
/// @param  {string}    trim        characters to trim, optional
///
/// @return {string}    trimmed string
///
/// GMLscripts.com/license

function string_trim(str, trim=" \n\r\t\v\f")
{
    var l = 1;
    while (string_pos(string_char_at(str, l), trim)) {
        l++;
    }
    var r = string_length(str);
    while (string_pos(string_char_at(str, r), trim)) {
        r--;
    }
    return string_copy(str, l, r - l + 1);
}