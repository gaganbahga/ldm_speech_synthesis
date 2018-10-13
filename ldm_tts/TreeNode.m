classdef TreeNode < handle
    properties
        node_id
        root_ind
        left_child
        right_child
    end
    methods
        function obj = TreeNode(node, lChild, rChild)
            if nargin == 1
                obj.node_id = node;
            elseif nargin == 3
                obj.node_id = node;
                obj.left_child = lChild;
                obj.right_child = rChild;
            end
        end
    end
end