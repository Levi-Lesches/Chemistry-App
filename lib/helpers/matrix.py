def get_pivot (col: list) -> (int, int): 
    result_index = None
    result = None
    for index, value in enumerate (col): 
        if value != 0: return index, value
        else: 
            result_index = index
            result = value

    else: return result_index, result
