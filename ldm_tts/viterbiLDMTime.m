% rough script to calculate time
maxSegments = 100;
frame_shift = 50000;
load('label_data_states.mat')
load('nick_clustered_model.mat')
load('mgc_data_nick.mat')

pattern = strcat('^([a-z_]+)_[1-3]_[0-9]+$');
phones = get_phone_list();
segmentEntry = struct('mgc',[],'modelId',{});
timeTaken = zeros(7,4);
parfor l = 1:7
shortSegments = struct('phone',phones,'segments',segmentEntry);
maxSegments = l*5+1;
for fileId = 1:length(label_data_states)
    for segmentId = 1:3:length(label_data_states(fileId).tri_phone)
        %disp(label_data(file_id).tri_phone{label_id})
        %disp( patterns{pat_id} )
        state1 = label_data_states(fileId).tri_phone{segmentId};
        phone = regexp(state1,pattern,'tokens');
        beginId = label_data_states(fileId).begin(segmentId)/frame_shift + 1;
        endId = label_data_states(fileId).ending(segmentId+2)/frame_shift ;
        nSegments = endId-beginId+1;
        if nSegments > maxSegments || nSegments < maxSegments-5;
            continue;
        end
        
        phoneId = find(strcmp({shortSegments.phone},phone{1,1}));
        shortSegments(phoneId).segments(end+1).mgc = mgc_data{fileId}(:,beginId:endId);
        state2 = label_data_states(fileId).tri_phone{segmentId+1};
        state3 = label_data_states(fileId).tri_phone{segmentId+2};
        modelId1 = find(strcmp({model.state},state1));
        modelId2 = find(strcmp({model.state},state2));
        modelId3 = find(strcmp({model.state},state3));
        shortSegments(phoneId).segments(end).modelId = [modelId1,modelId2,modelId3];
        
    end
end
variation = struct('phone',{},'avgDist3',[],'avgLogLDif3',[],'avgDist4',[],...
    'avgLogLDif4',[],'avgDist5',[],'avgLogLDif5',[],'nSegments',[]);
time = [];
ind = 0;
for i = 1:length(shortSegments)
    fprintf('phone id:%d\n',i)
    phoneSegment = shortSegments(i);
    variation(i).phone = phoneSegment.phone;
    dist = zeros(length(phoneSegment.segments),3);
    logL = dist;
    j = 0;
    for segment = phoneSegment.segments
        ind = ind+1;
        disp(ind)
        modelSeg = struct('g1',{},'Q1',{},'F',{},'g',{},'Q',{},'H',{},'mu',{},'R',{},'state',{});
        modelSeg(1) = model(segment.modelId(1));
        modelSeg(2) = model(segment.modelId(2));
        modelSeg(3) = model(segment.modelId(3));
        %disp('new sequence');
        subVitSeq = zeros(3,size(segment.mgc,2));
        subVitLogL = zeros(3,1);
        for depth = 3:5
            tic
            [subVitSeq(depth-2,:), subVitLogL(depth-2)] = viterbildm(segment.mgc,modelSeg,3,depth);
            time(ind,depth-2) = toc;
        end
        tic
        [bestSeq, bestLogL] = bestSequence(segment.mgc,modelSeg,3);
        time(ind,4) = toc;
        if ind == 20
            break
        end
        
        j = j+1;
        for k = 1:3
            dist(j,k) = sum(abs(subVitSeq(k,:)-bestSeq'));
            logL(j,k) = bestLogL - subVitLogL(k);
        end
    end
    if ind >= 20
        break
    end
    variation(i).avgDist3 = mean(dist(:,1));
    variation(i).avgLogLDif3 = mean(logL(:,1));
    variation(i).avgDist4 = mean(dist(:,2));
    variation(i).avgLogLDif4 = mean(logL(:,2));
    variation(i).avgDist5 = mean(dist(:,3));
    variation(i).avgLogLDif5 = mean(logL(:,3));
    
    variation(i).nSegments = length(phoneSegment.segments);
end
timeTaken(l,:) = mean(time,1);
% save('variations.mat','variation')
end
