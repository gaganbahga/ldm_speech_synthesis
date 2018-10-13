% rough script to normalize the data in tree
segments = fieldnames(tree);
normParams = struct();
for k = 1:length(segments)
    
    segment = segments{k};
    normParams.(segment) = struct();
    phones = fieldnames(tree.(segment));
    
    for j = 1:length(phones)
        phone = phones{j};
        normParams.(segment).(phone) = struct();
        data = [];
        for i = 1:length(tree.(segment).(phone).data)
            data = [data tree.(segment).(phone).data(i).mgc];
        end
        mu = mean(data,2);
        sigma = var(data,0,2);
        normParams.(segment).(phone).mu = mu;
        normParams.(segment).(phone).sigma = sigma;
        for i = 1:length(tree.(segment).(phone).data)
            data = tree.(segment).(phone).data(i).mgc;
            data = (data-mu)./sqrt(sigma);
            tree.(segment).(phone).data(i).mgc = data;
        end
    end
    
end