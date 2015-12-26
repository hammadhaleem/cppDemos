% % % % NOTES % % % %
% max(resultArray(:,1))-min(resultArray(:,1)) = 3023171.
% to reduce complications, R0 for each community for each content is always
% recalculated, and R0 is generation-weighted to consider dynamics.
%
% % % % % % % % % % % 

tic;

commNum = max(arr);
target1 = 4000; %2680
target = 4000; %2680

[a1,b1] = hist(resultArray(:,3),unique(resultArray(:,3)));
%contentList = b1(a1>=target1);
contents = b1(a1>=target1);
%contents = 714;
%beginning = min(resultArray(:,1)) + 2200000;
%interval = 350;
t_ro = zeros(length(contents),19);
errorTotal=[];

actual_timing = zeros(size(contents,1),1);
for i= 1 : size(actual_timing,1)
    temp = sort(resultArray(resultArray(:,3)==contents(i),1));
    actual_timing(i) = temp(target);
end

for g=1:size(contents,1)
    contentList = contents(g);
    beginning = min(resultArray(resultArray(:,3)==contentList,1));
    interval = ceil( (actual_timing(g) - beginning) / 20 );

% For increasing fraction of data:
% 1. get new users and place them in communities
% For each content in contentList:
% 2. get content's associated communities - Ro, current & new infections
% 3. prediction for each community
% 4. content virality & content's virality timing

%timing=zeros(size(contentList,1),ceil((max(resultArray(:,1))-beginning-interval)/interval)); 
timing = zeros(1,19);
error=[];
%newInf = ones(size(contentList,1),(size(arr,1))); %%% CONTENTLIST >1 ???
current = ones(1,size(unique(arr),1));

sorted_time = sort(resultArray(resultArray(:,3)==contentList,1));
for frac = 0.05:0.05:0.95
    t = sorted_time(round(frac*target));
    
    % for densification vs. R_0 %
    t_ro(g,round(frac/0.05)) = t;
    % % % % % % % % % % % % % % %
    
%for t = beginning + interval : interval : beginning + 10*interval
%for t = beginning + interval : interval : max(resultArray(:,1))

% %% 1. Get new users and place them in communities
% list = resultArray(resultArray(:,1)<=t & resultArray(:,1)>=t-interval , [2 5]);
% list = resultArray(resultArray(:,1)<=t, [2 5]);
% 
% 
% [j,k]=ismember(list(:,1),users);
% [l,m]=ismember(list(:,2),users);
% 
% newUsers = list((~j & l),1);
% newArr = arr(m(~j & l));
% [~,pos] = ismember(newUsers,newUsers);
% pos = unique(pos);
% newUsers = newUsers(pos);
% newArr = newArr(pos);
% users = cat(1, users, newUsers);
% arr = cat(1,arr,newArr);
% 
% newUsers = list((~l & j),2);
% newArr = arr(k(~l & j));
% [~,pos] = ismember(newUsers,newUsers);
% pos = unique(pos);
% newUsers = newUsers(pos);
% newArr = newArr(pos);
% users = cat(1, users, newUsers);
% arr = cat(1,arr,newArr);
% 
% % insert lone poster-parent pairs
% newUsers = list((~l & ~j),[1 2]); %temp2 = unique(list((~l & ~j),2));
% newUsers = newUsers'; newUsers = newUsers(1:end);
% [~,temp] = ismember(newUsers, list);
% newArr = ceil(temp./2);
% [~,pos] = ismember(unique(newUsers),newUsers);
% 
% newUsers = newUsers(pos)';
% newArr = newArr(pos)' + repmat(commNum,size(pos,2),1);
% users = cat(1, users, newUsers);
% arr = cat(1, arr, newArr);
% commNum = max(arr);
% 
% [j,k]=ismember(list(:,1),users);
% [l,m]=ismember(list(:,2),users);
% 
% newUsers = list((~j & l),1);
% newArr = arr(m(~j & l));
% [~,pos] = ismember(newUsers,newUsers);
% pos = unique(pos);
% newUsers = newUsers(pos);
% newArr = newArr(pos);
% users = cat(1, users, newUsers);
% arr = cat(1,arr,newArr);
% 
% % newUsers = list((~l & ~j),1);
% % newArr = repmat(commNum,size(newUsers,1),1) + cumsum(ones(size(newUsers,1),1));
% % [~,pos] = ismember(newUsers,newUsers);
% % pos = unique(pos);
% % newUsers = newUsers(pos);
% % newArr = newArr(pos);
% 
% % newUsers = unique(list(~j & ~l));
% % newArr = repmat(commNum,size(newUsers,1),1);
% % [~,pos] = ismember(newUsers,newUsers);
% % pos = unique(pos);
% % newUsers = newUsers(pos);
% % newArr = newArr(pos);
% % commNum = commNum+1;
% % users = cat(1, users, newUsers);
% % arr = cat(1, arr, newArr);
% 

