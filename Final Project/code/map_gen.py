string = "{vgaR, vgaG, vgaB}"
def vertical(i):
    return f'''
                        if({i}<=y && y<={i}+10) begin
                            if(x==230) {string} = 12'h767;
                            if(x==250) {string} = 12'h767;
                            if(x==270) {string} = 12'h767;
                            if(x==290) {string} = 12'h767;
                            if(x==310) {string} = 12'h767;
                            if(x==330) {string} = 12'h767;
                            if(x==350) {string} = 12'h767;
                            if(x==370) {string} = 12'h767;
                            if(x==390) {string} = 12'h767;
                            if(x==410) {string} = 12'h767;
                        end
                        if({i}+10<y && y<={i}+20) begin
                            if(x==220) {string} = 12'h767;
                            if(x==240) {string} = 12'h767;
                            if(x==260) {string} = 12'h767;
                            if(x==280) {string} = 12'h767;
                            if(x==300) {string} = 12'h767;
                            if(x==320) {string} = 12'h767;
                            if(x==340) {string} = 12'h767;
                            if(x==360) {string} = 12'h767;
                            if(x==380) {string} = 12'h767;
                            if(x==400) {string} = 12'h767;
                            if(x==420) {string} = 12'h767;
                        end
'''
def hor(i):
    return f'''
                        if(220<=x && x<=420) if(y=={i}) {string} = 12'h767;
'''
with open(".\\a.txt", "w") as file:
    for y in range(30, 400, 10):
        file.write(hor(y))    
    for y in range(30, 400, 30):
        file.write(vertical(y))