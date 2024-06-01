local returnKeys = {}

local _keys = {
	[32]  = 'space';
	[39]  = 'apostrophe';
	[44]  = 'comma';
	[45]  = 'minus';
	[46]  = 'period';
	[47]  = 'slash';
	[48]  = 'zero';
	[49]  = 'one';
	[50]  = 'two';
	[51]  = 'three';
	[52]  = 'four';
	[53]  = 'five';
	[54]  = 'six';
	[55]  = 'seven';
	[56]  = 'eight';
	[57]  = 'nine';
	[59]  = 'semicolon';
	[61]  = 'equals';
	[65]  = 'a';
	[66]  = 'b';
	[67]  = 'c';
	[68]  = 'd';
	[69]  = 'e';
	[70]  = 'f';
	[71]  = 'g';
	[72]  = 'h';
	[73]  = 'i';
	[74]  = 'j';
	[75]  = 'k';
	[76]  = 'l';
	[77]  = 'm';
	[78]  = 'n';
	[79]  = 'o';
	[80]  = 'p';
	[81]  = 'q';
	[82]  = 'r';
	[83]  = 's';
	[84]  = 't';
	[85]  = 'u';
	[86]  = 'v';
	[87]  = 'w';
	[88]  = 'x';
	[89]  = 'y';
	[90]  = 'z';
	[91]  = 'leftBracket';
	[92]  = 'backslash';
	[93]  = 'rightBracket';
	[96]  = 'grave';
	[161] = 'world1';
	[162] = 'world2';
	[257] = 'enter';
	[258] = 'tab';
	[259] = 'backspace';
	[260] = 'insert';
	[261] = 'delete';
	[262] = 'right';
	[263] = 'left';
	[264] = 'down';
	[265] = 'up';
	[266] = 'pageUp';
	[267] = 'pageDown';
	[268] = 'home';
	[269] = 'end';
	[280] = 'capsLock';
	[281] = 'scrollLock';
	[282] = 'numLock';
	[283] = 'printScreen';
	[284] = 'pause';
	[290] = 'f1';
	[291] = 'f2';
	[292] = 'f3';
	[293] = 'f4';
	[294] = 'f5';
	[295] = 'f6';
	[296] = 'f7';
	[297] = 'f8';
	[298] = 'f9';
	[299] = 'f10';
	[300] = 'f11';
	[301] = 'f12';
	[302] = 'f13';
	[303] = 'f14';
	[304] = 'f15';
	[305] = 'f16';
	[306] = 'f17';
	[307] = 'f18';
	[308] = 'f19';
	[309] = 'f20';
	[310] = 'f21';
	[311] = 'f22';
	[312] = 'f23';
	[313] = 'f24';
	[314] = 'f25';
	[320] = 'numPad0';
	[321] = 'numPad1';
	[322] = 'numPad2';
	[323] = 'numPad3';
	[324] = 'numPad4';
	[325] = 'numPad5';
	[326] = 'numPad6';
	[327] = 'numPad7';
	[328] = 'numPad8';
	[329] = 'numPad9';
	[330] = 'numPadDecimal';
	[331] = 'numPadDivide';
	[332] = 'numPadMultiply';
	[333] = 'numPadSubtract';
	[334] = 'numPadAdd';
	[335] = 'numPadEnter';
	[336] = 'numPadEqual';
	[340] = 'leftShift';
	[341] = 'leftCtrl';
	[342] = 'leftAlt';
	[343] = 'leftSuper';
	[344] = 'rightShift';
	[345] = 'rightCtrl';
	[346] = 'rightAlt';
	[347] = 'rightSuper';
	[348] = 'menu';
}

local keys = _ENV
for nKey, sKey in pairs(_keys) do
    keys[sKey] = nKey
end

function getName(_nKey)
    expect(1, _nKey, "number")
    return _keys[_nKey]
end

for k, v in pairs(_keys) do
    returnKeys[v] = k
end

returnKeys["return"] = returnKeys.enter

return returnKeys