%% 2. Get content's associated communities - Ro, current & new infections
for i = 1:size(contentList,1)
    list = resultArray(resultArray(:,1)<=t & resultArray(:,3)==contentList(i), [2 7 1]);
    % newInfections = list(:,3) >= t-interval; % CHECK!!!
    % % interval ~= interval between fractions --> needs to be changed % %
    if frac~=0.05
        newInfections = list(:,3) >= sorted_time(round((frac-0.05)*target));
    else newInfections = list(:,3) >= sorted_time(round(frac*target));
    end
    
    if isempty(list)
        continue;
    end
    % link posters & their generations to communities
    [~,comm] = ismember(list(:,1),users);
    %%% TEMP FIX %%%
    comm(comm==0) = 1;
    %%%%%%%%%%%%%%%%
    comm = arr(comm);
    communities = unique(comm);
    newly = zeros(size(communities,1),1);    newInf = zeros(size(communities,1),1);
    R0 = ones(size(contentList,1),size(communities,1),1);          limit = zeros(size(communities,1),1);
    for h = 1:size(communities,1)
        temp = histc(list(comm==communities(h),2),1:15);    %
        maxGen = find(temp>0,1,'last');                     %
        temp = temp(2:end) ./ temp(1:end-1);                %
        %%%% fix isnan and isinf
        temp(isinf(temp)) = 1;                              %
        temp(isnan(temp)) = 1;                              %
        %R0(h) = (1 + sum(temp(1:maxGen-1))) / maxGen;      %
        
        %newly(h) = sum(comm==communities(h) & newInfections);
        newly(h) = sum(comm==communities(h));
        %temp = (t-beginning)/interval; UNUSED for now
        if frac == 0.05
            R0(i,h) = 1;
            newInf(h) = newly(h);
        else
            if current(h) ~= 0
            %R0(i,h) = newly(h) / newInf(i,h);
                %R0(i,h) = (R0(i,h) * (temp-1) + newly(h) / newInf(i,h)) / temp;
                R0(i,h) = newly(h) / current(h); 
            %else R0(i,h) = R0(i,h) * (temp-1) / temp;
            %else R0(i,h) = (R0(i,h) * (temp-1) + 1) / temp;
            end
        end
        if newly(h)>=current(h)
            newInf(h) = newly(h)-current(h);
        end
        current(h) = sum(comm==communities(h));
                
%         newInf = list(:,3) >= t-2*interval;
%         newInf = sum(comm==communities(h) & newInf);
%         R0(h) = newly(h) / newInf;
        
        limit(h) = sum(arr==communities(h));
        
%         cascUsers = list(comm==communities(h),1);
%         cascades = unique(resultArray(resultArray(:,1)<=t & resultArray(:,3)==contentList(i) & ismember(resultArray(:,2),cascUsers),4));
%         duration = zeros(size(cascades,1),1);
%         for f=1:size(cascades,1)
%            times = resultArray(resultArray(:,3)==contentList(i) & ismember(resultArray(:,2),cascUsers) & resultArray(:,4) == cascades(f) , 1);
%            times = times - min(times);
%            gt = histc( resultArray(resultArray(:,3)==contentList(i) & ismember(resultArray(:,2),cascUsers) & resultArray(:,4) == cascades(f) ,7), 1:15);
%            err = zeros(10,15);
%            for mult = 0.1:0.1:1
%                err(round(mult/0.1),:) = histc(times,[interval*mult:interval*mult:interval*15*mult]);
%                err(round(mult/0.1),:) = abs(gt - err(mult/0.1));
%            end
%            err = sum(err,2);
%            duration(f) = interval * 0.1 * find(err==min(err),1);
%         end
        
        
    end
    
        % for densification vs. R_0 %
        ro(g,round(frac/0.05)) = sum(newly(newly~=1));
        % % % % % % % % % % % % % % %
    
