function formulas = printRxnFormulaGF(model,rxnAbbrList,printFlag,lineChangeFlag,metNameFlag,fid,directionFlag)
%printRxnFormula Print the reaction formulas for a list of reactions
%
%
%INPUTS
% model             COBRA model structure
%
%OPTIONAL INPUTS
% rxnAbbrList       Abbrs of reactions whose formulas are to be printed
% printFlag         Print formulas or just return them (Default = true)
% lineChangeFlag    Append a line change at the end of each line
%                   (Default = true)
% metNameFlag       print full met names instead of abbreviations 
%                   (Default = false)
% fid               Optional file identifier for printing in files
% directionFlag     Checks directionality of reaction. See Note.
%                   (Default = true)
%
%OUTPUT
% formulas          Cell array containing formulas of specified reactions
%
% NOTE: Reactions that have an upperbound <= 0 and lowerbound < 0 will have
% its directionality reversed unless directionFlag = false.
%
% Markus Herrgard 11/17/05
%
% 04/30/08 Ronan Fleming
% altered code since findRxnIDs used abbreviations not names of reactions
%
% 10/11/09 Jeff Orth
% added metNameFlag option
%
% 03/10/10 Richard Que
% added lb < 0 requirement for reversing directionality

if (nargin < 2)
    rxnAbbrList = model.rxns;
end
if (nargin < 3)
    printFlag = true;
end
if (nargin < 4)
    lineChangeFlag = true;
end
if (nargin <5)
    metNameFlag = false;
end
if (nargin < 6)
    fid = 1;
end
if (nargin < 7)
    directionFlag = false; %keng: changed default to false
end

if (~iscell(rxnAbbrList))
    if (strcmp(rxnAbbrList,'all'))
        rxnAbbrList = model.rxns;
    else
        rxnAbbrTmp = rxnAbbrList;
        clear rxnAbbrList;
        rxnAbbrList{1} = rxnAbbrTmp;
    end
end

for i = 1:length(rxnAbbrList);

    rxnAbbr = rxnAbbrList{i};

    rxnID = findRxnIDs(model,rxnAbbr);

    if (printFlag)
        fprintf(fid,'%s\t',rxnAbbr);
    end
    
    if (rxnID > 0)

        Srxn = full(model.S(:,rxnID));

        if directionFlag && (isfield(model,'ub') && model.ub(rxnID) <= 0) && (isfield(model,'lb') && model.lb(rxnID) < 0)
            % If directionFlag is true, then for flux ranges with negative
            % values the reported reaction will be inverted, i.e. not as
            % stated by the stoichiometric matrix.
            Srxn = -Srxn;
        end

        Sprod = (Srxn(Srxn > 0));
        if metNameFlag
            prodMets = model.metNames(Srxn > 0);
        else
            prodMets = model.mets(Srxn > 0);
        end
        
        Sreact = (Srxn(Srxn < 0));
        if metNameFlag
            reactMets = model.metNames(Srxn < 0);
        else
            reactMets = model.mets(Srxn < 0);
        end
        
        formulaStr = '';
        for j = 1:length(reactMets)
            if (j > 1)
                if (printFlag)
                    fprintf(fid,'+ ');
                end
                formulaStr = [formulaStr '; '];
            end
            if (abs(Sreact(j)) ~= 1)
                if (printFlag)
                    fprintf(fid,'%f %s ',abs(Sreact(j)),reactMets{j});
                end
                formulaStr = [formulaStr  reactMets{j} ;];
            else
                if (printFlag)
                    fprintf(fid,'%s ',reactMets{j});
                end
                formulaStr = [formulaStr  reactMets{j}];
            end
        end

        if (model.rev(rxnID))
            if (printFlag)
                fprintf(fid,'<=> ');
            end
            formulaStr = [formulaStr '; '];
        else
            if (model.lb(rxnID) == 0)
                if (printFlag)
                    fprintf(fid,'-> ');
                end
                formulaStr = [formulaStr '; '];
            else
                if (printFlag)
                    fprintf(fid,'<- ');
                end
                formulaStr = [formulaStr '; '];
            end
        end
        
        if 0
            if length(formulaStr)>200
                %most probably this is the biomass reaction 
                if (printFlag)
                    fprintf(fid,'\n');
                end
            end
        end
        
        for j = 1:length(prodMets)
            if (j > 1)
                if (printFlag)
                    fprintf(fid,'+ ');
                end
                formulaStr = [formulaStr '; '];
            end
            if (Sprod(j) ~= 1)
                if (printFlag)
                    fprintf(fid,'%f %s ',Sprod(j),prodMets{j});
                end
                formulaStr = [formulaStr   prodMets{j} ];
            else
                if (printFlag)
                    fprintf(fid,'%s ',prodMets{j});
                end
                formulaStr = [formulaStr  prodMets{j} ];
            end
        end
        if (printFlag) && 0
            fprintf('\t.');
        end
        
    else
        if (printFlag)
            fprintf(fid,'not in model');
        end
        formulaStr = 'NA';
    end
    if (printFlag)
%         if (rxnID > 0) && (isfield(model,'grRules'))
%             if (isempty(model.grRules{rxnID}))
%                 fprintf('\t');
%             else
%                 fprintf('\t%s',model.grRules{rxnID});
%             end
%         end
        if (lineChangeFlag)
            fprintf(fid,'\n');
        end
    end
    formulas{i} = formulaStr;

end
formulas = formulas';
