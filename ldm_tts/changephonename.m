function phone = changephonename(phone)
% Change phone name
%   Change the phone name so to remove special characters to make valid
%   struct fields
%   inputs :
%          phone name
%   outputs:
%          changed phone name

% author : Gagandeep Singh 2017

phone = regexprep(phone,'@','a1');
phone = regexprep(phone,'!','sc');
end