function s = fgetstr(fid)
    % 增强版 fgetstr：自动跳过空白符，并免疫 Excel 带来的特殊符号
    s = fscanf(fid, '%s', 1);
    
    % 如果读到了文件末尾，返回特殊标记
    if isempty(s)
        s = 'EOF_REACHED'; 
    else
        % 【关键修复】剔除字符串里可能附带的任何双引号或单引号
        s = strrep(s, '"', ''); 
        s = strrep(s, '''', ''); 
    end
end