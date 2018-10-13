classdef Node_ptr < handle
% Node pointer
%   node pointer used to cluster

% author : Gagandeep Singh 2017
properties
    node_id = {};
    quests = struct();
    leafNodes = struct('nodeId',{},'maxSplitLogL',[],'bestQues',[]);
end
end