b  = "b"
c  = "c"
d  = "d"
e  = "e"
f  = "f"
g  = "g"

hc = "hc"
hd = "hd"
he = "he"
hf = "hf"
hg = "hg"

M2 = [ hc, hc, hc, hc, g,  g,  b,  b ]
M3 = [ hc, hc, g,  g,  e,  e,  c,  c ]
M4 = [ g,  g,  g,  g,  f,  f,  d,  d ]
M5 = [ e,  e,  e,  e,  g,  g,  b,  b ]
M6 = [ hc, hc, hc, hc, g,  g,  b,  b ]
M7 = [ hc, hc, g,  g,  c,  c,  c,  c ]

M = [M2, M3, M4, M5, M6, M7]

for measure, M_list in enumerate(M, start = 2):
    print(f'// ----Measure {measure + 1}---- //')
    for j in range(len(M_list)):
        for k in range(8):
            if (not (k % 2)):
                print(f"12'd{64 * measure + j * 8 + k}: toneL = `{M_list[j]};    ", end = '')
            else:
                print(f"12'd{64 * measure + j * 8 + k}: toneL = `{M_list[j]};")
        print('')