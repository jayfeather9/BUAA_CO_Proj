import re

def read_file(file_name):
    s = ""
    try:
        f = open(file_name, "r", encoding="utf-16")
        s = f.read()
        f.close()
    except:
        try:
            f = open(file_name, "r", encoding="utf-8")
            s = f.read()
            f.close()
        except:
            try:
                f = open(file_name, "r")
                s = f.read()
                f.close()
            except:
                assert(0)
    return s

bad_type = 0
first_bad = [[0,0,0],[0,0,0]]

def cmp(arr1, arr2):
    if (len(arr1) != len(arr2)):
        return 0
    for i in range(len(arr1)):
        if (arr1[i] != arr2[i]):
            return 0
    return 1

def cmp2(arr1, arr2):
    global bad_type
    global first_bad
    if len(arr1) == 0:
        badtype = 2
        return 0
    if len(arr2) == 0:
        badtype = 1
        return 0
    for i in range(len(arr1)):
        if (len(arr1) != len(arr2) and (i == len(arr2)-1 or i == len(arr1)-1)):
            bad_type = 1 if len(arr1) > len(arr2) else 2
            return 0
        if (cmp(arr1[i][1:], arr2[i][1:]) == 0):
            first_bad[0] = arr1[i][:]
            first_bad[1] = arr2[i][:]
            return 0
    return 1

std = read_file("MARSOut.txt")
ans = read_file("CPUOut.txt")

data_pattern = re.compile(r"([0-9]*)@([0-9a-fA-F]{8}): \*([0-9a-fA-F]{8}) <= ([0-9a-fA-F]{8})")
reg_pattern = re.compile(r"([0-9]*)@([0-9a-fA-F]{8}): \$ ([1-9][0-9]{0,1}) <= ([0-9a-fA-F]{8})")

std_data_result = data_pattern.findall(std)
std_reg_result = reg_pattern.findall(std)
ans_data_result = data_pattern.findall(ans)
ans_reg_result = reg_pattern.findall(ans)

bad_type = 0
first_bad = [[0,0,0,0],[0,0,0,0]]
print("Good Data!" if cmp2(std_data_result, ans_data_result) else \
    "Data less results than std!" if bad_type == 1 else \
    "Data more results than std!" if bad_type == 2 else \
    f"Data not same results, get {first_bad[1][0]}@{first_bad[1][1]}: *{first_bad[1][2]} <= {first_bad[1][3]}\n \
        expected {first_bad[0][0]}@{first_bad[0][1]}: *{first_bad[0][2]} <= {first_bad[0][3]}")
bad_type = 0
first_bad = [[0,0,0],[0,0,0]]
print("Good Reg!" if cmp2(std_reg_result, ans_reg_result) else \
    "Reg less results than std!" if bad_type == 1 else \
    "Reg more results than std!" if bad_type == 2 else \
    f"Reg not same results, get {first_bad[1][0]}@{first_bad[1][1]}: ${first_bad[1][2]} <= {first_bad[1][3]}\n \
        expected {first_bad[0][0]}@{first_bad[0][1]}: ${first_bad[0][2]} <= {first_bad[0][3]}")