c  = "c"
g  = "g"
b  = "b"
hc = "hc"
hd = "hd"
he = "he"
hf = "hf"
hg = "hg"

M2 = [hg, he, he, he, hf, hd, hd, hd]
M3 = [hc, he, hg, hg, he, he, he, he]
M4 = [hd, hd, hd, hd, hd, he, hf, hf]
M5 = [he, he, he, he, he, hf, hg, hg]
M6 = [hg, he, he, he, hf, hd, hd, hd]
M7 = [hc, he, hg, hg, hc, hc, hc, hc]

M = [M2, M3, M4, M5, M6, M7]

for measure, M_list in enumerate(M, start = 2):
    print(f'// ----Measure {measure + 1}---- //')
    for j in range(len(M_list)):
        for k in range(8):
            if (not (k % 2)):
                print(f"12'd{64 * measure + j * 8 + k}: toneR = `{M_list[j]};    ", end = '')
            else:
                print(f"12'd{64 * measure + j * 8 + k}: toneR = `{M_list[j]};")
        print('')