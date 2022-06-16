%Description:
%       Writes a property to whatever storage means is
%       currently being used
%Usage: 
%       set_property(value,i,j,prop_name)
%       
function [] = set_property(value,i,j,prop_name,varargin)
global config

i_index = config.sample_set(i);
if j == -1
  j_index = -1;
else
  j_index = config.sample_set(j);
end

%Hack so you can pass down varargin from parent functions
if size(varargin) == [1 1] & isa(varargin{1},'cell') 
  varargin = varargin{1};
end

%If we are setting the ground truth id of an image some special things need to happen
if strcmp(prop_name,'gt_id')
  ground_truth = load_ground_truth();
  computed = load_computed(i_index,varargin);
  if isequal(value,'new')
    value = ground_truth.num_gtids+1;
  end
  if(value <= ground_truth.num_gtids)
    %Append the new image to the ground truth
    otherids = ground_truth.gtid_to_imgids(value);
    ground_truth.gtid_to_imgids(value) = unique([otherids, i_index]);
    
    correct_sex = '';
    %Check to make sure certain properties are consistent
    for id = otherids
      other_comp = load_computed(id,varargin);
      if ~strcmp(other_comp.sex, computed.sex) & isempty(correct_sex)
        correct_sex = questdlg('What is the correct sex?','Inconsistent Labeling',computed.sex,other_comp.sex,computed.sex);
      end
    end
    
    %Correct any errors
    for id = [otherids value]
      other_comp = load_computed(id,varargin);
      if ~isempty(correct_sex)
        other_comp.sex = correct_sex;
        computed.sex = correct_sex;
        save_computed(0,other_comp);
      end
    end
  else
    %Create a new ground truth entry
    ground_truth.gtid_to_names(value) = query_property(i,-1,'name');
    ground_truth.names_to_gtid(query_property(i,-1,'name')) = value;
    ground_truth.gtid_to_imgids(value) = [i_index];
    ground_truth.num_gtids = ground_truth.num_gtids + 1;
  end
  save_ground_truth(ground_truth);

elseif j_index == -1 %sum(strcmp(prop_name,{computed_fields{1,:}}))
  computed = load_computed(i_index,varargin);
  computed = setfield(computed,prop_name,value);
  save_computed(i_index,computed);
%--------
else %sum(strcmp(prop_name, statistic_fields))
  statistics = load_statistics(i_index,varargin);
  stat_field = getfield(statistics,prop_name);
  stat_field(j_index) = value;
  statistics = setfield(statistics,prop_name,stat_field);
  save_statistics(i_index,statistics);  
end
