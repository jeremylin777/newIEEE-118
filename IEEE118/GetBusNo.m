function code = GetBusNo(AllBusName, BusName)
BusNum = length(AllBusName);
for code = 1:BusNum
   if(strcmp(AllBusName(code), BusName)==1)
      return
   end
end
ErrMsg = strcat('Invalid BusName: ', BusName);
disp(ErrMsg);
error('Error occured in Fucntions "GetBusNo". Exit by DPL');
   
   