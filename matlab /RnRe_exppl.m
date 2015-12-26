
tic;

target = 2000;
[a1,b1] = hist(resultArray(:,3),unique(resultArray(:,3)));
contents = b1(a1>=target);
% contents = 714;

actual_timing = zeros(size(contents,1),1);
for i= 1 : size(actual_timing,1)
    temp = sort(resultArray(resultArray(:,3)==contents(i),1));
    actual_timing(i) = temp(target);
end

% cascades_formed = unique(resultArray(~isnan(resultArray(:,4)),4));
% for i = 1:length(cascades_formed)
%     cascades_formed(i) = resultArray(find(resultArray(:,4)==cascades_formed(i),1),1);
% end

sample_times = zeros(length(contents),100);
total_casc = zeros(length(contents),99); new_casc = zeros(length(contents),99);
Re = zeros(length(contents),99); Rn = zeros(length(contents),99); 
mean_Re = zeros(length(contents),99); mean_Rn = zeros(length(contents),99); 
% delta_mean_logRe = zeros(length(contents),99); delta_mean_logRn = zeros(length(contents),99); 
% delta_logRe = zeros(length(contents),99); delta_logRn = zeros(length(contents),99); 
state_tab = ones(length(contents),198).*-1;
grad_Rn = zeros(length(contents),99); grad_Re = zeros(length(contents),99);
errorTotal = zeros(length(contents),99);
errorForward = zeros(length(contents),99);

rec_mean = zeros(length(contents),99);
rec_meanRn = zeros(length(contents),99); rec_meanRe = zeros(length(contents),99);

