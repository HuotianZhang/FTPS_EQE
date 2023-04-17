function update_data_table(table, gap, vocsq, vocrad, voc)
    current_data = table.Data;
    new_row = {gap, vocsq, vocrad, voc};
    
    if isempty(current_data)
        table.Data = new_row;
    else
        table.Data = [current_data; new_row];
    end
end
