def gen_row_num(file_name, out_file_name):
    f = open(file_name, "r", encoding="utf-8")
    s = f.read().split('\n')
    f.close()
    f = open(out_file_name, "w")
    cnt = 0
    for i in s:
        while (len(i) > 0 and (i[0] == " " or i[0] == "\t")):
            i = i[1:]
        if len(i) == 0 or i[-1] == ":" or i[0] == "." or i[0] == "#":
            f.write(i + '\n')
        else:
            f.write("%s\t\t\t# %08x\n" % (i, cnt + 0x3000))
            cnt += 4
    f.close()


if __name__ == "__main__":
    gen_row_num("mips1.asm", "mips1_good.asm")