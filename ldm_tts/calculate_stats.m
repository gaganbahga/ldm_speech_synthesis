% rough scripts for calculating stats of segments 

function stats = calculate_stats(segments)
    stats = {};
    tri_states = fieldnames(segments);
    for iTri = 1:length(tri_states)
        stats.(tri_states{iTri}).std = std((segments.(tri_states{iTri}).mgc)')';
        stats.(tri_states{iTri}).mean = mean(segments.(tri_states{iTri}).mgc,2);
    end     
end