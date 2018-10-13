function quests = readquestions(questionFilePath)
% Read Questions
%   read the questions from the file path and store in a struct
%   inputs :
%          questionFilePath
%   outputs:
%          quests : struct array with fields question (of classification),
%          patterns which is a cell array of all matching patterns

% author : Gagandeep Singh 2017

file = fopen(questionFilePath);
quests = struct('question', {}, 'patterns', {},'node_id',{});

QSPattern = 'QS[\s]+"([A-Za-z\-@0-9\!<^_\?\=\(\)]+)"[\s]+{([*a-z0-9@<>&$#\?\!\~\-\+\=\^\[\],|/_A-Z:]+)}';

line = fgetl(file);
qId = 0;
while ischar(line)
    quesEntry = regexp(line, QSPattern, 'tokens');
    
    
    if ~isempty(quesEntry)
        qId = qId+1;
        quests(qId).question = quesEntry{1}{1};
        pats = strsplit(quesEntry{1}{2},',');
        for patId = 1:length(pats)
            pats{patId} = regexprep(pats{patId},'\\','\\\\');
            pats{patId} = regexprep(pats{patId},'\-','\\\-');
            pats{patId} = regexprep(pats{patId},'\?','\\\?');
            pats{patId} = regexprep(pats{patId},'\+','\\\+');
            pats{patId} = regexprep(pats{patId},'\|','\\\|');
            pats{patId} = regexprep(pats{patId},'*','.');
            pats{patId} = regexprep(pats{patId},'\!','\\\!');
            pats{patId} = regexprep(pats{patId},'\=','\\\=');
            pats{patId} = regexprep(pats{patId},'\^','\\\^');
            pats{patId} = regexprep(pats{patId},'\(','\\\(');
            pats{patId} = regexprep(pats{patId},'\)','\\\)');
            pats{patId} = regexprep(pats{patId},'\\\\d\\\+','\[0\-9\]\+');
            pats{patId} = regexprep(pats{patId},'\[3\\\-9\]','\[3\-9\]');
            pats{patId} = regexprep(pats{patId},'(^[a-z@\!1\\\^]+)\~','\^$1\\\~');
        end
        quests(qId).patterns = pats;
        quests(qId).node_id = '';
        
    end
    line = fgetl(file);
end
fclose(file);
end