for i = 1:length(contents)
    sorted_time = sort(resultArray(resultArray(:,3)==contents(i),1));
    sample_times(i,:) = ([sorted_time(1) sorted_time(round([0.01:0.01:0.99] .* target))']);% - sorted_time(1));
    [~,pos] = ismember(unique(resultArray(resultArray(:,3)==contents(i),4)),unique(resultArray(:,4)));
    total_casc(i,:) = sum( repmat(cascades_formed(pos),1,99) <= repmat(sample_times(i,2:end),length(pos),1) ,1);
    new_casc(i,:) = total_casc(i,:) - [0 total_casc(i,1:end-1)];
    state = ones(1,2); % 1 = rise ; 0 = fall 
    surge_begin = [1 1]; fall_begin = [0 0];
    recent_mean = ones(1,2).*-10;
    pred_time = zeros(1,99);
    pred_nearFuture = zeros(1,99);
    
    for frac = 0.01:0.01:0.99
        Rn(i,round(frac/0.01)) = new_casc(i,round(frac/0.01)) / (sample_times(i,round(frac/0.01)+1) - sample_times(i,round(frac/0.01))) ;
        if  Rn(i,round(frac/0.01)) == 0
             Rn(i,round(frac/0.01)) = 0.0001;
        end        
        if frac == 0.01
            Re(i,round(frac/0.01)) = (round(frac*target) - new_casc(i,round(frac/0.01))) / (sample_times(i,2) - sample_times(i,1));
        else
            Re(i,round(frac/0.01)) = ( round(frac*target)-total_casc(i,round(frac/0.01)) - round((frac-0.01)*target)+total_casc(i,round((frac-0.01)/0.01)) ) / (sample_times(i,round(frac/0.01)+1) - sample_times(i,round(frac/0.01))) ;
        end
        % zero rate == -inf gradient %  % stagnant existing cascades ~ Re<0 %
        if  Re(i,round(frac/0.01)) <= 0
             Re(i,round(frac/0.01)) = 0.0001;
        end
        
        % trend %
%         mean_Rn(i,round(frac/0.01)) = sum(Rn(i,surge_begin:round(frac/0.01))) / round(frac/0.01);
%         mean_Re(i,round(frac/0.01)) = sum(Re(i,surge_begin:round(frac/0.01))) / round(frac/0.01);
        mean_Rn(i,round(frac/0.01)) = sum(Rn(i,surge_begin(1):round(frac/0.01))) / (round(frac/0.01)-surge_begin(1)+1);
        mean_Re(i,round(frac/0.01)) = sum(Re(i,surge_begin(2):round(frac/0.01))) / (round(frac/0.01)-surge_begin(2)+1);

         if frac>=0.05
             recent_mean(1) = sum(Rn(i,round(frac/0.01)-4:round(frac/0.01)))/5;
             recent_mean(2) = sum(Re(i,round(frac/0.01)-4:round(frac/0.01)))/5;
         else recent_mean(1) = mean_Rn(i,round(frac/0.01));
             recent_mean(2) = mean_Re(i,round(frac/0.01));
         end
         rec_meanRn(i,round(frac/0.01)) = recent_mean(1);
         rec_meanRe(i,round(frac/0.01)) = recent_mean(2);
         rec_mean(i,round(frac/0.01)) = recent_mean(1)+recent_mean(2);
%         if frac==0.01
%             if Rn(i,1)>0
%                 delta_logRn(i,round(frac/0.01)) = log(Rn(i,1));
%             end
%             if Re(i,1)>0
%                 delta_logRe(i,round(frac/0.01)) = log(Re(i,1));  
%             end
%         else
%             if Rn(i,round(frac/0.01)) < Rn(i,round((frac-0.01)/0.01))
%                 delta_logRn(i,round(frac/0.01)) = -5;
%             else
%                 delta_logRn(i,round(frac/0.01)) = log(Rn(i,round(frac/0.01))) - log(Rn(i,round((frac-0.01)/0.01)));
%             end
%             if Re(i,round(frac/0.01)) < Re(i,round((frac-0.01)/0.01))
%                 delta_logRe(i,round(frac/0.01)) = -5;
%             else
%                 delta_logRe(i,round(frac/0.01)) = log(Re(i,round(frac/0.01))) - log(Re(i,round((frac-0.01)/0.01)));
%             end
%         end
        
        if (state(1) == 1 && (recent_mean(1) < mean_Rn(i,round(frac/0.01))) && (Rn(i,round(frac/0.01)) < mean_Rn(i,round(frac/0.01))) )
            state(1) = 0;
            fall_begin(1) = find(rec_meanRn(i,:)==max(rec_meanRn(i,state_tab(i,1:99)==1 & [false(1,surge_begin(1)-1)  true(1,100-surge_begin(1))])) , 1,'last'); %find index for max(Rn) in the last rising mode
        else
            if (state(1) == 0 && (recent_mean(1) > mean_Rn(i,round(frac/0.01))) && (Rn(i,round(frac/0.01)) > mean_Rn(i,round(frac/0.01))) )
            state(1) = 1;
            surge_begin(1) = find( rec_meanRn(i,:)==min(rec_meanRn(i,state_tab(i,1:99)==0 & [false(1,fall_begin(1)-1)  true(1,100-fall_begin(1))])) , 1,'last'); %find index for min(Rn) in the last falling mode
            end  
        end
        state_tab(i,round(frac/0.01)) = state(1);
            
        if (state(2) == 1 && (recent_mean(2) < mean_Re(i,round(frac/0.01))) && (Re(i,round(frac/0.01)) < mean_Re(i,round(frac/0.01))) )
            state(2) = 0;
            fall_begin(2) = find(rec_meanRe(i,:)==max(rec_meanRe(i,state_tab(i,100:198)==1 & [false(1,surge_begin(2)-1)  true(1,100-surge_begin(2))])) , 1,'last'); %find index for max(Re) in the last rising mode
        else
            if (state(2) == 0 && (recent_mean(2) > mean_Re(i,round(frac/0.01))) && (Re(i,round(frac/0.01)) > mean_Re(i,round(frac/0.01))) )
            state(2) = 1;
            surge_begin(2) = find( rec_meanRe(i,:)==min(rec_meanRe(i,state_tab(i,100:198)==0 & [false(1,fall_begin(2)-1)  true(1,100-fall_begin(2))])) , 1,'last'); %find index for min(Rn) in the last falling mode
            end
        end
        state_tab(i,round(frac/0.01)+99) = state(2);
        
        % exponent %
        if state(1)==1
             temp = surge_begin(1);
        else temp = fall_begin(1);
        end
         %polyfit(log(sample_times(i,2:round(frac/0.01)+1)-sorted_time(1)), log(Rn(i,1:round(frac/0.01))) ,1);
%          polyfit(log(sample_times(i,temp+1:round(frac/0.01)+1)-sorted_time(1)), log(total_casc(i,temp:round(frac/0.01))) , 1);
%          polyfit(log(sample_times(i,temp+1:round(frac/0.01)+1)-sorted_time(1)), log(Rn(i,temp:round(frac/0.01))) , 1);
         polyfit(log(sample_times(i,temp+1:round(frac/0.01)+1)-sorted_time(1)), log(rec_meanRn(i,temp:round(frac/0.01))) , 1);
         grad_Rn(i,round(frac/0.01)) = ans(1);
         
        if state(2)==1
             temp1 = surge_begin(2);
        else temp1 = fall_begin(2);
        end
         %polyfit(log(sample_times(i,2:round(frac/0.01)+1)-sorted_time(1)), log(Re(i,1:round(frac/0.01))) ,1);
%          polyfit(log(sample_times(i,2:round(frac/0.01)+1)-sorted_time(1)), log(round([0.01:0.01:frac].*target)-total_casc(i,1:round(frac/0.01))) ,1);
%          polyfit(log(sample_times(i,temp1+1:round(frac/0.01)+1)-sorted_time(1)), log(Re(i,temp1:round(frac/0.01))) , 1);
         polyfit(log(sample_times(i,temp1+1:round(frac/0.01)+1)-sorted_time(1)), log(rec_meanRe(i,temp1:round(frac/0.01))) , 1);
         grad_Re(i,round(frac/0.01)) = ans(1);
        
%         Rn(i,Rn(i,:)<=0) = 0.001;       
%         mean_logRn(i,round(frac/0.01)) = sum(log(Rn(i,surge_begin:round(frac/0.01))))/round(frac/0.01);
%         recent_mean(1) = mean_logRn(i,round(frac/0.01));
%         Re(i,Re(i,:)<=0) = 0.001;
%         mean_logRe(i,round(frac/0.01)) = sum(log(Re(i,surge_begin:round(frac/0.01))))/round(frac/0.01);
%         recent_mean(2) = mean_logRe(i,round(frac/0.01));
        
        % % project forward in time % %
        if frac==0.01
            interval = sorted_time(round(frac*target)) - sorted_time(1);
%             delta_mean_logRn(i,round(frac/0.01)) = mean_logRn(i,round(frac/0.01));
%             delta_mean_logRe(i,round(frac/0.01)) = mean_logRe(i,round(frac/0.01));
%             delta_mean_Rn = exp(mean_logRn(i,round(frac/0.01)));
%             delta_mean_Re = exp(mean_logRe(i,round(frac/0.01)));            
        else
            interval = sorted_time(round(frac*target)) - sorted_time(round((frac-0.01)*target));
%             delta_mean_logRn(i,round(frac/0.01)) = mean_logRn(i,round(frac/0.01))-mean_logRn(i,round((frac-0.01)/0.01));
%             delta_mean_logRe(i,round(frac/0.01)) = mean_logRe(i,round(frac/0.01))-mean_logRe(i,round((frac-0.01)/0.01));
%             delta_mean_Rn = exp(mean_logRn(i,round(frac/0.01))) - exp(mean_logRn(i,round(frac/0.01-1)));
%             delta_mean_Re = exp(mean_logRe(i,round(frac/0.01))) - exp(mean_logRe(i,round(frac/0.01-1)));            
        end
        
        % Rn rise&fall mode %
        if state(1) == 1
            % cal. projected mean ; determine mode transition
%            pred_Rn = Rn(i,round(frac/0.01)) + exp(grad_Rn(i,round(frac/0.01)) - frac*(log(Rn(i,round(frac/0.01))/Rn(i,1))).*[1:200]);
%             pred_Rn = Rn(i,round(frac/0.01)) + exp(grad_Rn(i,round(frac/0.01)) - frac*(log(Rn(i,round(frac/0.01))/recent_mean(1))).*[1:200]);
            pred_Rn = exp(grad_Rn(i,round(frac/0.01)) - frac*(log(recent_mean(1)/Rn(i,1))).*[1:200]);
           proj_meanRn = (mean_Rn(i,round(frac/0.01))*round(frac/0.01) + cumsum(pred_Rn)) ./ (round(frac/0.01)+[1:200]);
           temp = find(max(pred_Rn)); temp1 = find(pred_Rn<proj_meanRn,1);
           polyfit([0:(temp1-temp)].*interval, log(pred_Rn(temp:temp1)) ,1);
           pred_Rn(temp1+1:end) = exp(log(pred_Rn(temp1)) + ans(1).*[1:(200-temp1)]);
        else
%            polyfit(sample_times(i,fall_begin(1)+1:round(frac/0.01)+1)-sorted_time(1), log(Rn(i,fall_begin(1):round(frac/0.01))) ,1);
           polyfit(sample_times(i,fall_begin(1)+1:round(frac/0.01)+1)-sorted_time(1), Rn(i,fall_begin(1):round(frac/0.01)) ,1);
%            pred_Rn = exp(log(Rn(i,round(frac/0.01))) + ans(1).*[1:200]);
           pred_Rn = exp(log(Rn(i,round(frac/0.01)))) + ans(1).*[1:200];
        end
        
        % Re rise&fall mode %        
        if state(2) == 1
%            pred_Re = Re(i,round(frac/0.01)) + exp(grad_Re(i,round(frac/0.01)) - frac*(log(Re(i,round(frac/0.01))/Re(i,1))).*[1:200]);
%            pred_Re = Re(i,round(frac/0.01)) + exp(grad_Re(i,round(frac/0.01)) - frac*(log(Re(i,round(frac/0.01))/recent_mean(2))).*[1:200]);           
            pred_Re = exp(grad_Re(i,round(frac/0.01)) - frac*(log(recent_mean(2)/Re(i,1))).*[1:200]);
           proj_meanRe = (mean_Re(i,round(frac/0.01))*round(frac/0.01) + cumsum(pred_Re)) ./ (round(frac/0.01)+[1:200]);            
           temp = find(max(pred_Re)); temp1 = find(pred_Re<proj_meanRe,1);
           polyfit([0:(temp1-temp)].*interval, log(pred_Re(temp:temp1)) ,1);            
           pred_Re(temp1+1:end) = exp(log(pred_Re(temp1)) + ans(1).*[1:(200-temp1)]);
        else
%            polyfit(sample_times(i,fall_begin(2)+1:round(frac/0.01)+1)-sorted_time(1), log(Re(i,fall_begin(2):round(frac/0.01))) ,1);
           polyfit(sample_times(i,fall_begin(2)+1:round(frac/0.01)+1)-sorted_time(1), Re(i,fall_begin(2):round(frac/0.01)) ,1);
%            pred_Re = exp(log(Re(i,round(frac/0.01))) + ans(1).*[1:200]);
           pred_Re = exp(log(Re(i,round(frac/0.01)))) + ans(1).*[1:200];
        end
            
            
            
            % calc. projection
             % pred = round(frac*target) + cumsum(pred .* interval);
        pred = cumsum(pred_Rn + pred_Re);
        pred = pred.*interval;
        if ~isempty(find(pred>=target-round(frac*target),1))
            pred_time(round(frac/0.01)) = sorted_time(round(frac*target)) + find(pred>=target-round(frac*target),1)*interval;
        end
        
        if frac>=0.95
            nearFuture_target = target;
        else
            nearFuture_target = round((frac+0.1)*target);
        end
        if ~isempty(find(pred>=nearFuture_target-round(frac*target),1))        
            pred_nearFuture(round(frac/0.01)) = sorted_time(round(frac*target)) + find(pred>=nearFuture_target-round(frac*target),1)*interval;
        end
        % % % % % % %


            
            
%             pred1 = delta_mean_logRn(i,round(frac/0.01)).*[1:200]./1; pred2 = delta_mean_logRe(i,round(frac/0.01)).*[1:200]./1;
%             pred = exp(mean_logRn(i,round(frac/0.01))- abs(pred1))  + exp(mean_logRe(i,round(frac/0.01))- abs(pred2));
%             pred = exp(log(Rn(i,round(frac/0.01)))- abs(pred1))  + exp(log(Re(i,round(frac/0.01)))- abs(pred2));
%             pred = Rn(i,round(frac/0.01)) + Re(i,round(frac/0.01)) - exp(-abs(pred1) -abs(pred2));
%             pred = round(frac*target) + cumsum((pred_Rn+pred_Re) .* interval);
%             pred = exp(delta_mean_logRn(i,round(frac/0.01))).*[1:200] + exp(delta_mean_logRe(i,round(frac/0.01))).*[1:200]; 
%             pred = ( exp(mean_logRn(i,round(frac/0.01))) + exp(mean_logRe(i,round(frac/0.01))) + cumsum(pred,2) ) .* ( repmat(sorted_time(round(frac/0.01))-sorted_time(1),1,200) + repmat(interval,1,200).*[1:200] );
%             if ~isempty(find(pred>=target,1))
%                 pred_time(round(frac/0.01)) = sorted_time(round(frac*target)) + find(pred>=target,1)*interval;
%             end
%         end
        % % % % % % %
    end
    
    temp = sorted_time(round([0.06:0.01:1 ones(1,4)]*target))';
    errorForward(i,:) = abs(temp - pred_nearFuture) ./ (temp - sorted_time(1));
    errorForward(errorForward>1)=1;
    
    temp = abs((repmat(actual_timing(i),1,99) - pred_time) ./ (actual_timing(i)-sorted_time(1)));
    temp(temp>1) = 1;
    errorTotal(i,:) = temp;
end


toc;

