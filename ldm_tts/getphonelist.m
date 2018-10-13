function phones = getphonelist(phoneset)
% Get phone list
%   input :
%         phoneset : currently valid phonesets are unilex and cmu. More
%         could be added

% author : Gagandeep Singh 2017

if strcmp(phoneset,'unilex')
    phones = {'@'
    'a'
    'aa'
    'ai'
    'b'
    'ch'
    'd'
    'dh'
    'e'
    'ei'
    'eir'
    'f'
    'g'
    'h'
    'i'
    'i@'
    'ii'
    'iy'
    'jh'
    'k'
    'l'
    'l!'
    'lw'
    'm'
    'm!'
    'n'
    'n!'
    'ng'
    'o'
    'oi'
    'oo'
    'ou'
    'ow'
    'p'
    'r'
    '@@r'
    's'
    'sh'
    't'
    'th'
    'u'
    'uh'
    'ur'
    'uu'
    'uw'
    'v'
    'w'
    'y'
    'z'
    'zh'
    'sil'
    'sp'};
elseif strcmp(phoneset,'cmu')
    phones = {'aa'
    'ae'
    'ah'
    'ao'
    'aw'
    'ax'
    'ay'
    'b'
    'b_cl'
    'ch'
    'ch_cl'
    'd'
    'd_cl'
    'dh'
    'eh'
    'er'
    'ey'
    'f'
    'g'
    'g_cl'
    'hh'
    'ih'
    'iy'
    'jh'
    'jh_cl'
    'k'
    'k_cl'
    'l'
    'm'
    'n'
    'ng'
    'ow'
    'oy'
    'p'
    'p_cl'
    'r'
    's'
    'sh'
    'sil'
    'sp'
    't'
    't_cl'
    'th'
    'uh'
    'uw'
    'v'
    'w'
    'y'
    'z'
    'zh'};
else
    error('Phoneset %s not valid. ')
end
end