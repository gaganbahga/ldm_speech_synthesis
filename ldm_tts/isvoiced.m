function isvoiced = isvoiced(phone)
% is voiced
%   check if phone is voiced
% Inputs:
%       phone 
% Outputs:
%       isvoiced

%   author : Gagandeep Singh 2017

    voicelessPhones = {'ch','f','h','k','p','s','sh','t','th','sil','sp'};
    isvoiced = ~sum(strcmp(voicelessPhones,phone));
end