%% 3. Prediction for each community    
    
    R0(i,11:end) = 1;
    prediction = repmat(newInf,1,50) .* repmat(R0(i,:)',1,50).^repmat([1:50],h,1);
    %prediction = repmat(newInf,1,50) .* repmat(R0(i,:)',1,50).^ repmat([0.96:-0.04:-1],h,1);
    prediction = cumsum(prediction,2) + repmat(newly,1,50);
    temp = repmat(limit,1,50);
    prediction(prediction >= repmat(limit,1,50)) = temp(prediction >= repmat(limit,1,50));
    
%% 4. Content virality & content's virality timing    
    virality = sum(prediction,1);
    if isempty( find(virality>=target,1) )
         %timing(i,(t-beginning)/interval) = 0;
         timing(i,round(frac/0.05)) = 0;
    else
    %timing(i,(t-beginning)/interval) = t + find(virality>=target,1) * interval - beginning; %%% INCOMPLETE?
    %timing(i,round(frac/0.1)) = t + find(virality>=target,1) * interval - beginning; %%% INCOMPLETE?
    if frac~=0.05
        timing(i,round(frac/0.05)) = t + find(virality>=target,1) * (t - sorted_time(round((frac-0.05)*target))) - beginning;
    else timing(i,round(frac/0.05)) = t + find(virality>=target,1) * (t - sorted_time(1)) - beginning;
    end
    %timing(i,round(frac/0.05)) = t + find(virality>=target,1) * interval - beginning;
    %overshoot(g,round(frac/0.05)) = timing(i,round(frac/0.05)) < actual_timing(g);
    end

%     R0 = histc(list(:,2),1:15);
%     R0 = R0(2:end) ./ R0(1:end-1);
%     maxGen = max(list(:,2));
%     R0 = (1 + sum(R0(1:maxGen-1))) / maxGen;
end
  if frac==0.4
     virc4=virality;
  else if frac==0.8
          virc8=virality;
      end
  end
end
%actual_timing = zeros(i,1);
% for i= 1 : size(actual_timing,1)
%     temp = resultArray(resultArray(:,3)==contentList(i),1);
%     actual_timing(i) = temp(target) - beginning;
% end

error = abs( repmat(actual_timing(g)-beginning,1,size(timing,2)) - timing ) ./ repmat(actual_timing(g)-beginning,1,size(timing,2));
error(error>1) = 1;
errorTotal(g,:) = error;

end

% for densification vs. R_0 %
% for i=1:length(ro)
%     ro(i,:) = [1 ro(i,2:end)./ro(i,1:end-1)];
% end
% ro_avg = sum(ro,1)./length(ro);
% % % % % % % % % % % % % % %











% % for each content, can we get posters and their associated communities?
% list = resultArray(resultArray(:,3)==55,[2 5]);
% [j,k]=ismember((resultArray(resultArray(:,3)==55,2)),users); % 55-> contentList(i)
% [l,m]=ismember((resultArray(resultArray(:,3)==55,5)),users);
% 
% newUsers = list((~j & xor(j,l)),1);
% newArr = arr(m(~j & xor(j,l)));
% users = cat(1, users, newUsers);
% arr = cat(1,arr,newArr);
% 
% newUsers = list((~l & xor(j,l)),2);
% newArr = arr(k(~l & xor(j,l)));
% users = cat(1, users, newUsers);
% arr = cat(1,arr,newArr);
% 
% % insert lone poster-parent pairs
% newUsers = list(~j & ~l);
% newArr = repmat(commNum,size(newUsers,1),1);
% users = cat(1, users, newUsers);
% arr = cat(1, arr, newArr);
% 
% %a1 = zeros(size(j,1),1); a1(l) = m(l); a1(j) = k(j);

toc;

