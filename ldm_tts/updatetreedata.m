% rough script used to update data in the tree when the labeldata changed
% without building a new tree

segments = fieldnames(tree);

for k = 1:length(segments)
    segment = segments{k};
    phones = fieldnames(tree.(segment));
    for j = 1:length(phones)
        phone = phones{j};
        for i = 1:length(tree.(segment).(phone).data)
            fileId = tree.(segment).(phone).data(i).file_id;
            labelId = tree.(segment).(phone).data(i).label_id;
            begin = labelData(fileId).begin(labelId);
            beginId = 1 + begin/50000;
            ending = labelData(fileId).ending(labelId);
            endId = ending/50000;
            tree.(segment).(phone).data(i).mgc = mgcData{fileId}(:,beginId:endId)*10;
        end
    end
    
end